using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.ScrollView"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\ScrollView.psd1" "$StagingDir\Gumby.ScrollView.psd1"
	Copy-Item "$PSScriptRoot\ScrollView.psm1" "$StagingDir\Gumby.ScrollView.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
