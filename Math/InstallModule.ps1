param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Math"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psd1" "$TargetDir\Math.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Math.psm1" "$TargetDir\Math.psm1"
		break
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Math.psm1"
		RemoveFileIfExisting "$TargetDir\Math.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
		break
	}
}
