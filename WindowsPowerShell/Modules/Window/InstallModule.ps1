param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Window"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Window.psd1" "$TargetDir\Window.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Window.psm1" "$TargetDir\Window.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Window.psm1"
		RemoveIfExisting "$TargetDir\Window.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}