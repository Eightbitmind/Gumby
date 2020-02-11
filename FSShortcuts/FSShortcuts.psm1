<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FssEnsureShortcutDrive($driveLetter, $path) {
	$substOut = &'subst'
	if ($substOut -eq $null -or !$substOut.Contains($driveLetter)) {
		subst $driveLetter $path
	}
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FssExpandShortcut($shortcutPath) {
	if (Test-Path "$shortcutPath\__ShortcutTarget.txt") {
		Invoke-Expression "`"$(Get-Content $shortcutPath\__ShortcutTarget.txt)`""
	} else {
		$shortcutPath
	}
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FssSetLocationIfShortcut() {
	if (Test-Path '__ShortcutTarget.txt') {
		Set-Location (FssExpandShortcut (pwd))
	}
}
