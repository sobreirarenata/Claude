# Envia o resultado de uma tarefa agendada para o espaco pessoal da Renata no Google Chat.
#
# Posta o texto de um arquivo (UTF-8) no UNICO webhook guardado em
#   %USERPROFILE%\.vx-synapse\gchat-webhook-relatorios
# (fora de qualquer repo: a URL e segredo e nunca entra no git nem na conversa).
# O script nao recebe URL por parametro: so sabe postar nesse espaco.
#
# Este script esta liberado por caminho no settings.json da Renata (roda sem janelinha):
# qualquer mudanca nele passa por plano e commit.
#
# Uso (Windows PowerShell 5.1):
#   powershell -ExecutionPolicy Bypass -File C:\DEV\Sobreira\Claude\scripts\enviar-chat.ps1 -Arquivo <caminho-do-texto>
#
# Formatacao do Chat: *negrito* (um asterisco), _italico_, bullet e o caractere digitado, sem tabela.

param([Parameter(Mandatory = $true)][string]$Arquivo)

$ErrorActionPreference = 'Stop'
$limite = 4000
$hook = Join-Path $env:USERPROFILE '.vx-synapse\gchat-webhook-relatorios'

if (-not (Test-Path $hook)) {
    "NAO ENVIADO: falta o webhook em $hook. Crie o webhook no espaco do Chat e grave a URL nesse arquivo."
    exit 1
}
if (-not (Test-Path $Arquivo)) {
    "NAO ENVIADO: arquivo de texto nao encontrado: $Arquivo"
    exit 1
}

$url  = ([IO.File]::ReadAllText($hook)).Trim()
$text = ([IO.File]::ReadAllText($Arquivo, [Text.Encoding]::UTF8)).Trim()
if ($text.Length -eq 0) {
    "NAO ENVIADO: o arquivo de texto esta vazio."
    exit 1
}
if ($text.Length -gt $limite) {
    $text = $text.Substring(0, $limite - 20) + "`n(cortado)"
}

$corpo = @{ text = $text } | ConvertTo-Json -Compress
$bytes = [Text.Encoding]::UTF8.GetBytes($corpo)
try {
    $resp = Invoke-RestMethod -Method Post -Uri $url -ContentType 'application/json; charset=UTF-8' -Body $bytes
    "Enviado: $($resp.name)"
} catch {
    # Nao reenviar no automatico (duplica a mensagem). A mensagem de erro nao traz a URL.
    $codigo = $null
    if ($_.Exception.Response) { $codigo = [int]$_.Exception.Response.StatusCode }
    "NAO ENVIADO: erro HTTP $codigo - $($_.Exception.Message)"
    exit 1
}
