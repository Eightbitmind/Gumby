using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Math"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Math.psd1" "$StagingDir\Gumby.Math.psd1"
	Copy-Item "$PSScriptRoot\Math.psm1" "$StagingDir\Gumby.Math.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
