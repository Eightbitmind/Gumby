using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.DotNet"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\DotNet.psd1" "$StagingDir\Gumby.DotNet.psd1"
	Copy-Item "$PSScriptRoot\DotNet.psm1" "$StagingDir\Gumby.DotNet.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
