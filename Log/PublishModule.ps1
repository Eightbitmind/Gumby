using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Log"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Log.psd1" "$StagingDir\Gumby.Log.psd1"
	Copy-Item "$PSScriptRoot\Log.psm1" "$StagingDir\Gumby.Log.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
