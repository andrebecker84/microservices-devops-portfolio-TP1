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

RAIZ="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CERTS="$RAIZ/certs"
DIAS=825                 # limite aceito pelos navegadores para certificado de servidor
SENHA_TRUSTSTORE=changeit

mkdir -p "$CERTS"
cd "$CERTS"

azul()    { printf '\033[36m%s\033[0m\n' "$1"; }
verde()   { printf '\033[32m  ✔ %s\033[0m\n' "$1"; }
cinza()   { printf '\033[90m  · %s\033[0m\n' "$1"; }

azul ""
azul "  PortfolioHub · geração de certificados"
azul ""

# ─── autoridade certificadora ────────────────────────────────────────────────
if [[ -f ca.crt && -f ca.key ]]; then
    cinza "CA já existe, mantida (apague certs/ para recriar do zero)"
else
    openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
        -keyout ca.key -out ca.crt \
        -subj "/CN=PortfolioHub Local CA/O=PortfolioHub/C=BR" \
        -addext "basicConstraints=critical,CA:TRUE" \
        -addext "keyUsage=critical,keyCertSign,cRLSign" 2>/dev/null
    chmod 600 ca.key
    verde "autoridade certificadora criada (validade 10 anos)"
fi

# ─── certificados de servidor ────────────────────────────────────────────────
# Cada certificado precisa valer para DOIS nomes: o nome do serviço na rede do
# Compose (usado entre containers) e localhost (usado pelo navegador e pelo
# cliente HTTP na sua máquina). Sem os dois no SAN, um dos lados recusa.
emitir() {
    local nome=$1
    if [[ -f "$nome.crt" && -f "$nome.key" ]]; then
        cinza "$nome — já existe, mantido"
        return
    fi

    openssl req -newkey rsa:2048 -sha256 -nodes \
        -keyout "$nome.key" -out "$nome.csr" \
        -subj "/CN=$nome/O=PortfolioHub/C=BR" 2>/dev/null

    openssl x509 -req -in "$nome.csr" -CA ca.crt -CAkey ca.key -CAcreateserial \
        -out "$nome.crt" -days "$DIAS" -sha256 \
        -extfile <(printf 'subjectAltName=DNS:%s,DNS:localhost,IP:127.0.0.1\nkeyUsage=critical,digitalSignature,keyEncipherment\nextendedKeyUsage=serverAuth\n' "$nome") \
        2>/dev/null

    rm -f "$nome.csr"
    chmod 600 "$nome.key"
    verde "$nome"
}

for servico in postgres mongo discovery-server profile-service project-service api-gateway; do
    emitir "$servico"
done

# ─── PEM combinado exigido pelo MongoDB ──────────────────────────────────────
# O mongod quer chave e certificado no mesmo arquivo, nessa ordem.
if [[ ! -f mongo.pem ]]; then
    cat mongo.key mongo.crt > mongo.pem
    chmod 600 mongo.pem
    verde "mongo.pem (chave + certificado combinados)"
fi

# ─── truststore para a JVM ───────────────────────────────────────────────────
# Contém só a CA. É o que faz os serviços Java confiarem uns nos outros e nos
# bancos, sem recorrer a "aceitar qualquer certificado".
if [[ ! -f truststore.p12 ]]; then
    openssl pkcs12 -export -nokeys -in ca.crt -out truststore.p12 \
        -passout "pass:$SENHA_TRUSTSTORE" -name portfoliohub-ca 2>/dev/null
    verde "truststore.p12 (contém apenas a CA pública)"
fi

echo
azul "  Arquivos em certs/"
ls -1 | sed 's/^/    /'
echo
printf '\033[33m  Próximo passo — confie na CA para o navegador parar de avisar:\033[0m\n'
echo
printf '    \033[97mImport-Certificate -FilePath "%s\\ca.crt" -CertStoreLocation Cert:\\CurrentUser\\Root\033[0m\n' "$(cygpath -w "$CERTS" 2>/dev/null || echo "$CERTS")"
echo
printf '\033[90m    Instala apenas para o seu usuário, não para a máquina toda.\n'
printf '    Para remover depois da entrega: abra certmgr.msc, vá em Autoridades de\n'
printf '    Certificação Raiz Confiáveis e apague "PortfolioHub Local CA".\033[0m\n'
echo
