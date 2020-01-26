using module Log
using module TestUtils

[TestClass()]
class TestUtilsTests {
	[TestMethod()]
	[void] TestObject_WithMatchingInts_Succeeds() {
		TestObject 1 1
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingInts_Fails() {
		TestIsFalse (AreObjectsEqual 1 2)
	}

	[TestMethod()]
	[void] TestObject_WithMatchingStrings_Succeeds() {
		TestObject 'abc' 'abc'
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingStrings_Fails() {
		TestIsFalse (AreObjectsEqual 'abc' 'xyz')
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArrays_Succeeds() {
		TestObject @(10, 20, 30) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArrays_Fails() {
		TestIsFalse (AreObjectsEqual @(10, 20, 30) @(10, 20, 40))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingObjects_Succeeds() {
		TestObject @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 30}
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingObjects_Fails() {
		TestIsFalse (AreObjectsEqual @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 46})
	}

	[TestMethod()]
	[void] TestObject_WithMatchingObjectsWithArrays_Succeeds() {
		TestObject @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,3}
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingObjectsWithArrays_Fails() {
		TestIsFalse (AreObjectsEqual @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,4})
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArraysOfObjects_Succeeds() {
		TestObject (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dana"})
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArraysOfObjects_Fails() {
		TestIsFalse (AreObjectsEqual (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dora"}))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingRegex_Succeeds() {
		TestObject "Emily" ([RegexComparand]::new("^Em"))
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingRegex_Fails() {
		TestIsFalse (AreObjectsEqual "Esther" ([RegexComparand]::new("^Em")))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArrayOfRegex_Succeeds() {
		TestObject @("Fiona", "Gavin") @([RegexComparand]::new("^Fi"), [RegexComparand]::new("^Ga"))
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArrayOfRegex_Fails() {
		TestIsFalse (AreObjectsEqual @("Fiona", "Gina") @([RegexComparand]::new("^Fi"), [RegexComparand]::new("^Ga")))
	}

	[TestMethod()]
	[void] TestObject_WithListContainingItems_Succeeds() {
		TestObject @(10, 20, 30, 40) ([ListContainsComparand]::new(@(20, 40)))
	}

	[TestMethod()]
	[void] TestObject_WithListNotContainingItems_Succeeds() {
		TestIsFalse (AreObjectsEqual @(10, 20, 30, 40) ([ListContainsComparand]::new(@(20, 21))))
	}

	[TestMethod()]
	[void] TestObject_WithListContainingMatchingRegexs_Succeeds() {
		TestObject @("Hanna", "Irene", "Joyce") ([ListContainsComparand]::new(@([RegexComparand]::new("anna"), [RegexComparand]::new("oyce"))))
	}

	[TestMethod()]
	[void] TestObject_WithListContainingNonMatchingRegexs_Fails() {
		TestIsFalse (AreObjectsEqual @("Hanna", "Irene", "Joyce") ([ListContainsComparand]::new(@([RegexComparand]::new("anna"), [RegexComparand]::new("oice")))))
	}

	[TestMethod()]
	[void] TestObject_WithNegatedInt_Succeeds() {
		TestObject 1 ([NotComparand]::new(2))
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([TestUtilsTests])
