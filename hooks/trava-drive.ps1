# Trava do Drive H:\ (hook PreToolUse do Claude Code)
#
# Roda antes de cada ferramenta (Read, Glob, Grep, Edit, Write, Bash, PowerShell...).
# - Qualquer caminho no H:\ fora das 5 pastas liberadas -> bloqueia.
# - Dentro das 5 pastas: so leitura. Editar, criar, mover, renomear, copiar ou apagar -> bloqueia.
# Saida 2 = bloqueia (o Claude Code mostra a mensagem ao Claude). Saida 0 = segue.
# Arquivo so com ASCII de proposito: o PowerShell 5.1 le .ps1 sem BOM como ANSI.

$ErrorActionPreference = 'Stop'

function Stop-Tool([string]$motivo) {
    [Console]::Error.WriteLine("TRAVA DO DRIVE H: $motivo Pastas liberadas (so leitura): Bordero pagamentos de GAR, HR, GB Agro, DGB Ipe e BAR. Ver README do repo C:\DEV\Sobreira\Claude.")
    exit 2
}

[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$raw = [Console]::In.ReadToEnd()

try {
    $evento = $raw | ConvertFrom-Json
    $ferramenta = [string]$evento.tool_name

    # Junta todos os textos da entrada da ferramenta (caminho, padrao, comando...)
    $partes = @()
    if ($evento.tool_input) {
        foreach ($p in $evento.tool_input.PSObject.Properties) {
            if ($p.Value -is [string]) { $partes += $p.Value }
            elseif ($p.Value) { $partes += ($p.Value | ConvertTo-Json -Depth 10 -Compress) }
        }
    }
    $texto = ($partes -join "`n").ToLowerInvariant()
} catch {
    # Entrada ilegivel: se citar o H:, bloqueia por precaucao; senao segue.
    if ($raw -match '(?i)(^|[^a-z])h:[\\/]|drives compartilhados') { Stop-Tool 'entrada nao pode ser conferida.' }
    exit 0
}

# Normaliza: barra normal vira invertida; /h/... (estilo Git Bash) vira h:\...
$texto = $texto -replace '/', '\'
$texto = $texto -replace '(^|[\s"''=(])\\{1,2}h\\', '$1h:\'

$citaH = $texto -match '(^|[^a-z])h:\\|drives compartilhados'
if (-not $citaH) { exit 0 }

# 1) Ferramenta de escrita no H: -> sempre bloqueia
if ($ferramenta -match '^(Edit|MultiEdit|Write|NotebookEdit)$') {
    Stop-Tool 'o Drive e somente leitura; nenhum arquivo pode ser criado ou alterado.'
}

# 2) Comando de terminal com verbo de alteracao citando o H: -> bloqueia
if ($ferramenta -match '^(Bash|PowerShell)$') {
    $verbos = '(^|[\s;|&(])(mv|cp|rm|rmdir|mkdir|touch|tee|ln|install|rsync|truncate|del|erase|ren|rename|move|copy|xcopy|robocopy|md|rd|ni|mi|cpi|ri|rni|sc|ac|clc|move-item|copy-item|remove-item|rename-item|new-item|set-content|add-content|clear-content|out-file|set-item|export-csv|expand-archive|compress-archive|start-bitstransfer)(\s|$)|sed\s+-i|>\s*|\.(moveto|copyto|delete|writealltext|writeallbytes|create)\('
    if ($texto -match $verbos) {
        Stop-Tool 'comando de criar, alterar, mover, copiar ou apagar nao e permitido no Drive.'
    }
}

# 3) Qualquer caminho do H: fora das 5 pastas -> bloqueia
$base = 'h:\\drives compartilhados\\administrativo\\'
$fim  = '\\financeiro\\border\S{1,3} pagamentos(?=$|[\\"''\s*])'
$liberadas = @('1 - gar', '2 - hr', '3 - gb agro', '4 - dgb ipe', '5 - bar') | ForEach-Object { $base + [regex]::Escape($_) + $fim }
$resto = $texto
foreach ($pasta in $liberadas) { $resto = [regex]::Replace($resto, $pasta, '<liberada>') }

if ($resto -match '(^|[^a-z])h:\\|drives compartilhados') {
    Stop-Tool 'caminho fora das pastas liberadas.'
}

exit 0
