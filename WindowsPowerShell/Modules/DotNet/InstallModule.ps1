param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\DotNet"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\DotNet.psd1" "$TargetDir\DotNet.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\DotNet.psm1" "$TargetDir\DotNet.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\DotNet.psm1"
		RemoveIfExisting "$TargetDir\DotNet.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}