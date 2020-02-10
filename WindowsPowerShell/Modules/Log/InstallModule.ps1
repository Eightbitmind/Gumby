param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Log"

switch ($Action) {
	"Install" {
		Write-Warning "'Log' module should be installed from PSGallery"

		# MakeDirIfNotExisting $TargetDir
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Log.psd1" "$TargetDir\Log.psd1"
		# CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Log.psm1" "$TargetDir\Log.psm1"
	}

	"Uninstall" {
		Write-Warning "'Log' module should be installed from PSGallery"

		# RemoveIfExisting "$TargetDir\Log.psm1"
		# RemoveIfExisting "$TargetDir\Log.psd1"
		# RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}