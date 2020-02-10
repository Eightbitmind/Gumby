param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\File"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\File.psd1" "$TargetDir\File.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\File.psm1" "$TargetDir\File.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\File.psm1"
		RemoveIfExisting "$TargetDir\File.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}