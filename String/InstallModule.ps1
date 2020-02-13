param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\String"

switch ($Action) {
	"Install" {
		Write-Warning "'String' module should be installed from the PS Gallery."

		# MakeDirIfNotExisting "$TargetDir"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\String.psd1" "$TargetDir\String.psd1"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\String.psm1" "$TargetDir\String.psm1"
	}
	"Uninstall" {
		Write-Warning "'String' module should be installed from the PS Gallery."

		# RemoveFileIfExisting "$TargetDir\String.psm1"
		# RemoveFileIfExisting "$TargetDir\String.psd1"
		# RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
