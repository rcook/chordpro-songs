#Requires -Version 5
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string] $ConfigPath,
    [Parameter(Mandatory = $false, Position = 0, ValueFromRemainingArguments = $true)]
    [object[]] $Arguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$chordProPath = Resolve-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath ChordPro.ORG\ChordPro\chordpro.exe)

$previewerPath = $null

if (-not $previewerPath) {
    $temp = Join-Path -Path $env:ProgramFiles -ChildPath Google\Chrome\Application\chrome.exe
    if (Test-Path -Path $temp) {
        $previewerPath = Resolve-Path -Path $temp
    }
}

if (-not $previewerPath) {
    $temp = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath Google\Chrome\Application\chrome.exe
    if (Test-Path -Path $temp) {
        $previewerPath = Resolve-Path -Path $temp
    }
}

if ($ConfigPath) {
    $ConfigPath = Resolve-Path -Path $ConfigPath
}

if (-not $ConfigPath) {
    $temp = Join-Path -Path $PSScriptRoot -ChildPath chordpro-big.json
    if (Test-Path -Path $temp) {
        $ConfigPath = Resolve-Path -Path $temp
    }
}

$commonArgs = @('--strict')

foreach ($arg in $Arguments) {
    $inputPath = Resolve-Path -Path $arg
    $item = Get-Item -Path $inputPath
    $outputPath = Join-Path -Path $item.DirectoryName -ChildPath "$($item.BaseName).pdf"

    $allArgs = @()
    $allArgs += $commonArgs
    $allArgs += @($inputPath)
    if ($ConfigPath) {
        $allArgs += @('--config', $ConfigPath)
    }
    $allArgs += @('--output', $outputPath)

    & $chordProPath $allArgs
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Failed to render $inputPath"
    }

    if (-not $previewerPath) {
        & $outputPath
    } else {
        & $previewerPath $outputPath
    }
}
