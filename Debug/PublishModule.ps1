using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Debug"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Debug.psd1" "$StagingDir\Gumby.Debug.psd1"
	Copy-Item "$PSScriptRoot\Debug.psm1" "$StagingDir\Gumby.Debug.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
