using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Navigate"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Navigate.psd1" "$StagingDir\Gumby.Navigate.psd1"
	Copy-Item "$PSScriptRoot\Navigate.psm1" "$StagingDir\Gumby.Navigate.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
