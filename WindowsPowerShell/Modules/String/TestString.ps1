using module String
using module TestUtils

#region Abbreviate tests

#                         0123456789
TestAreEqual (Abbreviate "abcdefghij" 10) "abcdefghij"
TestAreEqual (Abbreviate "abcdefghij" 9) "abc...hij"
TestAreEqual (Abbreviate "abcdefghij" 8) "abc...ij"
TestAreEqual (Abbreviate "abcdefghij" 7) "ab...ij"
TestAreEqual (Abbreviate "abcdefghij" 6) "ab...j"
TestAreEqual (Abbreviate "abcdefghij" 5) "a...j"
TestAreEqual (Abbreviate "abcdefghij" 4) "a..."

#endregion

#region EnsureStringLength

TestAreEqual (EnsureStringLength "abc" 6) "abc   "
TestAreEqual (EnsureStringLength "abc" 6 "_") "abc___"
TestAreEqual (EnsureStringLength "abcdef" 3) "abc"

#endregion

#region NormalizeWhitespace tests

TestAreEqual (NormalizeWhitespace "") ""
TestAreEqual (NormalizeWhitespace "abc") "abc"
TestAreEqual (NormalizeWhitespace "abc ") "abc"
TestAreEqual (NormalizeWhitespace " abc") "abc"
TestAreEqual (NormalizeWhitespace "   a bc`tdef `t ghi `n") "a bc def ghi"

#endregion

#region Split-Line tests

TestTuplesAreEqual (SplitCSVLine "`"a`",`"b`",`"c`"") @('a', 'b', 'c')

#endregion

#region Zip tests

& {
	$r = Zip ("a", "b", "c") (1, 2, 3)
	TestAreEqual $r.Count 3
	TestAreEqual $r.a 1
	TestAreEqual $r.b 2
	TestAreEqual $r.c 3
}

#endregion