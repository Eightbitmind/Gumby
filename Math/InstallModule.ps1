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
		MakeDirIfNotExisting "$TargetDir"
		ExpandFile "$PSScriptRoot\Math.psd1t" "$PSScriptRoot\InstallMacros.psd1" "$TargetDir\$InstallName.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psm1" "$TargetDir\$InstallName.psm1"
		break
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\$InstallName.psm1"
		RemoveFileIfExisting "$TargetDir\$InstallName.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
		break
	}
}
