using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.CmdHistory"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\CmdHistory.psd1" "$StagingDir\Gumby.CmdHistory.psd1"
	Copy-Item "$PSScriptRoot\CmdHistory.psm1" "$StagingDir\Gumby.CmdHistory.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
