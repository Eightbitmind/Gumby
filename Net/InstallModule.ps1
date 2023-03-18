param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Net"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Net.psd1" "$TargetDir\Net.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Net.psm1" "$TargetDir\Net.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Net.psm1"
		RemoveFileIfExisting "$TargetDir\Net.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
