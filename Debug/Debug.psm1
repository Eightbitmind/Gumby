
function TraceStack() {
	foreach ($frame in Get-PSCallStack) {
		echo $frame.Location >> "$env:TEMP\PSDebug.log"
	}
}
<#
.SYNOPSIS
Asserts a condition.

.PARAMETER Condition
Value representing the condition.

.PARAMETER Message
Message to fail execution with if the condition is not true.
#>
function assert($Condition, $Message = "failed assertion") {
	if (!$Condition) {
		TraceStack
		throw $Message
	}
}

Export-ModuleMember -Function assert
