param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\ListBox"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\ListBox.psd1" "$TargetDir\ListBox.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\ListBox.psm1" "$TargetDir\ListBox.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\ListBox.psm1"
		RemoveFileIfExisting "$TargetDir\ListBox.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
