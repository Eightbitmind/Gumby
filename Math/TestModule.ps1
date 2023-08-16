using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Math.psm1"

[TestClass()]
class IsEvenTests {
	[TestMethod()]
	[void] Minus2_IsEven() {
		Test $true (IsEven -2)
	}

	[TestMethod()]
	[void] Minus1_IsNotEven() {
		Test $false (IsEven -1)
	}

	[TestMethod()]
	[void] Zero_IsEven() {
		Test $true (IsEven 0)
	}

	[TestMethod()]
	[void] One_IsNotEven() {
		Test $false (IsEven 1)
	}

	[TestMethod()]
	[void] Two_IsEven() {
		Test $true (IsEven 2)
	}
}

[TestClass()]
class EncodeB26Tests {
	[TestMethod()]
	[void] EncodeB26_0_A() {
		Test "A" (EncodeBase26 0)
	}

	[TestMethod()]
	[void] EncodeB26_25_Z() {
		Test "Z" (EncodeBase26 25)
	}

	[TestMethod()]
	[void] EncodeB26_26_BA() {
		Test "BA" (EncodeBase26 26)
	}

	[TestMethod()]
	[void] EncodeB26_77_CZ() {
		Test "CZ" (EncodeBase26 77)
	}

	[TestMethod()]
	[void] EncodeB26_1234_BVM() {
		Test "BVM" (EncodeBase26 1234)
	}
}

[TestClass()]
class GenerateRandomLetterIdTests {
	[TestMethod()]
	[void] DefaultLength_Generates3CharString() {
		Test 3 (GenerateRandomLetterId).Length
	}

	[TestMethod()]
	[void] Length1_Generates1CharString() {
		Test 1 (GenerateRandomLetterId -Length 1).Length
	}

	[TestMethod()]
	[void] Length4_Generates4CharString() {
		Test 4 (GenerateRandomLetterId -Length 4).Length
	}
}

$tests = ([IsEvenTests], [EncodeB26Tests], [GenerateRandomLetterIdTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\MathTests.log" @tests }
}
