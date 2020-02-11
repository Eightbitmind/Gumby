param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\TextBuffer"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TextBuffer.psd1" "$TargetDir\TextBuffer.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TextBuffer.psm1" "$TargetDir\TextBuffer.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\TextBuffer.psm1"
		RemoveFileIfExisting "$TargetDir\TextBuffer.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
