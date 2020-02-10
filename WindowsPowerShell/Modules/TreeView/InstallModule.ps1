param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\TreeView"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TreeView.psd1" "$TargetDir\TreeView.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TreeView.psm1" "$TargetDir\TreeView.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\TreeView.psm1"
		RemoveIfExisting "$TargetDir\TreeView.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}