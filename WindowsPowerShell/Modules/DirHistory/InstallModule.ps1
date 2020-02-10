param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\DirHistory"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\DirHistory.psd1" "$TargetDir\DirHistory.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\DirHistory.psm1" "$TargetDir\DirHistory.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\DirHistory.psm1"
		RemoveIfExisting "$TargetDir\DirHistory.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}