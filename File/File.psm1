<#
.SYNOPSIS
Copies a file, creating target directories if needed.

.PARAMETER Source
File to copy.

.PARAMETER Target
Path to copy the file to.
#>
function CopyFile($Source, $Target) {
	if (!(Test-Path $Source)) { throw "file '$Source' can't be found" }

	$targetPath = Split-Path -Path $Target
	if (!(Test-Path $targetPath)) { md $targetPath | Out-Null }
	Copy-Item $Source $Target
}

<#
.SYNOPSIS
Creates a symbolic link.

.PARAMETER Target
Target of the link being created.

.PARAMETER Link
Path of the link being created.
#>
function CreateSymbolicLink($Target, $Link) {
	[void](New-Item -Path $Link -ItemType SymbolicLink -Value $Target)
}

function IsSymbolicLink ($Item) {
	if ($Item -is [string]) { $Item = Get-Item $Item }
	return (($null -ne $Item.LinkType) -and ($Item.LinkType -eq 'SymbolicLink'))
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
filter IsNotDirectory {
	if($_.Attributes -ne [IO.FileAttributes]::Directory) { $_ }
}

<#
.SYNOPSIS
Sets the read-only property of an item.

.PARAMETER Path
Path of the item on which to set the read-only property.

.PARAMETER Value
Value of the read-only property.
#>
function SetReadOnly([string] $Path, [bool] $Value = $false) {
	Set-ItemProperty -Name IsReadOnly -Value $Value -Path $Path
}

<#
.SYNOPSIS
Like Test-Path, but with error messages suppressed.

.PARAMETER Path
Path to test.

.OUTPUTS
Boolean indicating whether the item identified by $Path exists.
#>
function TestPath2([string] $Path) {
	Test-Path -ErrorAction SilentlyContinue $Path
}
