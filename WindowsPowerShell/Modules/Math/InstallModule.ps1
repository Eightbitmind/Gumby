param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Math"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psd1" "$TargetDir\Math.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psm1" "$TargetDir\Math.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Math.psm1"
		RemoveIfExisting "$TargetDir\Math.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}