function Assert($Condition, $Message = "assertion failed") {
	if (!$Condition) { throw $Message }
}

<#
.SYNOPSIS
If necessary, abbreviates a string by replacing part of it with the ellipsis.

.PARAMETER Text
String to abbreviate.

.PARAMETER MaxLength
Maximum length of abbreviated string.

.PARAMETER Ellipsis
Ellipsis string (optional, defaults to "...").

.OUTPUTS
Abbreviated string.
#>
function Abbreviate([string] $Text, [uint32] $MaxLength, [string] $Ellipsis = "...") {
	if ($Text.Length -le $MaxLength) {
		return $Text
	} else {
		# Assert ($MaxLength -gt $Ellipsis.length)
		# PS converts floats to ints by rounding, not by truncation of the fractional part

		#   01234567890123456789
		#   abcdefghij
		#
		#     p    q
		#     |    |
		# l   v    v		p	q
		# 9	abc... hij		3	7	x = (9-3)/2 = 3		p = round(x, 0, 1)	q = l - trunc(x)
		# 8	abc... ij		3	8	x = (8-3)/2 = 2.5 	p = round(x, 0, 1)	q = l - trunc(x)
		# 7	ab...  ij		2	8	x = (7-3)/2 = 2		p = round(x, 0, 1)	q = l - trunc(x)
		# 6	ab...  j		2	9	x = (6-3)/2 = 1.5	p = round(x, 0, 1)	q = l - trunc(x)
		# 5	a...   j		1	9	x = (5-3)/2 = 1		p = round(x, 0, 1)	q = l - trunc(x)
		# 4 a...			1	10	x = (4-3)/2 = 0.5

		$x = ($MaxLength - $Ellipsis.Length ) / 2
		return $Text.Substring(0, [Math]::Round($x, 0, 1)) + $Ellipsis + $Text.Substring($Text.Length - [Math]::Truncate($x))
	}
}

<#
.SYNOPSIS
Ensures a string has the specified length.

.PARAMETER Text
Text to ensure length of.

.PARAMETER Length
Desired length of the text.

.PARAMETER FillChar
Character to pad the text with if it is shorter than the specified length (optional, defaults to
' ').

.OUTPUTS
Text with the specified length.
#>
function EnsureStringLength([string] $Text, [int] $Length, [string] $FillChar = ' ') {
	if ($Text.Length -lt $Length) {
		return $Text.PadRight($Length, $FillChar)
	} else {
		return $Text.Substring(0, $Length)
	}
}

<#
.SYNOPSIS
Normalizes a string by removing whitespace characters from its beginning and end, and by reducing
whitespace character sequences in the middle of the string to a single whitespace character.

.PARAMETER Text
String to normalize.

.OUTPUTS
Normalized string.
#>
function NormalizeWhitespace([string] $Text) {
	$([regex] '\s+').Replace($Text.Trim().Replace('`r`n', ' ').Replace('`r', ' ').Replace('`n', ' '), ' ')
}

function SpaceWords([string[]] $Words, [int] $Width, [string] $SpacingChar = ' ') {
	# The code below is a sketch that only works correctly for 2 words. A proper version needs
	# to provide heterogenous spacing lengths according to the integer divisibility of the
	# total spacing length.

	Assert ($Words.Count -ge 2)
	Assert ($SpacingChar.Length -eq 1)

	$totalSpacingLength = $Width
	foreach ($word in $Words) { $totalSpacingLength -= $word.Length }

	Assert ($totalSpacingLength -ge 0)

	$spacingLength = $totalSpacingLength / ($Words.Count - 1)

	$sb = [Text.StringBuilder]::new($Width)
	for ($i = 0; $i -lt $Words.Count; ++$i) {
		$sb.Append($Words[$i]) | Out-Null
		if ($i -lt $Words.Count - 1) { $sb.Append($SpacingChar * $spacingLength) | Out-Null }
	}

	return $sb.ToString()
}

<#
.SYNOPSIS
Splits a string of comma-separated, quoted sub-strings (e.g. a line from a CSV file).

.PARAMETER Line
String to split.

.OUTPUTS
List of substrings.
#>
function SplitCSVLine([string] $Line) {
	[bool] $inString = $false;

	$fields = @()
	$accu = ""

	for ($i = 0; $i -lt $Line.Length; $i++) {
		switch ($Line[$i]) {
			#{$_ -eq '"' -and -not $inString} {$inString = $true; break}
			#{$_ -eq '"' -and $inString}      {$inString = $false; break}
			{$_ -eq '"'} {$inString = !$inString; break}
			{($_ -in ',', ';') -and -not $inString} {$fields += $accu; $accu = ""; break}
			default {$accu += $_}
		}
	}

	$fields += $accu
	return $fields
}
