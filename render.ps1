#Requires -Version 5
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromRemainingArguments = $true)]
    [object[]] $Arguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$previewerPath = $null

if (-not $previewerPath) {
    $temp = (Join-Path -Path $env:ProgramFiles -ChildPath Google\Chrome\Application\chrome.exe)
    if (Test-Path -Path $temp) {
        $previewerPath = Resolve-Path -Path $temp
    }
}

if (-not $previewerPath) {
    $temp = (Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath Google\Chrome\Application\chrome.exe)
    if (Test-Path -Path $temp) {
        $previewerPath = Resolve-Path -Path $temp
    }
}

$chordProPath = Resolve-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath ChordPro.ORG\ChordPro\chordpro.exe)

$configPath = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath chordpro.json)

foreach ($arg in $Arguments) {
    $inputPath = Resolve-Path -Path $arg
    $item = Get-Item -Path $inputPath
    $outputPath = Join-Path -Path $item.DirectoryName -ChildPath "$($item.BaseName).pdf"

    & $chordProPath $inputPath --config $configPath --output $outputPath
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        throw "Failed to render $inputPath"
    }

    if ($null -eq $previewerPath) {
        & $outputPath
    } else {
        & $previewerPath $outputPath
    }
}
