function PathNormalize([string] $path)
{
	$path.Replace('/', '\')
}

Export-ModuleMember -Function PathNormalize
