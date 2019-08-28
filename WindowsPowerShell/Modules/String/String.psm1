# --------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
	Splits line of comma-separated quoted strings.

.PARAMETER Line
	String to split.

.OUTPUT
	List of substrings.
#>
function Split-Line([string] $Line)
{
	[bool] $inString = $false;

	$fields = @()
	$accu = ""

	for ($i = 0; $i -lt $Line.Length; $i++)
	{
		switch ($Line[$i])
		{
			#{$_ -eq '"' -and -not $inString} {$inString = $true; break}
			#{$_ -eq '"' -and $inString}      {$inString = $false; break}
			{$_ -eq '"'} {$inString = !$inString; break}
			{($_ -in ',', ';') -and -not $inString} {$fields += $accu; $accu = ""; break}
			default {$accu += $_}
		}
	}

	$fields += $accu
	$fields
}

# --------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
	Integrates an array of names and an array of values into a hash table.

.PARAMETER Names
	Array of names. The items therein become the hash table keys.

.PARAMETER Values
	Array of values. The items therein become the hash table values.

.OUTPUT
	Hash table.
#>
function Zip($Names, $Values)
{
	if ($Names.Length -ne $Values.Length) { throw "Number of names and values does not line up." }

	$hash = @{}

	for ($i = 0; $i -lt $Names.Length; $i++)
	{
		$hash.Add($Names[$i], $Values[$i])
	}

	$hash
}

# --------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
	Normalizes a string.

.PARAMETER s
	String to normalize.

.OUTPUT
	Normalized string
#>
function ConvertTo-NormalizedString([string] $s)
{
	$([regex] '\s+').Replace($s.Trim().Replace('`r`n', ' ').Replace('`r', ' ').Replace('`n', ' '), ' ')
}

# --------------------------------------------------------------------------------------------------

<#
.SYNOPSIS
	Abbreviates a string.

.PARAMETER text
	String to abbreviate.

.PARAMETER maxLength
	Maximum length of abbreviated string.

.OUTPUT
	Abbreviated string.
#>
function Abbreviate([string] $text, [uint32] $maxLength, [string] $ellipsis = "...")
{
	if ($text.Length -le $maxLength)
	{
		return $text
	}
	else
	{
		# assert ($maxLength -gt $ellipsis.length)
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

		$x = ($maxLength - $ellipsis.Length ) / 2
		return $text.Substring(0, [Math]::Round($x, 0, 1)) + $ellipsis + $text.Substring($text.Length - [Math]::Truncate($x))
	}
}

Export-ModuleMember -Function Abbreviate, ConvertTo-NormalizedString, Split-Line, Zip
