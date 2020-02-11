param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Log"

switch ($Action) {
	"Install" {
		Write-Warning "'Log' module should be installed from the PS Gallery."

		# MakeDirIfNotExisting "$TargetDir"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Log.psd1" "$TargetDir\Log.psd1"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\Log.psm1" "$TargetDir\Log.psm1"
	}
	"Uninstall" {
		Write-Warning "'Log' module should be installed from the PS Gallery."

		# RemoveFileIfExisting "$TargetDir\Log.psm1"
		# RemoveFileIfExisting "$TargetDir\Log.psd1"
		# RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
