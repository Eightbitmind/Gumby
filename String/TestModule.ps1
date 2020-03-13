using module Gumby.Test
using module ".\String.psm1"

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")


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
	[void] ExpandMacros_KnownMacros() {
		Test "Name's Bond, James Bond." (ExpandMacros 'Name''s $LastName, $FirstName $LastName.' @{FirstName = "James"; LastName = "Bond"})
	}

	[TestMethod()]
	[void] ExpandMacros_UnknownMacros() {
		Test 'there are known knowns and known $Unknowns' (ExpandMacros 'there are known $ThingsWeAreAwareOf and known $Unknowns' @{ThingsWeAreAwareOf = "knowns"})
	}

	[TestMethod()]
	[void] ExpandMacros_EscapedMacroReference() {
		Test 'The Great `$Escape is a tale of prisoner escape.' (ExpandMacros 'The Great `$Escape is a tale of $Escape.' @{Escape = "prisoner escape"})
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

[TestClass()]
class TextArrayTests {
	[TestMethod()]
	[void] GetLineCount_OfEmptyTextArray() {
		$ta = [TextArray]::new()
		Test 0 $ta.GetLineCount()
	}

	[TestMethod()]
	[void] SetText_Line0Column0() {
		$ta = [TextArray]::new()
		$ta.SetText(0, 0, "abc")
		Test 1 $ta.GetLineCount()
		Test "abc" $ta.GetLine(0)
	}

	[TestMethod()]
	[void] SetText_Line2Column0() {
		$ta = [TextArray]::new()
		$ta.SetText(2, 0, "abc")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "abc" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_Line2Column2() {
		$ta = [TextArray]::new()
		$ta.SetText(2, 2, "abc")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "  abc" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_ContinuousAdditionOfLine() {
		$ta = [TextArray]::new()
		$ta.SetText(0, 0, "abc")
		$ta.SetText(1, 0, "def")

		Test 2 $ta.GetLineCount()
		Test "abc" $ta.GetLine(0)
		Test "def" $ta.GetLine(1)
	}

	[TestMethod()]
	[void] SetText_DiscontinuousAdditionOfLine() {
		$ta = [TextArray]::new()
		$ta.SetText(0, 0, "abc")
		$ta.SetText(2, 0, "def")

		Test 3 $ta.GetLineCount()
		Test "abc" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "def" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_ContinuousAdditionOfLineText() {
		$ta = [TextArray]::new()
		$ta.SetText(2, 2, "abc")
		$ta.SetText(2, 5, "def")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "  abcdef" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_DiscontinuousAdditionOfLineText() {
		$ta = [TextArray]::new()
		$ta.SetText(2, 2, "abc")
		$ta.SetText(2, 7, "def")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "  abc  def" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_OverwriteAndAppendLineText() {
		$ta = [TextArray]::new()
		#                  234
		$ta.SetText(2, 2, "abc")
		$ta.SetText(2, 4,   "pqr")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "  abpqr" $ta.GetLine(2)
	}

	[TestMethod()]
	[void] SetText_EmbeddedOverwriteLineText() {
		$ta = [TextArray]::new()
		#                  23456789
		$ta.SetText(2, 2, "abcdefgh")
		$ta.SetText(2, 4,   "pqr")
		Test 3 $ta.GetLineCount()
		Test "" $ta.GetLine(0)
		Test "" $ta.GetLine(1)
		Test "  abpqrfgh" $ta.GetLine(2)
	}
}

[TestClass()]
class WordWrapTests {
	[TestMethod()]
	[void] WordWrap_OneWordShorterThanWidth() {
		Test @("abc") @(WordWrap "abc" 4)
	}

	[TestMethod()]
	[void] WordWrap_OneWordAsLongAsWidth() {
		Test @("abc") @(WordWrap "abc" 3)
	}

	[TestMethod()]
	[void] WordWrap_OneWordLongerThanWidth() {
		Test @("ab", "c") @(WordWrap "abc" 2)
	}

	[TestMethod()]
	[void] WordWrap_WidthAtEndOfWord() {
		Test @("abc", " de") @(WordWrap "abc de" 3)
	}

	[TestMethod()]
	[void] WordWrap_WidthAtBoundary() {
		Test @("abc ", "de") @(WordWrap "abc de" 4)
	}
}

$tests = @([StringModuleTests], [TextArrayTests], [WordWrapTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\StringTests.log" @tests }
}
