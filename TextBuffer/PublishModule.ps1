using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.TextBuffer"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\TextBuffer.psd1" "$StagingDir\Gumby.TextBuffer.psd1"
	Copy-Item "$PSScriptRoot\TextBuffer.psm1" "$StagingDir\Gumby.TextBuffer.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
