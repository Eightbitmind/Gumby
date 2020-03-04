using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Install"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Install.psd1" "$StagingDir\Gumby.Install.psd1"
	Copy-Item "$PSScriptRoot\Install.psm1" "$StagingDir\Gumby.Install.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
