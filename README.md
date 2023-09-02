# powershell-profile
This PowerShell profile makes the Windows PowerShell a bit better

Save `Profile.ps1` in `Documents/WindowsPowershell/`. 

What it does is: 
- Makes tab-completion look and feel like Linux. It presents all options instead of rotating through each option.
- Creates function `Get-History-Full`, with alias `hist`. This allows you to see all commands you've run previously.
- Creates alias `head` for `select-object`, allowing us to do things like `head -First 10`. 
