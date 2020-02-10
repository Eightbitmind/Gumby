param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\FSShortcuts"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\FSShortcuts.psd1" "$TargetDir\FSShortcuts.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\FSShortcuts.psm1" "$TargetDir\FSShortcuts.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\FSShortcuts.psm1"
		RemoveIfExisting "$TargetDir\FSShortcuts.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}