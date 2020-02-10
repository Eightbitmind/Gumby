param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Navigate"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Navigate.psd1" "$TargetDir\Navigate.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Navigate.psm1" "$TargetDir\Navigate.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Navigate.psm1"
		RemoveIfExisting "$TargetDir\Navigate.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}