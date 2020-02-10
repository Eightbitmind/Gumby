param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\ListBox"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\ListBox.psd1" "$TargetDir\ListBox.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\ListBox.psm1" "$TargetDir\ListBox.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\ListBox.psm1"
		RemoveIfExisting "$TargetDir\ListBox.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}