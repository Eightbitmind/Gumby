param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\Win32"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Win32.psd1" "$TargetDir\Win32.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\Win32.psm1" "$TargetDir\Win32.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\Win32.psm1"
		RemoveIfExisting "$TargetDir\Win32.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}