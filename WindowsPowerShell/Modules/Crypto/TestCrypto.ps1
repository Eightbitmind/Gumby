using module Crypto
using module TestUtils

[TestClass()]
class CryptoModuleTests {
	[TestMethod()]
	[void] GetMD501() {
		TestAreEqual (GetMD5 "abc") "90-01-50-98-3C-D2-4F-B0-D6-96-3F-7D-28-E1-7F-72"
	}
}

RunTests([CryptoModuleTests])
