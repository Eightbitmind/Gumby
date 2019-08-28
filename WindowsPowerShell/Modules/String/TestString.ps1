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
