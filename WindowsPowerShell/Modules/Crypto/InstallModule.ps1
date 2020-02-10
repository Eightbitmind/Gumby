param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Crypto"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Crypto.psd1" "$TargetDir\Crypto.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Crypto.psm1" "$TargetDir\Crypto.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Crypto.psm1"
		RemoveIfExisting "$TargetDir\Crypto.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}