using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Search"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Search.psd1" "$StagingDir\Gumby.Search.psd1"
	Copy-Item "$PSScriptRoot\Search.psm1" "$StagingDir\Gumby.Search.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
