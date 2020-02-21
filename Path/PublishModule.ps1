using module File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Path"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Path.psd1" "$StagingDir\Gumby.Path.psd1"
	Copy-Item "$PSScriptRoot\Path.psm1" "$StagingDir\Gumby.Path.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
