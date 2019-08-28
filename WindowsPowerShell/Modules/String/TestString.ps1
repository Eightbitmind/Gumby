using module String
using module TestUtils
#                         0123456789
TestAreEqual (Abbreviate "abcdefghij" 10) "abcdefghij"
TestAreEqual (Abbreviate "abcdefghij" 9) "abc...hij"
TestAreEqual (Abbreviate "abcdefghij" 8) "abc...ij"
TestAreEqual (Abbreviate "abcdefghij" 7) "ab...ij"
TestAreEqual (Abbreviate "abcdefghij" 6) "ab...j"
TestAreEqual (Abbreviate "abcdefghij" 5) "a...j"
TestAreEqual (Abbreviate "abcdefghij" 4) "a..."

TestTuplesAreEqual (Split-Line "`"a`",`"b`",`"c`"") @('a', 'b', 'c')

& {
	$r = Zip ("a", "b", "c") (1, 2, 3)
	TestAreEqual $r.Count 3
	TestAreEqual $r.a 1
	TestAreEqual $r.b 2
	TestAreEqual $r.c 3
}

TestAreEqual (ConvertTo-NormalizedString "   a bc`tdef `t ghi `n") "a bc def ghi"