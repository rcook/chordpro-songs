#Requires -Version 5
[CmdletBinding()]
param(
    [Parameter(Mandatory = $false, Position = 0, ValueFromRemainingArguments = $true)]
    [object[]] $Arguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$chordProPath = Resolve-Path -Path (Join-Path -Path $env:ProgramFiles -ChildPath ChordPro.ORG\ChordPro\chordpro.exe)
$previewerPath = 'C:\Program Files\Google\Chrome\Application\chrome.exe'

foreach ($arg in $Arguments) {
    $inputPath = Resolve-Path -Path $arg
    $item = Get-Item -Path $inputPath
    $outputPath = Join-Path -Path $item.DirectoryName -ChildPath "$($item.BaseName).pdf"

    & $chordProPath $inputPath --output $outputPath
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
