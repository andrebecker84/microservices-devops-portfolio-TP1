@echo off
REM Atalho para run-services.ps1, contornando a politica de execucao do PowerShell.
REM
REM   .\run     sobe os quatro modulos e mantem o monitor ativo
REM
REM Nao aceita argumentos: o comportamento e sempre o mesmo.
REM %~dp0 e a pasta deste arquivo, entao funciona chamado de qualquer diretorio.
REM Usa pwsh (PowerShell 7) quando disponivel, pelo melhor suporte a Unicode.

setlocal
where pwsh >nul 2>&1
if %errorlevel%==0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-services.ps1"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run-services.ps1"
)
endlocal
