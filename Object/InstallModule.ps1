param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Object"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Object.psd1" "$TargetDir\Object.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Object.psm1" "$TargetDir\Object.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Object.psm1"
		RemoveFileIfExisting "$TargetDir\Object.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
