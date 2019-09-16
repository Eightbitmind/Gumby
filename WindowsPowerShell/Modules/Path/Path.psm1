<#
.SYNOPSIS
Normalizes a path.

.PARAMETER Path
Path to normalize.

.OUTPUTS
Normalized path.
#>
function PathNormalize([string] $Path) {
	return $path.Replace('/', '\')
}

<#
.SYNOPSIS
Gets the path separator character for platform the function is running on.

.OUTPUTS
Path separator.
#>
function PathSeparator() { return '\' }

<#
.SYNOPSIS
Gets a list of common path separator characters.

.OUTPUTS
List of common path separator characters.
#>
function PathSeparators() { return '/', '\' }

<#
.SYNOPSIS
Extracts the base name part of a file path.

.PARAMETER Path
Path to extract base name part from.

.OUTPUTS
Base name part.
#>
function PathFileBaseName([string] $Path) {
	[int] $a = $Path.LastIndexOf((PathSeparator))

	if ($a -lt 0) { $a = 0 } else { ++$a }

	if ($a -ge $Path.Length) { return "" }

	[int] $b = $Path.IndexOf('.', $a)

	if ($b -lt 0) {
		# "a\b" -> "b"
		return $Path.Substring($a)
	} else {
		# "a\b.c" -> "b"
		return $Path.Substring($a, $b - $a)
	}
}

<#
.SYNOPSIS
Joins file name parts into a path.

.PARAMETER Directories
Directory parts.

.PARAMETER BaseName
Base name part.

.PARAMETER Extension
Extension part.

.OUTPUTS
Joined path.
#>
function PathJoin([string[]]$Directories, [string] $BaseName, [string] $Extension) {
	$sb = [Text.StringBuilder]::new()

	foreach ($dir in $Directories) {
		$sb.Append($dir.Trim((PathSeparators))).Append((PathSeparator)) | Out-Null
	}

	$sb.Append($BaseName) | Out-Null

	if (![string]::IsNullOrEmpty($Extension)) {
		if ($Extension.StartsWith('.')) {
			$sb.Append($Extension) | Out-Null
		} else {
			$sb.Append('.').Append($Extension) | Out-Null
		}
	}

	return $sb.ToString()
}
