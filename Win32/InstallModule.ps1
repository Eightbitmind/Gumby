param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Win32"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Win32.psd1" "$TargetDir\Win32.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Win32.psm1" "$TargetDir\Win32.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Win32.psm1"
		RemoveFileIfExisting "$TargetDir\Win32.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
