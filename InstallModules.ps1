param(
	[ValidateSet("Install", "Uninstall")]
	$Action = "Install",

	[string] $TargetRootDir = "$([System.Environment]::GetFolderPath(`"MyDocuments`"))\WindowsPowerShell\Modules"
)

foreach ($script in (Get-ChildItem -Recurse -Include "InstallModule.ps1")) {
	& $script -Action $Action -TargetRootDir $TargetRootDir
}
