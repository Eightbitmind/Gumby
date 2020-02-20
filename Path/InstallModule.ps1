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
		Write-Warning "'Path' module should be installed from the PS Gallery."

		# MakeDirIfNotExisting "$TargetDir"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Path.psd1" "$TargetDir\Path.psd1"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Path.psm1" "$TargetDir\Path.psm1"
	}
	"Uninstall" {
		Write-Warning "'Path' module should be installed from the PS Gallery."

		# RemoveFileIfExisting "$TargetDir\Path.psm1"
		# RemoveFileIfExisting "$TargetDir\Path.psd1"
		# RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
