function Win32EnsureHelperFunctions()
{
	$win32ClassExists = $true; try {$dummy = [Win32]} catch {$win32ClassExists = $false}

	if (!$win32ClassExists)
	{
		# $envLib = $null
		# if (!Test-Path(Env:\LIB))
		# {
		#     $envLib = $env:LIB
		#     rm Env:\LIB
		# }
Add-Type @'
using System.Runtime.InteropServices;
public static class Win32
{
	[DllImport("user32.dll")]
	public static extern bool SwapMouseButton(bool fSwap);
}
'@

		# if($envLib -ne $null)
		# {
		#     $env:LIB = $envLib
		# }
	}
}

Export-ModuleMember -Function Win32EnsureHelperFunctions
