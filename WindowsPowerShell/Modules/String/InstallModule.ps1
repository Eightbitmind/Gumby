param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\String"

switch ($Action) {
	"Install" {
		Write-Warning "'String' module should be installed from PSGallery"

		# MakeDirIfNotExisting $TargetDir
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\String.psd1" "$TargetDir\String.psd1"
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\String.psm1" "$TargetDir\String.psm1"
	}

	"Uninstall" {
		Write-Warning "'String' module should be installed from PSGallery"

		# RemoveIfExisting "$TargetDir\String.psm1"
		# RemoveIfExisting "$TargetDir\String.psd1"
		# RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}