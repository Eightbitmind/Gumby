param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Input"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Input.psd1" "$TargetDir\Input.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Input.psm1" "$TargetDir\Input.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Input.psm1"
		RemoveFileIfExisting "$TargetDir\Input.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
