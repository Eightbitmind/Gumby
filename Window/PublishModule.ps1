using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Window"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Window.psd1" "$StagingDir\Gumby.Window.psd1"
	Copy-Item "$PSScriptRoot\Window.psm1" "$StagingDir\Gumby.Window.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
