using module File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Test"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\TestUtils.psd1" "$StagingDir\Gumby.Test.psd1"
	Copy-Item "$PSScriptRoot\TestUtils.psm1" "$StagingDir\Gumby.Test.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
