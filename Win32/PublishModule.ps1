using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Win32"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Win32.psd1" "$StagingDir\Gumby.Win32.psd1"
	Copy-Item "$PSScriptRoot\Win32.psm1" "$StagingDir\Gumby.Win32.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
