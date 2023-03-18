param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\CmdHistory"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\CmdHistory.psd1" "$TargetDir\CmdHistory.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\CmdHistory.psm1" "$TargetDir\CmdHistory.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\CmdHistory.psm1"
		RemoveFileIfExisting "$TargetDir\CmdHistory.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
