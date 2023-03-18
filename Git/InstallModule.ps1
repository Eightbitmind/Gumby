param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Git"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Git.psd1" "$TargetDir\Git.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Git.psm1" "$TargetDir\Git.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Git.psm1"
		RemoveFileIfExisting "$TargetDir\Git.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
