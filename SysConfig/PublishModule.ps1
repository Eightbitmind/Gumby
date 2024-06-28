using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.SysConfig"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\SysConfig.psd1" "$StagingDir\Gumby.SysConfig.psd1"
	Copy-Item "$PSScriptRoot\SysConfig.psm1" "$StagingDir\Gumby.SysConfig.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
