using module Gumby.Path
using module Gumby.Test

Import-Module "$PSScriptRoot/Crypto.psm1"

[TestClass()]
class CryptoModuleTests {
	[TestMethod()]
	[void] GetMD501() {
		Test "90-01-50-98-3C-D2-4F-B0-D6-96-3F-7D-28-E1-7F-72" (GetMD5 "abc")
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $PSCommandPath).log"
RunTests $standaloneLogFilePath ([CryptoModuleTests])
