# Sobe os quatro módulos do PortfolioHub, cada um em sua própria janela.
#
#   .\run
#
# Janelas separadas são propositais: permitem parar um módulo isolado sem
# derrubar os demais. Nenhuma variável de ambiente é necessária — os
# application.yml leem o .env da raiz do projeto.

$ErrorActionPreference = "Stop"
$raiz = $PSScriptRoot

try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }

$OK      = [char]0x2714   # ✔
$FALHA   = [char]0x2718   # ✘
$AVISO   = [char]0x26A0   # ⚠
$ATIVO   = [char]0x25CF   # ●

# Fora do plano básico: precisam de ConvertFromUtf32, pois [char] não comporta
# pares substitutos. O 💼 é o mesmo do título do README, para o terminal e a
# documentação partilharem a identidade visual.
$PROJETO = [char]::ConvertFromUtf32(0x1F4BC)   # 💼
$WEB     = [char]::ConvertFromUtf32(0x1F310)   # 🌐
$OLHO    = [char]::ConvertFromUtf32(0x1F441)   # 👁
$FRAMES  = @([char]0x280B, [char]0x2819, [char]0x2839, [char]0x2838, [char]0x283C,
             [char]0x2834, [char]0x2826, [char]0x2827, [char]0x2807, [char]0x280F)

# Uma cor por quadro. Como as duas listas têm o mesmo comprimento, o ciclo de cor
# acompanha o giro e produz uma pulsação, em vez de piscar fora de compasso.
$CORES_GIRO = @("DarkBlue", "Blue", "DarkCyan", "Cyan", "White",
                "Cyan", "DarkCyan", "Blue", "DarkBlue", "DarkBlue")

$LARGURA = 62

function Escrever-Linha($icone, $nome, $porta, $estado, $tempo, $cor) {
    $linha = "  {0} {1,-18} {2,-6} {3}" -f $icone, $nome, $porta, $estado
    if ($tempo) { $linha = "{0,-46} {1,8}" -f $linha, $tempo }
    Write-Host ("`r" + $linha.PadRight($LARGURA)) -ForegroundColor $cor
}

function Test-Porta($porta) {
    # TcpClient com timeout curto: Test-NetConnection leva segundos em porta
    # fechada e tornaria o laço de espera inútil.
    $cliente = New-Object System.Net.Sockets.TcpClient
    try {
        $conexao = $cliente.BeginConnect("127.0.0.1", $porta, $null, $null)
        if (-not $conexao.AsyncWaitHandle.WaitOne(300)) { return $false }
        $cliente.EndConnect($conexao)
        return $true
    }
    catch { return $false }
    finally { $cliente.Close() }
}

function Iniciar-Modulo($nome, $porta, $limite = 120) {
    if (Test-Porta $porta) {
        Escrever-Linha $ATIVO $nome $porta "já ativo" $null "DarkGray"
        return $true
    }

    $comando = "`$host.UI.RawUI.WindowTitle = '$nome :$porta'; Set-Location '$raiz'; mvn -pl $nome spring-boot:run"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $comando

    $cronometro = [System.Diagnostics.Stopwatch]::StartNew()
    $quadro = 0
    while ($cronometro.Elapsed.TotalSeconds -lt $limite) {
        if (Test-Porta $porta) {
            $cronometro.Stop()
            $tempo = "{0:N1}s" -f $cronometro.Elapsed.TotalSeconds
            Escrever-Linha $OK $nome $porta "no ar" $tempo "Green"
            return $true
        }
        $giro = $FRAMES[$quadro % $FRAMES.Length]
        $corGiro = $CORES_GIRO[$quadro % $CORES_GIRO.Length]
        $decorrido = "{0:N0}s" -f $cronometro.Elapsed.TotalSeconds

        # Três escritas para que só o glifo receba a cor pulsante; o texto ao lado
        # permanece discreto. As larguras batem com as de Escrever-Linha, então a
        # linha final substitui esta sem deslocar nenhuma coluna.
        $corpo = " {0,-18} {1,-6} iniciando" -f $nome, $porta
        $resto = "{0,-43} {1,8}" -f $corpo, $decorrido
        Write-Host "`r  " -NoNewline
        Write-Host $giro -NoNewline -ForegroundColor $corGiro
        Write-Host $resto.PadRight($LARGURA - 3) -NoNewline -ForegroundColor DarkGray

        Start-Sleep -Milliseconds 120
        $quadro++
    }

    $cronometro.Stop()
    Escrever-Linha $FALHA $nome $porta "sem resposta" "$limite s" "Red"
    return $false
}

# ─────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  $PROJETO " -NoNewline
Write-Host "PortfolioHub" -ForegroundColor White -NoNewline
Write-Host "  ·  inicialização do ambiente" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-Path (Join-Path $raiz "pom.xml"))) {
    Escrever-Linha $FALHA "raiz do projeto" "" "pom.xml não encontrado" $null "Red"
    exit 1
}

# --- serviços de apoio ---
$falhou = $false
foreach ($banco in @(@{ n = "PostgreSQL"; p = 18432 }, @{ n = "MongoDB"; p = 18017 })) {
    if (Test-Porta $banco.p) {
        Escrever-Linha $OK $banco.n $banco.p "pronto" $null "Green"
    }
    else {
        Escrever-Linha $FALHA $banco.n $banco.p "fora do ar" $null "Red"
        $falhou = $true
    }
}

if ($falhou) {
    Write-Host ""
    Write-Host "  $AVISO  Suba os bancos antes de continuar:" -ForegroundColor Yellow
    Write-Host "     docker compose up -d" -ForegroundColor White
    Write-Host ""
    exit 1
}

Write-Host ""

# --- módulos, na ordem em que dependem uns dos outros ---
$modulos = @(
    @{ nome = "discovery-server"; porta = 18761 },
    @{ nome = "profile-service";  porta = 18081 },
    @{ nome = "project-service";  porta = 18082 },
    @{ nome = "api-gateway";      porta = 18080 }
)

$ativos = 0
foreach ($m in $modulos) {
    if (Iniciar-Modulo $m.nome $m.porta) { $ativos++ }
    else {
        Write-Host ""
        Write-Host "  $AVISO  Consulte a janela '$($m.nome) :$($m.porta)' para o erro." -ForegroundColor Yellow
        Write-Host ""
        exit 1
    }
}

# --- resumo ---
# Duas notas ascendentes, distintas do bipe grave e único que sinaliza queda:
# subir e cair precisam soar diferente sem exigir que você olhe a tela.
try { [Console]::Beep(880, 120); [Console]::Beep(1320, 160) } catch { }

Write-Host ""
Write-Host "  $OK Ambiente no ar" -ForegroundColor Green -NoNewline
Write-Host "  ·  $ativos módulos, cada um em sua janela" -ForegroundColor DarkGray
Write-Host ""
Write-Host "    $WEB Entrada única   " -ForegroundColor DarkGray -NoNewline
Write-Host "http://localhost:18080" -ForegroundColor Cyan
Write-Host "    $WEB Registro Eureka " -ForegroundColor DarkGray -NoNewline
Write-Host "http://localhost:18761" -ForegroundColor Cyan
Write-Host ""

# --- monitor ---
# Acompanha as portas e avisa quando um módulo cai ou volta. Encerrar o monitor
# não derruba nada: cada módulo vive na própria janela.
Write-Host "  $OLHO monitorando status " -ForegroundColor DarkGray -NoNewline
Write-Host "no ar" -ForegroundColor Green -NoNewline
Write-Host " dos módulos de serviços " -ForegroundColor DarkGray -NoNewline
Write-Host "(Ctrl+C encerra o monitor)" -ForegroundColor DarkGray
Write-Host ""

$estado = @{}
foreach ($m in $modulos) { $estado[$m.nome] = $true }

while ($true) {
    Start-Sleep -Seconds 2
    foreach ($m in $modulos) {
        $agora = Test-Porta $m.porta
        if ($agora -eq $estado[$m.nome]) { continue }

        $hora = Get-Date -Format "HH:mm:ss"
        if ($agora) {
            Write-Host "  $OK " -ForegroundColor Green -NoNewline
            Write-Host ("{0,-18} {1,-6} " -f $m.nome, $m.porta) -NoNewline
            Write-Host "voltou ao ar" -ForegroundColor Green -NoNewline
            Write-Host "   $hora" -ForegroundColor DarkGray
        }
        else {
            try { [Console]::Beep(660, 180) } catch { }
            Write-Host "  $FALHA " -ForegroundColor Red -NoNewline
            Write-Host ("{0,-18} {1,-6} " -f $m.nome, $m.porta) -NoNewline
            Write-Host "encerrado" -ForegroundColor Red -NoNewline
            Write-Host "      $hora" -ForegroundColor DarkGray
        }
        $estado[$m.nome] = $agora
    }
}
