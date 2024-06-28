using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.ListBox"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\ListBox.psd1" "$StagingDir\Gumby.ListBox.psd1"
	Copy-Item "$PSScriptRoot\ListBox.psm1" "$StagingDir\Gumby.ListBox.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
