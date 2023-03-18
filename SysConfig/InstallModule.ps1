param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\SysConfig"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\SysConfig.psd1" "$TargetDir\SysConfig.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\SysConfig.psm1" "$TargetDir\SysConfig.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\SysConfig.psm1"
		RemoveFileIfExisting "$TargetDir\SysConfig.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
