param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\PowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Crypto"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting "$TargetDir"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Crypto.psd1" "$TargetDir\Crypto.psd1"
		CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Crypto.psm1" "$TargetDir\Crypto.psm1"
	}
	"Uninstall" {
		RemoveFileIfExisting "$TargetDir\Crypto.psm1"
		RemoveFileIfExisting "$TargetDir\Crypto.psd1"
		RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
