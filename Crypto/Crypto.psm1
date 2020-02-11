<#
.SYNOPSIS
Gets MD5 hash for a string value.

.PARAMETER Text
String value to calculate MD5 hash for.

.OUTPUTS
Text representing MD5 hash.
#>
function GetMD5($Text) {
	$md5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$utf8 = New-Object -TypeName System.Text.UTF8Encoding
	$hash = [System.BitConverter]::ToString($md5.ComputeHash($utf8.GetBytes($Text)))
	return $hash
}
