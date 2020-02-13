param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\FSShortcuts"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\FSShortcuts.psd1" "$TargetDir\FSShortcuts.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\FSShortcuts.psm1" "$TargetDir\FSShortcuts.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\FSShortcuts.psm1"
		RemoveFileIfExisting "$TargetDir\FSShortcuts.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
