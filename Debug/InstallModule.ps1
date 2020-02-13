param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Debug"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Debug.psd1" "$TargetDir\Debug.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Debug.psm1" "$TargetDir\Debug.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Debug.psm1"
		RemoveFileIfExisting "$TargetDir\Debug.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
