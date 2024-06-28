using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Object"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Object.psd1" "$StagingDir\Gumby.Object.psd1"
	Copy-Item "$PSScriptRoot\Object.psm1" "$StagingDir\Gumby.Object.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
