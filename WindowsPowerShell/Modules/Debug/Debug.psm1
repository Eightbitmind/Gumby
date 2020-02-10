<#
.SYNOPSIS
Asserts a condition.

.PARAMETER Condition
Value representing the condition.

.PARAMETER Message
Message to fail execution with if the condition is not true.
#>
function Assert($Condition, $Message = "failed assertion") {
	if (!$Condition) { throw $Message }
}
