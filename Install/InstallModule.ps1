param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Install"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Install.psd1" "$TargetDir\Install.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Install.psm1" "$TargetDir\Install.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Install.psm1"
		RemoveFileIfExisting "$TargetDir\Install.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
