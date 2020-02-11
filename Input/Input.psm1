<#
.SYNOPSIS
Prompts user for one out of a list of choices.

.PARAMETER prompt
Text to show to the user.

.PARAMETER choices
List of valid choices.

.PARAMETER caseSensitive
Value indicating whether input casing matters (true) or not (false). If it doesn't, the function
returns the user input uppercased.

.OUTPUTS
Choice selected by the user.
#>
function ReadChoice([string] $prompt, $choices, [bool]$caseSensitive=$false) {
	while ($true) {
		$choice = Read-Host "$prompt [$($choices -join '')]"
		if (($caseSensitive -and ($choices -ccontains $choice)) -or (-not($caseSensitive) -and ($choices -contains $choice))) {
			break
		} else {
			Write-Host "Sorry, only valid choices are $($choices -join ', ').`n"
		}
	}

	if ($caseSensitive) { $choice } else { $choice.ToUpperInvariant() }
}

