param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\TestUtils"

switch ($Action) {
	"Install" {
		Write-Warning "'TestUtils' module should be installed from the PS Gallery."

		# MakeDirIfNotExisting "$TargetDir"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psd1" "$TargetDir\TestUtils.psd1"
		# CopyFileIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psm1" "$TargetDir\TestUtils.psm1"
	}
	"Uninstall" {
		Write-Warning "'TestUtils' module should be installed from the PS Gallery."

		# RemoveFileIfExisting "$TargetDir\TestUtils.psm1"
		# RemoveFileIfExisting "$TargetDir\TestUtils.psd1"
		# RemoveDirIfExistingAndNotEmpty "$TargetDir"
	}
}
