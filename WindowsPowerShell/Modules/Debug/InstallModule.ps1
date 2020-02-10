param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Debug"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Debug.psd1" "$TargetDir\Debug.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Debug.psm1" "$TargetDir\Debug.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Debug.psm1"
		RemoveIfExisting "$TargetDir\Debug.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}