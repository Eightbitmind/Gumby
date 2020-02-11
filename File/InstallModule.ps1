param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\File"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\File.psd1" "$TargetDir\File.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\File.psm1" "$TargetDir\File.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\File.psm1"
		RemoveFileIfExisting "$TargetDir\File.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
