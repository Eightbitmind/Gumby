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
