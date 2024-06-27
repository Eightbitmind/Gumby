using module Gumby.File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\Gumby.Crypto"

try {
	EnsureEmptyDir $StagingDir
	Copy-Item "$PSScriptRoot\Crypto.psd1" "$StagingDir\Gumby.Crypto.psd1"
	Copy-Item "$PSScriptRoot\Crypto.psm1" "$StagingDir\Gumby.Crypto.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (Test-Path $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
