param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$HOME\OneDrive\Documents\WindowsPowerShell\Modules"
)

foreach ($script in (Get-ChildItem -Recurse -Include "InstallModule.ps1")) {
	& $script -Action $Action -TargetRootDir $TargetRootDir
}
