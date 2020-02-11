param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\TreeView"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TreeView.psd1" "$TargetDir\TreeView.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TreeView.psm1" "$TargetDir\TreeView.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\TreeView.psm1"
		RemoveFileIfExisting "$TargetDir\TreeView.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}