param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Search"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Search.psd1" "$TargetDir\Search.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Search.psm1" "$TargetDir\Search.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Search.psm1"
		RemoveFileIfExisting "$TargetDir\Search.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
