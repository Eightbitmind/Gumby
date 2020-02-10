param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\TextBuffer"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TextBuffer.psd1" "$TargetDir\TextBuffer.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TextBuffer.psm1" "$TargetDir\TextBuffer.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\TextBuffer.psm1"
		RemoveIfExisting "$TargetDir\TextBuffer.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}