using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Crypto.psm1"

[TestClass()]
class CryptoModuleTests {
	[TestMethod()]
	[void] GetMD501() {
		Test "90-01-50-98-3C-D2-4F-B0-D6-96-3F-7D-28-E1-7F-72" (GetMD5 "abc")
	}
}

$tests = ([CryptoModuleTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\CryptoTests.log" @tests }
}
