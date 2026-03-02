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

# Instead of using SLS which if the target is a file, while open the file and read it, we use this version of sls which is similar to grep
function grep {
    param (
        [Parameter(ValueFromPipeline)]
        [string]$inputObject, # Input from the pipeline

		[Parameter(Position = 0, Mandatory = $true)]
        [string]$userInput  # Input directly from the user
    )
	Process {
		$inputObject | sls -Pattern $userInput.toString()
	}
}

# For Fabric https://github.com/danielmiessler/fabric/tree/main

# Path to the patterns directory
$patternsPath = Join-Path $HOME ".config/fabric/patterns"

# Loop through each directory in the patterns folder (each pattern)
foreach ($patternDir in Get-ChildItem -Path $patternsPath -Directory) {
    $patternName = $patternDir.Name

    # Dynamically define a function for each pattern
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
        # Initialize an array to collect pipeline input
        `$collector = @()
    }

    process {
        # Collect pipeline input objects
        if (`$InputObject) {
            `$collector += `$InputObject
        }
    }

    end {
        # Join all pipeline input into a single string, separated by newlines
        `$pipelineContent = `$collector -join "`n"

        # If there's pipeline input, include it in the call to fabric
        if (`$pipelineContent) {
            `$pipelineContent | fabric --pattern $patternName `$patternArgs
        } else {
            # No pipeline input; just call fabric with the additional args
            fabric --pattern $patternName `$patternArgs
        }
    }
}
"@

    # Uncomment this for debugging to see the generated function text
    # Write-Host "--------`n$functionDefinition`n--------"

    # Add the function to the current session
    Invoke-Expression $functionDefinition
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
# Usage: yt "apikey" "youtube.com/link" 
function Get-YTTranscript {
    param(
        [Parameter(Mandatory = $true)]
        [string]$License,
        [Parameter(Mandatory = $true)]
        [string]$Url
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

    (Invoke-WebRequest -Method POST "https://www.youtube-transcript.io/api/transcripts" `
        -Headers @{
        Authorization  = "Basic $License"
        "Content-Type" = "application/json"
    } `
        -Body $body
    ).Content.ToString() | jq -r '.[].text'
}

Set-Alias yt Get-YTTranscript
