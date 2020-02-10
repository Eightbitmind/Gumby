param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string]
	$TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

# dot-source install helper methods
. "$PSScriptRoot\..\InstallUtils.ps1"

$TargetDir = "$TargetRootDir\SysConfig"

switch ($Action) {
	"Install" {
		MakeDirIfNotExisting $TargetDir
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\SysConfig.psd1" "$TargetDir\SysConfig.psd1"
		CopyIfTargetNotExistingOrIsOlder "$PSScriptRoot\SysConfig.psm1" "$TargetDir\SysConfig.psm1"
	}

	"Uninstall" {
		RemoveIfExisting "$TargetDir\SysConfig.psm1"
		RemoveIfExisting "$TargetDir\SysConfig.psd1"
		RemoveDirIfExistingAndNotEmpty $TargetDir
	}
}