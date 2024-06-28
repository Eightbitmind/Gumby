using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Net"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Net.psd1" "$StagingDir\Gumby.Net.psd1"
	Copy-Item "$PSScriptRoot\Net.psm1" "$StagingDir\Gumby.Net.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
