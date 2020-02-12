using module Gumby.Test

$__tests = [System.Collections.ArrayList]::new()

foreach ($moduleTestScript in (Get-ChildItem $PSScriptRoot -Recurse -Include TestModule.ps1)) {
	$exports = . $moduleTestScript -Mode ExportTests
	if ($exports -is [array]) {
		foreach ($test in $exports) { [void]($__tests.Add($test)) }
	} else {
		[void]($__tests.Add($exports))
	}
}

RunTests "$env:TEMP\AllModuleTests.log" @__tests
