function Dispose($Object) {
	if ($Object -ne $null -and $Object -is [System.IDisposable]) {
		$Object.Dispose()
	}
}

Export-ModuleMember -Function Dispose
