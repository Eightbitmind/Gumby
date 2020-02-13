param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\DirHistory"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\DirHistory.psd1" "$TargetDir\DirHistory.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\DirHistory.psm1" "$TargetDir\DirHistory.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\DirHistory.psm1"
		RemoveFileIfExisting "$TargetDir\DirHistory.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
