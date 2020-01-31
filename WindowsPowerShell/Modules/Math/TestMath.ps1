using module Math
using module TestUtils

[TestClass()]
class MathModuleTests {
	[TestMethod()]
	[void] IsEven_m2() {
		Test $true (IsEven -2)
	}

	[TestMethod()]
	[void] IsEven_m1() {
		Test $false (IsEven -1)
	}

	[TestMethod()]
	[void] IsEven_0() {
		Test $true (IsEven 0)
	}

	[TestMethod()]
	[void] IsEven_p1() {
		Test $false (IsEven 1)
	}

	[TestMethod()]
	[void] IsEven_p2() {
		Test $true (IsEven 2)
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([MathModuleTests])
