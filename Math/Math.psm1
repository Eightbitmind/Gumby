<#
.SYNOPSIS
Checks whether a number is even.

.PARAMETER n
Number to check.

.OUTPUTS
True if the number is even, false otherwise.
#>
function IsEven([int] $n) {
	return $n % 2 -eq 0
}

<#
.SYNOPSIS
Encode a number in a base-26 system using Latin uppercase letters as digits.

.PARAMETER n
Number to encode.

.OUTPUTS
Base-26 encoding of number.

.EXAMPLE
PS> EncodeBase26 0
A

.EXAMPLE
PS> EncodeBase26 25
Z

.EXAMPLE
PS> EncodeBase26 26
BA

.EXAMPLE
PS> EncodeBase26 77
CZ

.EXAMPLE
PS> EncodeBase26 1234
BVM
#>
function EncodeBase26($n) {
	function ToChar([int]$digit) { return [char](([int]'A'[0]) + $digit) }

	$base = 26
	$remainder = $n
	$result = "";

	while ($true) {
		$digit = $remainder % $base
		$remainder = ($remainder - $digit) / $base
		$result = (ToChar $digit) + $result
		if ($remainder -eq 0) {break}
	}

	return $result
}

<#
.SYNOPSIS
Generate a random string consisting of uppercase Latin letters.

.PARAMETER Length
Length of string to generate (defaults to 3).

.OUTPUTS
Random string.

.EXAMPLE
PS> GenerateRandomLetterId
LGW

.EXAMPLE
PS> GenerateRandomLetterId -Length 1
T

.EXAMPLE
PS> GenerateRandomLetterId -Length 4
SZCW
#>
function GenerateRandomLetterId($Length = 3)
{
	return (EncodeBase26 (Get-Random -Maximum ([math]::pow(26, $Length))))
}
