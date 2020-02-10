param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallModules.ps1"

$TargetDir = "$TargetRootDir\TestUtils"

switch ($Action) {
	"Install" {
		Write-Warning "'TestUtils' module should be installed from PSGallery"

		# MakeDirIfNotExisting $TargetDir
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psd1" "$TargetDir\TestUtils.psd1"
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\TestUtils.psm1" "$TargetDir\TestUtils.psm1"
	}

	"Uninstall" {
		Write-Warning "'TestUtils' module should be installed from PSGallery"

		# RemoveIfExisting "$TargetDir\TestUtils.psm1"
		# RemoveIfExisting "$TargetDir\TestUtils.psd1"
		# RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}