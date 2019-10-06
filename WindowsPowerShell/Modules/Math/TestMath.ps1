using module Math
using module TestUtils

[TestClass()]
class MathModuleTests {
	[TestMethod()]
	[void] IsEven_m2() {
		TestIsTrue (IsEven -2)
	}

	[TestMethod()]
	[void] IsEven_m1() {
		TestIsFalse (IsEven -1)
	}

	[TestMethod()]
	[void] IsEven_0() {
		TestIsTrue (IsEven 0)
	}

	[TestMethod()]
	[void] IsEven_p1() {
		TestIsFalse (IsEven 1)
	}

	[TestMethod()]
	[void] IsEven_p2() {
		TestIsTrue (IsEven 2)
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([MathModuleTests])
