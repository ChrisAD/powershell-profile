Set-PSReadlineKeyHandler -Key Tab -Function Complete
Function Get-History-Full {Get-Content (Get-PSReadlineOption).HistorySavePath}
Set-Alias -name hist -value get-history-full -Option AllScope
Set-Alias -name head -value select-object -Option AllScope
Set-Alias -name so -value select-object -Option AllScope
Set-Alias -name vact -value .\venv\Scripts\activate -Option AllScope
function prompt {
    $currentDir = Get-Location
    $gitBranch = $(git rev-parse --abbrev-ref HEAD 2>$null)
    if ($gitBranch) {
        "PS $PWD [$gitBranch]> "
    } else {
        "PS $PWD> "
    }
}
