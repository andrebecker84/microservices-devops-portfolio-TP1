#!/usr/bin/env bash
#
# Gera a autoridade certificadora local e os certificados de servidor do PortfolioHub.
#
#   bash scripts/gerar-certificados.sh
#
# Execute no Git Bash (o openssl vem com o Git para Windows). O script é
# idempotente: se `certs/ca.crt` já existir, ele não recria a CA, apenas os
# certificados que faltarem.
#
# NADA do que este script produz vai para o Git: a pasta certs/ está no
# .gitignore. As chaves privadas nascem e permanecem nesta máquina.
#
# Sobre a senha do truststore: é `changeit`, a convenção do JDK, e isso não é
# descuido. Um truststore guarda apenas certificados PÚBLICOS — a senha existe
# para detectar adulteração do arquivo, não para proteger segredo algum.

set -euo pipefail

# O Git Bash converte argumentos iniciados por "/" em caminhos do Windows, o que
# corrompe o -subj do openssl ("/CN=..." vira "C:/.../CN=..."). Desligar a
# conversão é inofensivo em Linux e macOS, onde a variável não é consultada.
export MSYS_NO_PATHCONV=1

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERTS="$RAIZ/certs"
DIAS=825                 # limite aceito pelos navegadores para certificado de servidor
SENHA_TRUSTSTORE=changeit

mkdir -p "$CERTS"
cd "$CERTS"

azul()  { printf '\033[36m%s\033[0m\n' "$1"; }
verde() { printf '\033[32m  OK  %s\033[0m\n' "$1"; }
cinza() { printf '\033[90m  --  %s\033[0m\n' "$1"; }

# O openssl escreve o progresso em stderr. Silenciar tudo esconderia erros reais:
# foi assim que uma falha no -subj passou despercebida e o script morreu mudo.
# Aqui a saída é guardada e só aparece quando o comando falha.
executar() {
    local saida
    if ! saida="$("$@" 2>&1)"; then
        printf '\033[31m  FALHOU: %s\033[0m\n' "$1" >&2
        printf '%s\n' "$saida" | tail -5 >&2
        exit 1
    fi
}

azul ""
azul "  PortfolioHub - geracao de certificados"
azul ""

# --- autoridade certificadora ------------------------------------------------
if [[ -f ca.crt && -f ca.key ]]; then
    cinza "CA ja existe, mantida (apague certs/ para recriar do zero)"
else
    executar openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
        -keyout ca.key -out ca.crt \
        -subj "/CN=PortfolioHub Local CA/O=PortfolioHub/C=BR" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign"
    chmod 600 ca.key
    verde "autoridade certificadora criada (validade 10 anos)"
fi

# --- certificados de servidor ------------------------------------------------
# Cada certificado precisa valer para DOIS nomes: o nome do serviço na rede do
# Compose (usado entre containers) e localhost (usado pelo navegador e pelo
# cliente HTTP na máquina). Sem os dois no SAN, um dos lados recusa.
emitir() {
    local nome=$1
    if [[ -f "$nome.crt" && -f "$nome.key" ]]; then
        cinza "$nome - ja existe, mantido"
        return
    fi

    executar openssl req -newkey rsa:2048 -sha256 -nodes \
        -keyout "$nome.key" -out "$nome.csr" \
        -subj "/CN=$nome/O=PortfolioHub/C=BR"

    printf 'subjectAltName=DNS:%s,DNS:localhost,IP:127.0.0.1\nkeyUsage=critical,digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth\n' "$nome" > "$nome.ext"

    executar openssl x509 -req -in "$nome.csr" -CA ca.crt -CAkey ca.key -CAcreateserial \
        -out "$nome.crt" -days "$DIAS" -sha256 -extfile "$nome.ext"

    rm -f "$nome.csr" "$nome.ext"
    chmod 600 "$nome.key"
    verde "$nome"
}

for servico in postgres mongo discovery-server profile-service project-service api-gateway; do
    emitir "$servico"
done

# --- PEM combinado exigido pelo MongoDB --------------------------------------
# O mongod quer chave e certificado no mesmo arquivo, nessa ordem.
if [[ ! -f mongo.pem ]]; then
    cat mongo.key mongo.crt > mongo.pem
    chmod 600 mongo.pem
    verde "mongo.pem (chave + certificado combinados)"
fi

# --- truststore para a JVM ---------------------------------------------------
# Contém só a CA. É o que faz os serviços Java confiarem uns nos outros e nos
# bancos, sem recorrer a "aceitar qualquer certificado".
if [[ ! -f truststore.p12 ]]; then
    # keytool, e nao openssl. O "openssl pkcs12 -export -nokeys" produz um arquivo
    # que a JVM abre sem erro mas enxerga com ZERO entradas: faltam as marcacoes
    # de trustedCertEntry que so o keytool grava. O sintoma e obscuro -- o Tomcat
    # falha com "the trustAnchors parameter must be non-empty" na inicializacao.
    if ! command -v keytool >/dev/null 2>&1; then
        echo "  FALHOU: keytool nao encontrado. Instale um JDK." >&2
        exit 1
    fi
    executar keytool -importcert -noprompt -alias portfoliohub-ca -file ca.crt -keystore truststore.p12 -storetype PKCS12 -storepass "$SENHA_TRUSTSTORE"
    verde "truststore.p12 (contem apenas a CA publica)"
fi

echo
azul "  Arquivos em certs/"
ls -1 | sed 's/^/    /'
echo
printf '\033[33m  Proximo passo - confie na CA para o navegador parar de avisar:\033[0m\n\n'
printf '    Import-Certificate -FilePath "%s\\ca.crt" -CertStoreLocation Cert:\\CurrentUser\\Root\n\n' "$(cygpath -w "$CERTS" 2>/dev/null || echo "$CERTS")"
printf '\033[90m    Instala apenas para o seu usuario. Para remover depois: certmgr.msc,\n'
printf '    Autoridades de Certificacao Raiz Confiaveis, apague "PortfolioHub Local CA".\033[0m\n\n'
