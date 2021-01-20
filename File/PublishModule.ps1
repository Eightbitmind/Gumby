using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.File"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\File.psd1" "$StagingDir\Gumby.File.psd1"
	Copy-Item "$PSScriptRoot\File.psm1" "$StagingDir\Gumby.File.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
