param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\ScrollView"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\ScrollView.psd1" "$TargetDir\ScrollView.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\ScrollView.psm1" "$TargetDir\ScrollView.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\ScrollView.psm1"
		RemoveFileIfExisting "$TargetDir\ScrollView.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
