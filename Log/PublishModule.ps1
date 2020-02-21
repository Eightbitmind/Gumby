using module File
using module Gumby.Path
using module Gumby.String

param($NuGetApiKey)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$Macros = Import-PowerShellDataFile "$PSScriptRoot\PublishMacros.psd1"
$PublishName = PathFileBaseName $Macros.RootModule
$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\$PublishName"

try {
	EnsureEmptyDir $StagingDir
	ExpandFile "$PSScriptRoot\Log.psd1t" "$PSScriptRoot\PublishMacros.psd1" "$StagingDir\$PublishName.psd1"
	Copy-Item "$PSScriptRoot\Log.psm1" "$StagingDir\$PublishName.psm1"
	Publish-Module -NuGetApiKey $NuGetApiKey -Path $StagingDir
} finally {
	if (TestPath $StagingDir) {Remove-Item -Recurse -Force $StagingDir}
}
