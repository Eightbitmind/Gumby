<#
.SYNOPSIS
	Values describing a text file encoding.
#>
enum TextFileEncoding {
	UTF8
	Unicode
	UTF32
	UTF7
	ASCII
}

# change to test publishing automation

<#
.SYNOPSIS
	Gets text file encoding.

.PARAMETER Path
	Path and name of the text file whose encoding is to be determined.

.OUTPUTS
	'TextFileEncoding' enum value describing the text file encoding.

.DESCRIPTION
	The Get-FileEncoding function determines encoding by looking at the Byte Order Mark (BOM).
	It assumes the specified file ('Path' parameter) is an existing, non-zero length file.
#>
function Get-TextFileEncoding ([string] $Path) {
	[byte[]] $bytes = Get-Content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path

	if ($bytes[0] -eq 0xef -and $bytes[1] -eq 0xbb -and $bytes[2] -eq 0xbf) {
		return [TextFileEncoding]::UTF8
	}
	elseif ($bytes[0] -eq 0xfe -and $bytes[1] -eq 0xff) {
		return [TextFileEncoding]::Unicode
	}
	elseif ($bytes[0] -eq 0 -and $bytes[1] -eq 0 -and $bytes[2] -eq 0xfe -and $bytes[3] -eq 0xff) {
		return [TextFileEncoding]::UTF32
	}
	elseif ($bytes[0] -eq 0x2b -and $bytes[1] -eq 0x2f -and $bytes[2] -eq 0x76) {
		return [TextFileEncoding]::UTF7
	}
	else {
		return [TextFileEncoding]::ASCII
	}
}

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

function IsDirectory($Path) {
	return (Test-Path -PathType Container $Path)
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
