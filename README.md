# powershell-profile
This PowerShell profile makes the Windows PowerShell a bit better

# Powershell 5 
Save `Profile.ps1` in `Documents/WindowsPowershell/`. 

# POwershell 7
Save `Profile.ps1` to `Documents/Powershell/Microsoft.PowerShell_profile.ps1`

# What it does 
What it does is: 
- Makes tab-completion look and feel like Linux. It presents all options instead of rotating through each option.
- Creates function `Get-History-Full`, with alias `hist`. This allows you to see all commands you've run previously.
- Creates alias `head` for `select-object`, allowing us to do things like `head -First 10`.
- Edits the prompt to include the current branch, if the folder is a git repo. 
