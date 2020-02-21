using module File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\GumbyString"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\String.psd1" "$StagingDir\Gumby.String.psd1"
	Copy-Item "$PSScriptRoot\String.psm1" "$StagingDir\Gumby.String.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (TestPath $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
