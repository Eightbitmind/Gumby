﻿using module Gumby.Debug

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
Expand macro references ('$MacroName') with macro values.

.PARAMETER Text
String containing macro references.

.PARAMETER Macros
Hashtable with macro names as keys and macro values as values.

.OUTPUTS
String in which macro references have been replaced with macro values.
#>
function ExpandMacros($Text, $Macros) {
	[regex] $macroPattern = '(?<!`)\$(?<MacroName>[a-zA-Z_]\w*)'
	return $macroPattern.Replace($Text, {
		param ($match)
		$macroName = $match.Groups['MacroName'].Value
		if ($Macros.ContainsKey($macroName)) {
			return $Macros[$macroName]
		} else {
			return $match.Value
		}
	})
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

<#
.SYNOPSIS
Integrates an array of names and an array of values into a hash table.

.PARAMETER Names
Array of names. The items therein become the hash table keys.

.PARAMETER Values
Array of values. The items therein become the hash table values.

.OUTPUTS
Hash table.
#>
function Zip($Names, $Values) {
	if ($Names.Length -ne $Values.Length) { throw "Number of names and values does not line up." }

	$hash = @{}

	for ($i = 0; $i -lt $Names.Length; $i++) {
		$hash.Add($Names[$i], $Values[$i])
	}

	return $hash
}

class TextArray {
	[void] SetText($lineIndex, $columnIndex, $text) {
		# ensure there are enough lines
		for ($i = $lineIndex - $this.lines.Count; $i -ge 0; --$i) {
			[void]($this.lines.Add([System.Text.StringBuilder]::new()))
		}

		$line = $this.lines[$lineIndex]

		if ($line.Length -le $columnIndex) {
			# append text
			[void]($line.Append(' ' * ($columnIndex - $line.Length)).Append($text))
		} else {
			# (partially) overwrite text

			#           012
			# line   = "abc"
			#             ^- columnIndex = 2
			# text   =   "pqr"
			#             removeCount = 1
			# result = "abpqr"

			#           012345678
			# line   = "abcdefghi"
			#             ^- columnIndex = 2
			# text   =   "pqr"
			#             removeCount = 3
			# result = "abpqrfghi"

			$removeCount = [Math]::Min($line.Length - $columnIndex, $text.Length)

			[void]($line.Remove($columnIndex, $removeCount))
			[void]($line.Insert($columnIndex, $text))
		}
	}

	[string] GetLine($lineIndex) {
		return $this.lines[$lineIndex].ToString()
	}

	[int] GetLineCount() {
		return $this.lines.Count
	}

	hidden [System.Collections.ArrayList] $lines = [System.Collections.ArrayList]::new()
}

enum TextJustification {
	Left
	Right
}

# All whitespace in a line boundary position is replaced by a line break. Therefore, this function
# does not preserve whitespace (i.e. if you were to join the resulting lines, you would get the
# original string back).
function WordWrap(
	[string] $Text,
	[int] $Width,
	[TextJustification] $Justification = [TextJustification]::Left) {

	if (![string]::IsNullOrEmpty($Text) -and ($Width -lt 1)) { throw "width must be greater than or equal to 1" }

	$lines = [System.Collections.ArrayList]::new()

	function JustifyAppend($s) {

		if ([string]::IsNullOrEmpty($s)) { return }

		switch ($Justification) {
			([TextJustification]::Left) {
				# PadRight?
			}
	
			([TextJustification]::Right) {
				$s = $s.PadLeft($Width)
			}
		}

		[void]($lines.Add($s))
	}

	if ([string]::IsNullOrEmpty($Text)) { return $lines }

	[int] $start = 0


	while ($start -lt $Text.Length) {

		# trim whitespace at the start of a line
		while ($start -lt $Text.Length -and [char]::IsWhiteSpace($Text, $start)) { ++$start }

		# The lines in the 'Adjust length' region below search for the end of the line by adjusting
		# the 'length' value.

		#region Adjust length

		# start value for length
		[int] $length = [Math]::Min($Width, $Text.Length - $start)

		# Look for the first (rightmost) whitespace. If 'length' is positioned at the end of the
		# string, we don't have to look for it as the end of the string counts as a separator.

		if ((($start + $length) -lt $Text.Length) -and (!([char]::IsWhiteSpace($Text, $start + $length)))) {
			while (($length -gt 0) -and !([char]::IsWhiteSpace($Text, $start + $length - 1))) { --$length }
		}

		if ($length -eq 0) {
			# no whitespace, break in the middle of a word
			$length = [Math]::Min($Width, $Text.Length - $start)
		} else {
			# trim whitespace at the end of a line by attempting to move the 'length' position
			# to the left
			while (($length -gt 0) -and ([char]::IsWhiteSpace($Text, $start + $length - 1))) { --$length }
		}

		#endregion

		JustifyAppend $Text.Substring($start, $length)

		# prepare next iteration
		$start += $length
	}
	return $lines
}
