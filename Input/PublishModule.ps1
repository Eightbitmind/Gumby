using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Input"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Input.psd1" "$StagingDir\Gumby.Input.psd1"
	Copy-Item "$PSScriptRoot\Input.psm1" "$StagingDir\Gumby.Input.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
