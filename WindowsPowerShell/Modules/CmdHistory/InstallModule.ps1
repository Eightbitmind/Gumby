param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\CmdHistory"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\CmdHistory.psd1" "$TargetDir\CmdHistory.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\CmdHistory.psm1" "$TargetDir\CmdHistory.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\CmdHistory.psm1"
		RemoveIfExisting "$TargetDir\CmdHistory.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}