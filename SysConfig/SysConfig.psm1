using module Win32

<#
.SYNOPSIS
	Switches mouse buttons.

.PARAMETER Swap
	.
#>
function SCSwapMouseButtons(<# $Swap = $true #>)
{
	Win32EnsureHelperFunctions

	# requires a re-logon to make the changes effective
	# get-itemproperty -Path "HKCU:\Control Panel\Mouse" -Name SwapMouseButtons


	[bool] $wasSwapped = [Win32]::SwapMouseButton($true);
	if ($wasSwapped)
	{
		# restore mouse button assignment
		[Win32]::SwapMouseButton($false) | Out-Null
	}


	# [Win32]::SwapMouseButton($Swap)
}
