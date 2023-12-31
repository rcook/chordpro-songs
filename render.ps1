#Requires -Version 5
[CmdletBinding()]
param(
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

$configPath = $null

if (-not $configPath) {
    $temp = Join-Path -Path $PSScriptRoot -ChildPath chordpro-big.json
    if (Test-Path -Path $temp) {
        $configPath = Resolve-Path -Path $temp
    }
}

foreach ($arg in $Arguments) {
    $inputPath = Resolve-Path -Path $arg
    $item = Get-Item -Path $inputPath
    $outputPath = Join-Path -Path $item.DirectoryName -ChildPath "$($item.BaseName).pdf"

    if (-not $configPath) {
        & $chordProPath $inputPath --output $outputPath
    } else {
        & $chordProPath $inputPath --config $configPath --output $outputPath
    }
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
