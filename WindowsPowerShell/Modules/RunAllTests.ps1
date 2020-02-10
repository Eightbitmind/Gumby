using module Gumby.Path
using module Gumby.Test

# Do not name this file in a way that matches the pattern used in the Get-ChildItem call below,
# else it will dot-source itself, leading to infinite recursion.

$Global:TestRunner = [TestRunner]::new("$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path)")

foreach ($testFile in (Get-ChildItem (Split-Path -Parent $MyInvocation.MyCommand.Path) -Recurse -Include Test*.ps1)) {
	. $testFile
}

$Global:TestRunner.RunTests()

Remove-Variable -Scope Global -Name TestRunner
