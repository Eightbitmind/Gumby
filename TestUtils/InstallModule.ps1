param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$Macros = Import-PowerShellDataFile "$PSScriptRoot\InstallMacros.psd1"
$InstallName = PathFileBaseName $Macros.RootModule

$TargetDir = "$TargetRootDir\$InstallName"

switch ($Action) {
	"Install" {
		Write-Warning "'TestUtils' module should be installed from the PS Gallery."

		# MakeDirIfNotExisting "$TargetDir"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psd1" "$TargetDir\TestUtils.psd1"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psm1" "$TargetDir\TestUtils.psm1"
	}
	"Uninstall" {
		Write-Warning "'TestUtils' module should be installed from the PS Gallery."

		# RemoveFileIfExisting "$TargetDir\TestUtils.psm1"
		# RemoveFileIfExisting "$TargetDir\TestUtils.psd1"
		# RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
