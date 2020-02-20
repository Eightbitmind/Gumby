using module File
using module Gumby.Path
using module Gumby.String

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$Macros = Import-PowerShellDataFile "$PSScriptRoot\PublishMacros.psd1"
$PublishName = PathFileBaseName $Macros.RootModule
$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\$PublishName"
EnsureEmptyDir $StagingDir
ExpandFile "$PSScriptRoot\Math.psd1t" "$PSScriptRoot\PublishMacros.psd1" "$StagingDir\$PublishName.psd1"
Copy-Item "$PSScriptRoot\Math.psm1" "$StagingDir\$PublishName.psm1"
