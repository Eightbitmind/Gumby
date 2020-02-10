param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\ScrollView"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\ScrollView.psd1" "$TargetDir\ScrollView.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\ScrollView.psm1" "$TargetDir\ScrollView.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\ScrollView.psm1"
		RemoveIfExisting "$TargetDir\ScrollView.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}