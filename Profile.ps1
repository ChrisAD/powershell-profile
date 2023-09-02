Set-PSReadlineKeyHandler -Key Tab -Function Complete
Function Get-History-Full {Get-Content (Get-PSReadlineOption).HistorySavePath}
Set-Alias -name hist -value get-history-full -Option AllScope
Set-Alias -name head -value select-object -Option AllScope
