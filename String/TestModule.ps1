using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/String.psm1"

[TestClass()]
class StringModuleTests {
	[TestMethod()]
	[void] Abbreviate10() {
		Test "abcdefghij" (Abbreviate "abcdefghij" 10)
	}

	[TestMethod()]
	[void] Abbreviate09() {
		Test "abc...hij" (Abbreviate "abcdefghij" 9)
	}

	[TestMethod()]
	[void] Abbreviate08() {
		Test "abc...ij" (Abbreviate "abcdefghij" 8)
	}

	[TestMethod()]
	[void] Abbreviate07() {
		Test "ab...ij" (Abbreviate "abcdefghij" 7)
	}

	[TestMethod()]
	[void] Abbreviate06() {
		Test "ab...j" (Abbreviate "abcdefghij" 6)
	}

	[TestMethod()]
	[void] Abbreviate05() {
		Test "a...j" (Abbreviate "abcdefghij" 5)
	}

	[TestMethod()]
	[void] Abbreviate04() {
		Test "a..." (Abbreviate "abcdefghij" 4)
	}

	[TestMethod()]
	[void] EnsureStringLength_ExtendsStringWithDefaultFillChar() {
		Test "abc   " (EnsureStringLength "abc" 6)
	}

	[TestMethod()]
	[void] EnsureStringLength_ExtendsStringWithCustomFillChar() {
		Test "abc___" (EnsureStringLength "abc" 6 "_")
	}

	[TestMethod()]
	[void] EnsureStringLength_TruncatesString() {
		Test "abc" (EnsureStringLength "abcdef" 3)
	}

	[TestMethod()]
	[void] NormalizeWhitespace_EmptyString() {
		Test "" (NormalizeWhitespace "")
	}
	[TestMethod()]
	[void] NormalizeWhitespace_StringWithoutWhitespace() {
		Test "abc" (NormalizeWhitespace "abc")
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithTrailingWhitespace() {
		Test "abc" (NormalizeWhitespace "abc ")
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithLeadingWhitespace() {
		Test "abc" (NormalizeWhitespace " abc")
	}

	[TestMethod()]
	[void] NormalizeWhitespace_StringWithScatteredWhitespace() {
		Test "a bc def ghi" (NormalizeWhitespace "   a bc`tdef `t ghi `n")
	}

	[TestMethod()]
	[void] SplitCSVLine_WellFormedCSVLine() {
		Test @('a', 'b', 'c') (SplitCSVLine "`"a`",`"b`",`"c`"")
	}

	[TestMethod()]
	[void] Zip_ThreeItems() {
		$r = Zip ("a", "b", "c") (1, 2, 3)
		Test (ExpectAnd (ExpectKeyCountEqual 3) @{a = 1; b = 2; c = 3}) $r
	}
}

$tests = @([StringModuleTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\StringTests.log" @tests }
}
