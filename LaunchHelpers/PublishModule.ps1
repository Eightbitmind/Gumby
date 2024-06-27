using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.LaunchHelpers"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\LaunchHelpers.psd1" "$StagingDir\Gumby.LaunchHelpers.psd1"
	Copy-Item "$PSScriptRoot\LaunchHelpers.psm1" "$StagingDir\Gumby.LaunchHelpers.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
