using module String
using module TestUtils

[TestClass()]
class StringModuleTests {
	[TestMethod()]
	[void] Abbreviate10() {
		TestAreEqual (Abbreviate "abcdefghij" 10) "abcdefghij"
	}

	[TestMethod()]
	[void] Abbreviate09() {
		TestAreEqual (Abbreviate "abcdefghij" 9) "abc...hij"
	}

	[TestMethod()]
	[void] Abbreviate08() {
		TestAreEqual (Abbreviate "abcdefghij" 8) "abc...ij"
	}

	[TestMethod()]
	[void] Abbreviate07() {
		TestAreEqual (Abbreviate "abcdefghij" 7) "ab...ij"
	}

	[TestMethod()]
	[void] Abbreviate06() {
		TestAreEqual (Abbreviate "abcdefghij" 6) "ab...j"
	}

	[TestMethod()]
	[void] Abbreviate05() {
		TestAreEqual (Abbreviate "abcdefghij" 5) "a...j"
	}

	[TestMethod()]
	[void] Abbreviate04() {
		TestAreEqual (Abbreviate "abcdefghij" 4) "a..."
	}

	[TestMethod()]
	[void] EnsureStringLength_ExtendsStringWithDefaultFillChar() {
		TestAreEqual (EnsureStringLength "abc" 6) "abc   "
	}

	[TestMethod()]
	[void] EnsureStringLength_ExtendsStringWithCustomFillChar() {
		TestAreEqual (EnsureStringLength "abc" 6 "_") "abc___"
	}

	[TestMethod()]
	[void] EnsureStringLength_TruncatesString() {
		TestAreEqual (EnsureStringLength "abcdef" 3) "abc"
	}

	[TestMethod()]
	[void] NormalizeWhitespace_EmptyString() {
		TestAreEqual (NormalizeWhitespace "") ""
	}
	[TestMethod()]
	[void] NormalizeWhitespace_StringWithoutWhitespace() {
		TestAreEqual (NormalizeWhitespace "abc") "abc"
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithTrailingWhitespace() {
		TestAreEqual (NormalizeWhitespace "abc ") "abc"
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithLeadingWhitespace() {
		TestAreEqual (NormalizeWhitespace " abc") "abc"
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithScatteredWhitespace() {
		TestAreEqual (NormalizeWhitespace "   a bc`tdef `t ghi `n") "a bc def ghi"
	}

	[TestMethod()]
	[void] SplitCSVLine_WellFormedCSVLine() {
		TestTuplesAreEqual (SplitCSVLine "`"a`",`"b`",`"c`"") @('a', 'b', 'c')
	}

	[TestMethod()]
	[void] Zip_ThreeItems() {
		$r = Zip ("a", "b", "c") (1, 2, 3)
		TestAreEqual $r.Count 3
		TestAreEqual $r.a 1
		TestAreEqual $r.b 2
		TestAreEqual $r.c 3
	}
}

$testRunner = [TestRunner]::new()
$testRunner.TestClasses.Add(([StringModuleTests])) | Out-Null
$testRunner.RunTests()
