param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\Search"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Search.psd1" "$TargetDir\Search.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Search.psm1" "$TargetDir\Search.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Search.psm1"
		RemoveIfExisting "$TargetDir\Search.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}