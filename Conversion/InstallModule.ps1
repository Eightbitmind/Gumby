param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Conversion"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Conversion.psd1" "$TargetDir\Conversion.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Conversion.psm1" "$TargetDir\Conversion.psm1"
		break
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Conversion.psm1"
		RemoveFileIfExisting "$TargetDir\Conversion.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
		break
	}
}
