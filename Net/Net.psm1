function Test-NetworkSharePath([string] $path) {
	# Examples of valid network share paths:
	#     "\\machine\share\sub1\sub2"
	#     "\\machine\share\sub1"
	#     "\\machine\share"
	#
	# Examples of Invalid network shared paths:
	#     "\\machine\"
	#
	# The shortest possible valid network share path is
	#     "\\a\b" (length = 5)

	$firstSingleSlash = if ($path.Length -gt 3) { $path.IndexOf("\", 3) } else { -1 }
	if ($path.Length -ge 5 -and $path.StartsWith('\\') -and $firstSingleSlash -gt 0 -and $firstSingleSlash -lt $path.Length - 1) {
		$secondSingleSlash = $path.IndexOf("\", $firstSingleSlash + 1)
		if ($secondSingleSlash -gt 0) {
			return @{
				IsValidNetworkSharePath = $true
				Machine = $path.Substring(2, $firstSingleSlash - 2)
				Share = $path.Substring($firstSingleSlash + 1, $secondSingleSlash - $firstSingleSlash - 1)
				Remainder = $path.Substring($secondSingleSlash + 1)
			}
		} else {
			$retval = @{
				IsValidNetworkSharePath = $true
				Machine = $path.Substring(2, $firstSingleSlash - 2)
				Share = $path.Substring($firstSingleSlash + 1, $path.Length - $firstSingleSlash - 1)
				Remainder = ""
			}
			return $retval
		}
	} else {
		return @{
			IsValidNetworkSharePath = $false 
			Machine=""
			Share = ""
			Remainder = ""
		}
	}
}

function Use-NetworkShare([string] $share, [string] $user, [string] $password) {
	try {
		$rv = net use $share /user:$user $password 2>&1 | Out-Null
		# Write-Host "return value $rv"
		# Write-Host "error $error"
		# Write-Host "lastexitcode $lastexitcode"
		if ($lastexitcode -eq 0) {
			return @{ Success = $true; Disconnect = {net use /d $share} }
		} else {
			return @{ Success = $false; Disconnect = {} }
		}
	} catch {
		return @{ Success = $false; Disconnect = {} }
	}
}
