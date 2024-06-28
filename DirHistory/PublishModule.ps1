using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.DirHistory"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\DirHistory.psd1" "$StagingDir\Gumby.DirHistory.psd1"
	Copy-Item "$PSScriptRoot\DirHistory.psm1" "$StagingDir\Gumby.DirHistory.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
