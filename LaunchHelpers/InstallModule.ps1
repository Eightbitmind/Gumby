param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\LaunchHelpers"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\LaunchHelpers.psd1" "$TargetDir\LaunchHelpers.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\LaunchHelpers.psm1" "$TargetDir\LaunchHelpers.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\LaunchHelpers.psm1"
		RemoveFileIfExisting "$TargetDir\LaunchHelpers.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
