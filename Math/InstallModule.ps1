param(
	[ValidateSet("Action", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules",
)

# dot-source install helper methods
. "..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Math"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psd1" "$TargetDir\Math.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psm1" "$TargetDir\Math.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Math.psm1"
		RemoveFileIfExisting "$TargetDir\Math.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
