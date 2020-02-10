param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Net"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Net.psd1" "$TargetDir\Net.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Net.psm1" "$TargetDir\Net.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Net.psm1"
		RemoveIfExisting "$TargetDir\Net.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}