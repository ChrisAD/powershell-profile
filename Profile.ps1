$__profileStart = [Diagnostics.Stopwatch]::StartNew()

Set-PSReadlineKeyHandler -Key Tab -Function Complete
Function Get-History-Full {Get-Content (Get-PSReadlineOption).HistorySavePath}
Set-Alias -name hist -value get-history-full -Option AllScope
Set-Alias -name head -value select-object -Option AllScope
Set-Alias -name so -value select-object -Option AllScope
Set-Alias -name vact -value .\venv\Scripts\activate -Option AllScope

function prompt {
    try {
        $branch = $null
        $dir = Get-Location
        $probe = $dir.Path
        while ($probe) {
            if (Test-Path (Join-Path $probe '.git')) {
                $head = Join-Path $probe '.git\HEAD'
                if (Test-Path $head) {
                    $line = Get-Content $head -ErrorAction SilentlyContinue
                    if ($line -match '^ref: refs/heads/(.+)$') { $branch = $Matches[1] }
                    elseif ($line) { $branch = $line.Substring(0, [Math]::Min(7, $line.Length)) }
                }
                break
            }
            $parent = Split-Path $probe -Parent
            if (-not $parent -or $parent -eq $probe) { break }
            $probe = $parent
        }
        if ($branch) { "PS $dir [$branch]> " } else { "PS $dir> " }
    } catch {
        "PS $(Get-Location)> "
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
# Lazy registration: define one dispatcher and register each pattern name as an
# alias-like function that calls it. Avoids 166x Invoke-Expression at startup.
$patternsPath = Join-Path $HOME ".config/fabric/patterns"

function Invoke-FabricPattern {
    param(
        [Parameter(Mandatory = $true)] [string] $Pattern,
        [Parameter(ValueFromPipeline = $true)] [string] $InputObject,
        [Parameter(ValueFromRemainingArguments = $true)] [string[]] $PatternArgs
    )
    begin { $collector = @() }
    process { if ($InputObject) { $collector += $InputObject } }
    end {
        $pipelineContent = $collector -join "`n"
        if ($pipelineContent) {
            $pipelineContent | fabric --pattern $Pattern $PatternArgs
        } else {
            fabric --pattern $Pattern $PatternArgs
        }
    }
}

if (Test-Path $patternsPath) {
    $__fabricTemplate = {
        param(
            [Parameter(ValueFromPipeline = $true)] [string] $i,
            [Parameter(ValueFromRemainingArguments = $true)] [string[]] $a
        )
        begin { $c = @() }
        process { if ($i) { $c += $i } }
        end {
            $p = $c -join "`n"
            if ($p) { $p | Invoke-FabricPattern -Pattern $__patternName -PatternArgs $a }
            else    { Invoke-FabricPattern -Pattern $__patternName -PatternArgs $a }
        }
    }.ToString()
    foreach ($patternDir in Get-ChildItem -Path $patternsPath -Directory) {
        $name = $patternDir.Name
        $body = "`$__patternName = '$name'; " + $__fabricTemplate
        Set-Item -Path "function:$name" -Value $body
    }
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
# Usage: yt  "youtube.com/link" "apikey"
function Get-YTTranscript {
    param(
        [Parameter(Position = 0, Mandatory = $true)]
        [string]$Url,

        [Parameter(Position = 1)]
        [string]$License = "69a534f31ea7fc674d035665"
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


# Create a venv for the current folder
function mkvenv {
    C:\python312\python.exe -m venv .\venv
}

Set-Alias yt Get-YTTranscript

function Remove-ImageBackground {
    param (
        [Parameter(Mandatory=$true)]
        [string]$APIKey,

        [Parameter(Mandatory=$true)]
        [string]$PathToFile,

        [Parameter(Mandatory=$true)]
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

set-alias rmbg Remove-ImageBackground

function Set-WindowTitle {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    $host.UI.RawUI.WindowTitle = $Title
}
Set-Alias swt Set-WindowTitle

$__profileStart.Stop()
Write-Host ("Profile loaded in {0:N0} ms" -f $__profileStart.Elapsed.TotalMilliseconds) -ForegroundColor DarkGray
Remove-Variable __profileStart -ErrorAction SilentlyContinue
