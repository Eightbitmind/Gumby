param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\AEulitzEverywhere"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\AEulitzEverywhere.psd1" "$TargetDir\AEulitzEverywhere.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\AEulitzEverywhere.psm1" "$TargetDir\AEulitzEverywhere.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\AEulitzEverywhere.psm1"
		RemoveFileIfExisting "$TargetDir\AEulitzEverywhere.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
