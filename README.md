# powershell-profile
This PowerShell profile makes the Windows PowerShell a bit better

# Powershell 5 
Save `Profile.ps1` in `Documents/WindowsPowershell/`. 

# Powershell 7
Save `Profile.ps1` to `Documents/Powershell/Microsoft.PowerShell_profile.ps1`

## Don't have Powershell 7? 
Powershell has a lot of quality of life upgrades. I recommend installing it and setting it as the default with Windows Terminal (https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701). You can install Powershell 7 with the built-in Windows packet manager `winget` like this: `winget install --id Microsoft.Powershell --source winget`

# What it does 
What it does is: 
- Makes tab-completion look and feel like Linux. It presents all options instead of rotating through each option.
- Creates function `Get-History-Full`, with alias `hist`. This allows you to see all commands you've run previously.
- Creates alias `head` for `select-object`, allowing us to do things like `head -First 10`.
- Edits the prompt to include the current branch, if the folder is a git repo. 
