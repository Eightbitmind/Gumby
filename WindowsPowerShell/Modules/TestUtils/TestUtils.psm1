using module Assert

function TestAreEqual($actual, $expected, $message = "Test Value")
{
	if ($actual -eq $expected)
	{
		Write-Host -ForegroundColor Green "value '$actual' matches expectation"
	}
	else
	{
		Write-Host -ForegroundColor Red "actual '$($actual)', expected '$($expected)'"
	}
}

function TestTuplesAreEqual($actual, $expected, $message = "Test Tuples")
{
	$actualEnum = $actual.GetEnumerator()
	$expectedEnum = $expected.GetEnumerator()

	while ($actualEnum.MoveNext())
	{
		if (!$expectedEnum.MoveNext())
		{
			Write-Host -ForegroundColor Red "$($message): more items than expected"
		}

		if ($actualEnum.Current -ne $expectedEnum.Current)
		{
			Write-Host -ForegroundColor Red "$($message): actual '$($actualEnum.Current)', expected '$($expectedEnum.Current)'"
		}
	}

	if ($expectedEnum.MoveNext())
	{
		Write-Host -ForegroundColor Red "$($message): fewer items than expected"
	}

	Write-Host -ForegroundColor Green "$($message): found expected items"
}

Export-ModuleMember -Function TestAreEqual
Export-ModuleMember -Function TestTuplesAreEqual
