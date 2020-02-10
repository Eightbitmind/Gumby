using module Gumby.Log
using module Gumby.Path

using module ".\TestUtils.psm1"

[TestClass()]
class TestUtilsTests {
	[TestMethod()]
	[void] TestObject_MatchingInts_Succeeds() {
		Test 1 1
	}

	[TestMethod()]
	[void] TestObject_MismatchingInts_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch 1 2 }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_WithMatchingStrings_Succeeds() {
		Test 'abc' 'abc'
	}

	[TestMethod()]
	[void] TestObject_MismatchingStrings_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch 'abc' 'xyz' }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingArrays_Succeeds() {
		Test @(10, 20, 30) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_MismatchingArrays_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch @(10, 20, 30) @(10, 20, 40) }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingObjects_Succeeds() {
		Test @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 30}
	}

	[TestMethod()]
	[void] TestObject_MismatchingObjects_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 46} }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingObjectsWithArrays_Succeeds() {
		Test @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,3}
	}

	[TestMethod()]
	[void] TestObject_MismatchingObjectsWithArrays_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,4} }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingArraysOfObjects_Succeeds() {
		Test (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dana"})
	}

	[TestMethod()]
	[void] TestObject_MismatchingArraysOfObjects_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dora"}) }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingRegex_Succeeds() {
		Test (ExpectRegex "^Em") "Emily"
	}

	[TestMethod()]
	[void] TestObject_MismatchingRegex_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (ExpectRegex "^Em") "Esther" }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_MatchingArrayOfRegex_Succeeds() {
		Test @((ExpectRegex "^Fi"), (ExpectRegex "^Ga")) @("Fiona", "Gavin")
	}

	[TestMethod()]
	[void] TestObject_MismatchingArrayOfRegex_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch @((ExpectRegex "^Fi"), (ExpectRegex "^Ga")) @("Fiona", "Gina") }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_ListContainingItem_Succeeds() {
		Test (ExpectContains 20) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_ListNotContainingItem_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (ExpectContains 21) @(10, 20, 30) }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_ListContainingItemMatchingRegex_Succeeds() {
		Test (ExpectContains (ExpectRegex "anna")) @("Hanna", "Irene", "Joyce")
	}

	[TestMethod()]
	[void] TestObject_ListNotContainingItemMatchingRegex_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (ExpectContains (ExpectRegex "anne")) @("Hanna", "Irene", "Joyce") }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_NegatedMismatch_Succeeds() {
		Test (ExpectNot 2) 1
	}

	[TestMethod()]
	[void] TestObject_DoubleNegatedMatch_Succeeds() {
		Test (ExpectNot (ExpectNot 1)) 1
	}

	[TestMethod()]
	[void] TestObject_WithListContainingOneItemAndAnother_Succeeds() {
		Test (ExpectAnd (ExpectContains 10) (ExpectContains 30)) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_ListNotContainingOneItemButNotAnother_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (ExpectAnd (ExpectContains 10) (ExpectContains 21)) @(10, 20, 30) }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_ListContainingOneItemOrAnother_Succeeds() {
		Test (ExpectOr (ExpectContains 40) (ExpectContains 10)) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_ListContainingNeitherOneItemNorAnother_Fails() {
		$result = $true
		$logInterceptor = [LogInterceptor]::new({})
		try { $result = IsMatch (ExpectOr (ExpectContains 5) (ExpectContains 17)) @(10, 20, 30) }
		finally { $logInterceptor.Dispose() }
		Test $false $result
	}

	[TestMethod()]
	[void] TestObject_CustomExpectation_Succeeds() {
		Test (Expect "IsEven" {param($a) ($a % 2) -eq 0}) 2
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([TestUtilsTests])
