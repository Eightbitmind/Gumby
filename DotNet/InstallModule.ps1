param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\DotNet"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\DotNet.psd1" "$TargetDir\DotNet.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\DotNet.psm1" "$TargetDir\DotNet.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\DotNet.psm1"
		RemoveFileIfExisting "$TargetDir\DotNet.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
