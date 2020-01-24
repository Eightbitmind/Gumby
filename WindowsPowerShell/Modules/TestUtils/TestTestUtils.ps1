using module Log
using module TestUtils

[TestClass()]
class TestUtilsTests {
	[TestMethod()]
	[void] TestObject_WithMatchingInts_Succeeds() {
		XTestObject 1 1
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingInts_Fails() {
		TestIsFalse (XAreObjectsEqual 1 2)
	}

	[TestMethod()]
	[void] TestObject_WithMatchingStrings_Succeeds() {
		XTestObject 'abc' 'abc'
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingStrings_Fails() {
		TestIsFalse (XAreObjectsEqual 'abc' 'xyz')
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArrays_Succeeds() {
		XTestObject @(10, 20, 30) @(10, 20, 30)
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArrays_Fails() {
		TestIsFalse (XAreObjectsEqual @(10, 20, 30) @(10, 20, 40))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingObjects_Succeeds() {
		XTestObject @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 30}
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingObjects_Fails() {
		TestIsFalse (XAreObjectsEqual @{Name = "Anna"; Age = 30} @{Name = "Anna"; Age = 46})
	}

	[TestMethod()]
	[void] TestObject_WithMatchingObjectsWithArrays_Succeeds() {
		XTestObject @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,3}
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingObjectsWithArrays_Fails() {
		TestIsFalse (XAreObjectsEqual @{Name = "Ben"; Games = 1,2,3} @{Name = "Ben"; Games = 1,2,4})
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArraysOfObjects_Succeeds() {
		XTestObject (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dana"})
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArraysOfObjects_Fails() {
		TestIsFalse (XAreObjectsEqual (@{Name = "Clara"}, @{Name = "Dana"}) (@{Name = "Clara"}, @{Name="Dora"}))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingRegex_Succeeds() {
		XTestObject "Emily" ([XRegexComparand]::new("^Em"))
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingRegex_Fails() {
		TestIsFalse (XAreObjectsEqual "Esther" ([XRegexComparand]::new("^Em")))
	}

	[TestMethod()]
	[void] TestObject_WithMatchingArrayOfRegex_Succeeds() {
		XTestObject @("Fiona", "Gavin") @([XRegexComparand]::new("^Fi"), [XRegexComparand]::new("^Ga"))
	}

	[TestMethod()]
	[void] TestObject_WithMismatchingArrayOfRegex_Fails() {
		TestIsFalse (XAreObjectsEqual @("Fiona", "Gina") @([XRegexComparand]::new("^Fi"), [XRegexComparand]::new("^Ga")))
	}

	[TestMethod()]
	[void] TestObject_WithListContainingItems_Succeeds() {
		XTestObject @(10, 20, 30, 40) ([XListContainsComparand]::new(@(20, 40)))
	}

	[TestMethod()]
	[void] TestObject_WithListNotContainingItems_Succeeds() {
		TestIsFalse (XAreObjectsEqual @(10, 20, 30, 40) ([XListContainsComparand]::new(@(20, 21))))
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([TestUtilsTests])
