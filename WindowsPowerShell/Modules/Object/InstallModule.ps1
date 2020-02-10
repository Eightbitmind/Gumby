param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Object"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Object.psd1" "$TargetDir\Object.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Object.psm1" "$TargetDir\Object.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Object.psm1"
		RemoveIfExisting "$TargetDir\Object.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}