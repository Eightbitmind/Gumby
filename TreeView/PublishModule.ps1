using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.TreeView"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\TreeView.psd1" "$StagingDir\Gumby.TreeView.psd1"
	Copy-Item "$PSScriptRoot\TreeView.psm1" "$StagingDir\Gumby.TreeView.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
