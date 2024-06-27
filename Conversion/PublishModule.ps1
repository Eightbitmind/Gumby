using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Conversion"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Conversion.psd1" "$StagingDir\Gumby.Conversion.psd1"
	Copy-Item "$PSScriptRoot\Conversion.psm1" "$StagingDir\Gumby.Conversion.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
