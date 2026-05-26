Set-PSReadlineKeyHandler -Key Tab -Function Complete

Function Get-History-Full {
    Get-Content (Get-PSReadlineOption).HistorySavePath
}

Set-Alias -Name hist -Value Get-History-Full -Option AllScope
Set-Alias -Name head -Value Select-Object -Option AllScope
Set-Alias -Name so -Value Select-Object -Option AllScope
Set-Alias -Name vact -Value .\venv\Scripts\activate -Option AllScope

function prompt {
    $currentDir = Get-Location
    $gitBranch = $(git rev-parse --abbrev-ref HEAD 2>$null)

    if ($gitBranch) {
        "PS $PWD [$gitBranch]> "
    }
    else {
        "PS $PWD> "
    }
}

# Instead of using SLS which, if the target is a file, will open and read it,
# we use this version of sls which is similar to grep.
function grep {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$InputObject,

        [Parameter(Position = 0, Mandatory = $true)]
        [string]$UserInput
    )

    process {
        $InputObject | Select-String -Pattern $UserInput.ToString()
    }
}

# For Fabric https://github.com/danielmiessler/fabric/tree/main

# Path to the patterns directory
$patternsPath = Join-Path $HOME ".config/fabric/patterns"

if (Get-Command fabric -ErrorAction SilentlyContinue) {
    if (Test-Path -Path $patternsPath -PathType Container) {
        $patternDirs = Get-ChildItem -Path $patternsPath -Directory -ErrorAction SilentlyContinue

        if ($patternDirs) {
            # Loop through each directory in the patterns folder, where each folder is a pattern.
            foreach ($patternDir in $patternDirs) {
                $patternName = $patternDir.Name

                # Dynamically define a function for each pattern.
                $functionDefinition = @"
function $patternName {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = `$true)]
        [string] `$InputObject,

        [Parameter(ValueFromRemainingArguments = `$true)]
        [String[]] `$patternArgs
    )

    begin {
        # Initialize an array to collect pipeline input.
        `$collector = @()
    }

    process {
        # Collect pipeline input objects.
        if (`$InputObject) {
            `$collector += `$InputObject
        }
    }

    end {
        # Join all pipeline input into a single string, separated by newlines.
        `$pipelineContent = `$collector -join "`n"

        # If there's pipeline input, include it in the call to fabric.
        if (`$pipelineContent) {
            `$pipelineContent | fabric --pattern $patternName `$patternArgs
        }
        else {
            # No pipeline input; just call fabric with the additional args.
            fabric --pattern $patternName `$patternArgs
        }
    }
}
"@

                # Uncomment this for debugging to see the generated function text.
                # Write-Host "--------`n$functionDefinition`n--------"

                # Add the function to the current session.
                Invoke-Expression $functionDefinition
            }
        }
        else {
            Write-Verbose "Fabric patterns directory exists, but no patterns were found: $patternsPath"
        }
    }
    else {
        Write-Verbose "Fabric patterns directory not found, skipping Fabric pattern function loading: $patternsPath"
    }
}
else {
    Write-Verbose "fabric command not found, skipping Fabric setup."
}

function scrape {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$scrapeUrl
    )

    fabric /scrape_url:$scrapeUrl
}

# Requires a free API key from youtube-transcript.io.
# Usage: yt "youtube.com/link" "apikey"
function Get-YTTranscript {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Url,

        [Parameter(Position = 1)]
        [string]$License = "Optional hardcoded API key"
    )

    if ($Url -match "v=([^&]+)") {
        $id = $matches[1]
    }
    elseif ($Url -match "youtu\.be/([^?&]+)") {
        $id = $matches[1]
    }
    else {
        Write-Error "Invalid YouTube URL"
        return
    }

    $body = @{ ids = @($id) } | ConvertTo-Json -Compress

    $headers = @{
        "Content-Type" = "application/json"
    }

    if ($License) {
        $headers["Authorization"] = "Basic $License"
    }

    (Invoke-WebRequest -Method POST "https://www.youtube-transcript.io/api/transcripts" `
        -Headers $headers `
        -Body $body
    ).Content.ToString() | jq -r '.[].text'
}

Set-Alias yt Get-YTTranscript

# Create a venv for the current folder.
function mkvenv {
    C:\python312\python.exe -m venv .\venv
}

function Remove-ImageBackground {
    param (
        [Parameter(Mandatory = $true)]
        [string]$APIKey,

        [Parameter(Mandatory = $true)]
        [string]$PathToFile,

        [Parameter(Mandatory = $true)]
        [string]$OutputFile
    )

    if (-not (Test-Path $PathToFile)) {
        throw "Input file not found: $PathToFile"
    }

    $headers = @{
        "X-API-Key" = $APIKey
    }

    $form = @{
        image_file = Get-Item $PathToFile
        size       = "auto"
    }

    try {
        Invoke-RestMethod `
            -Uri "https://api.remove.bg/v1.0/removebg" `
            -Method Post `
            -Headers $headers `
            -Form $form `
            -OutFile $OutputFile

        Write-Host "Background removed successfully -> $OutputFile"
    }
    catch {
        Write-Error "Failed to process image: $_"
    }
}

Set-Alias rmbg Remove-ImageBackground

function Set-WindowTitle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    $host.UI.RawUI.WindowTitle = $Title
}

Set-Alias swt Set-WindowTitle
