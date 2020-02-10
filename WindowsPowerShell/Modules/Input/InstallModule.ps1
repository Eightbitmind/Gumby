param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Input"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Input.psd1" "$TargetDir\Input.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Input.psm1" "$TargetDir\Input.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Input.psm1"
		RemoveIfExisting "$TargetDir\Input.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}