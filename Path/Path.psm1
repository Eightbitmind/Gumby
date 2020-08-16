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

	# a: Position after the last separator (if any)
	# b: Position of the last dot (if any)

	# "p"
	#  0
	#  a
	# b

	# "p.q"
	#  012
	#  a
	#   b

	# "p.q.r"
	#  01234
	#  a
	#     b

	# "p\q"
	#  012
	#    a
	# b

	# "p.q\r"
	#  01234
	#      a
	#   b

	# "p\q.r\s.t.u"
	#  01234567890
	#        a
	#           b

	[int] $a = $Path.LastIndexOf((PathSeparator))

	if ($a -lt 0) { $a = 0 } else { ++$a }

	if ($a -ge $Path.Length) { return "" }

	[int] $b = $Path.LastIndexOf('.')

	if ($b -lt $a) {
		return $Path.Substring($a)
	} else {
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

function PathAsUri($Path) {
	return "file:$($Path.Replace('\', '/'))"
}

<#
.SYNOPSIS
Gets a relative path.

.DESCRIPTION
The function returns a relative path which, when appended to the base directory, results in the
identifies the same element as the target path.

.PARAMETER BaseDirectory
Absolute path of base directory.

.PARAMETER TargetPath
Absolute target path to make relative with respect to base directory.

.OUTPUTS
Relative path.
#>
function PathGetRelative([string] $BaseDirectory, [string] $TargetPath) {
	# On modern .NET framework versions, this should get replaced with
	# System.IO.Path.GetRelativePath()

	$baseParts = $BaseDirectory.Split(@('/', '\'), ([System.StringSplitOptions]::RemoveEmptyEntries))
	if ($baseParts.Count -eq 0) { return $TargetPath }

	$targetPathParts = $TargetPath.Split(@('/', '\'), ([System.StringSplitOptions]::RemoveEmptyEntries))
	if ($targetPathParts.Count -eq 0) { return ("/.." * $basePArts.Count).Substring(1) }

	$relativePath = [System.Text.StringBuilder]::new();

	$lastCommon = 0
	if ($baseParts[$lastCommon] -ieq $targetPathParts[$lastCommon]) {
		while ($lastCommon + 1 -lt [Math]::Min($baseParts.Count, $targetPathParts.Count)) {
			if ($baseParts[$lastCommon + 1] -ine $targetPathParts[$lastCommon + 1]) { break }
			++$lastCommon
		}
	}

	# we could as well increment
	for ($i = $baseParts.Count - 1; $i -gt $lastCommon; --$i) { [void]$relativePath.Append('../') }

	for ($i = $lastCommon + 1; $i -lt $targetPathParts.Count; ++$i) { [void]$relativePath.Append($targetPathParts[$i]).Append('/') }

	if ($relativePath.Length -gt 0) {
		return $relativePath.ToString(0, $relativePath.Length - 1)
	} else {
		return ""
	}
}
