param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

foreach ($installScript in (Get-ChildItem -Recurse -Include "InstallModule.ps1")) {
	& $installScript -Action $Action -TargetRootDir $TargetRootDir
}
