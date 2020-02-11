param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Navigate"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Navigate.psd1" "$TargetDir\Navigate.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Navigate.psm1" "$TargetDir\Navigate.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Navigate.psm1"
		RemoveFileIfExisting "$TargetDir\Navigate.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
