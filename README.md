# powershell-profile
This PowerShell profile makes the Windows PowerShell a bit better

# Powershell 5 
Save `Profile.ps1` in `Documents/WindowsPowershell/`. 

# Powershell 7
Save `Profile.ps1` to `Documents/Powershell/Microsoft.PowerShell_profile.ps1`

## Don't have Powershell 7? 
Powershell has a lot of quality of life upgrades. I recommend installing it and setting it as the default with Windows Terminal (https://apps.microsoft.com/store/detail/windows-terminal/9N0DX20HK701). You can install Powershell 7 with the built-in Windows packet manager `winget` like this: `winget install --id Microsoft.Powershell --source winget`. 

### Setting Powershell 7 as default in Windows Terminal 
Setting it to be the default shell is done by opening up the settings, then opening the settings.json: 
![image](https://github.com/ChrisAD/powershell-profile/assets/6368326/40d052ca-31ed-4026-aba8-9be4393a0c62)

Change the defaultProfile value to be the GUID of the Powershell 7 profile. Below you can see the GUID of mine which I found further down in the json file. Copy the GUID and add it as the defaultProfile value. 
![image](https://github.com/ChrisAD/powershell-profile/assets/6368326/1efac4c0-f950-49bc-b108-535f659484b5)



# What it does 
What it does is: 
- Makes tab-completion look and feel like Linux. It presents all options instead of rotating through each option.
- Creates function `Get-History-Full`, with alias `hist`. This allows you to see all commands you've run previously.
- Creates alias `head` for `select-object`, allowing us to do things like `head -First 10`.
- Edits the prompt to include the current branch, if the folder is a git repo. 
- Loads all fabric patterns and makes them available as functions, allowing things like `get-clipboard | <pattern>`, e.g. `iwr example.com | so -ExpandProperty content | summarize` and of course much much more. 
- Installs aadintenrals if it is not already installed. Can be then used by `import-module aadinternals`
- Takes each Fabric pattern and turns it into a command
- Allows you to do yt <url> to get youtube transcript
- Allows for scrape <url> to get markdown (LLM friendly) formatting of a URL
