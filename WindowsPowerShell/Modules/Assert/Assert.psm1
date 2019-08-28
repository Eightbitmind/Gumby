function assert($cond, $message = "failed assertion")
{
	if (!$cond) { throw $message }
}

Export-ModuleMember -Function assert
