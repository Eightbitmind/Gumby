using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RuntTests")

Import-Module -Force "$PSScriptRoot/Path.psm1"

[TestClass()]
class PathNormalizeTests {
	[TestMethod()]
	[void] PathNormalize_PathWithForwardSlashes() {
		Test "a:\b\c.txt" (PathNormalize "a:/b/c.txt")
	}
}

[TestClass()]
class PathFileBaseNameTests {
	[TestMethod()]
	[void] PathFileBaseName_EmptyPath() {
		Test "" (PathFileBaseName "")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutParentWithoutExt() {
		Test "a" (PathFileBaseName "a")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutParentWithExt() {
		Test "a" (PathFileBaseName "a.b")
	}

	[TestMethod()]
	[void] PathFileBaseName_NameWithMultipleDots() {
		Test "a.b" (PathFileBaseName "a.b.c")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutFilePart() {
		Test "" (PathFileBaseName "a\b\")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithoutExt() {
		Test "c" (PathFileBaseName "a\b\c")
	}
	
	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithExtWithoutExt() {
		Test "d" (PathFileBaseName "a\b.c\d")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithExtWithExt() {
		Test "d" (PathFileBaseName "a\b.c\d.e")
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithExtWithNameWithMultipleDots() {
		Test "d.e" (PathFileBaseName "a\b.c\d.e.f")
	}
}

[TestClass()]
class PathJoinTests {
	[TestMethod()]
	[void] PathJoin_Nothing() {
		# not sure if that's the right behavior, perhaps we should throw if there's no base name
		Test "" (PathJoin)
	}

	[TestMethod()]
	[void] PathJoin_Base() {
		Test "a" (PathJoin -BaseName "a")
	}

	[TestMethod()]
	[void] PathJoin_BaseWithExt() {
		Test "a.b" (PathJoin -BaseName "a.b")
	}

	[TestMethod()]
	[void] PathJoin_BaseExtWithoutDot() {
		Test "a.txt" (PathJoin -BaseName "a" -Extension "txt")
	}

	[TestMethod()]
	[void] PathJoin_BaseExtWithDot() {
		Test "a.txt" (PathJoin -BaseName "a" -Extension ".txt")
	}

	[TestMethod()]
	[void] PathJoin_BaseWithExtDoubleExt() {
		Test "a.b.c.d" (PathJoin -BaseName "a.b" -Extension "c.d")
	}

	[TestMethod()]
	[void] PathJoin_DirsBaseNoExt() {
		Test "a\b\c\d" (PathJoin -Directories "a", "b", "c" -BaseName "d")
	}

	[TestMethod()]
	[void] PathJoin_DirsWithoutSepBaseExt() {
		Test "a\b\c\d.txt" (PathJoin -Directories "a", "b", "c" -BaseName "d" -Extension "txt")
	}

	[TestMethod()]
	[void] PathJoin_DirsWithSepBaseExt() {
		Test "a\b\c\d.txt" (PathJoin -Directories "a\", "/b", "c" -BaseName "d" -Extension "txt")
	}
}

[TestClass()]
class PathAsUriTests {
	[TestMethod()]
	[void] PathAsUri_Example1() {
		Test "file:///C/foo/bar" (PathAsUri "C:\foo\bar")
	}
}

[TestClass()]
class PathGetRelativeTests {
	[TestMethod()]
	[void] PathGetRelative01() {
		Test "" (PathGetRelative "" "")
	}

	[TestMethod()]
	[void] PathGetRelative02() {
		Test "a" (PathGetRelative "" "a")
	}

	[TestMethod()]
	[void] PathGetRelative03() {
		Test ".." (PathGetRelative "a" "")
	}

	[TestMethod()]
	[void] PathGetRelative04() {
		Test "" (PathGetRelative "a" "a")
	}

	[TestMethod()]
	[void] PathGetRelative05() {
		Test "" (PathGetRelative "a/b" "a/b")
	}

	[TestMethod()]
	[void] PathGetRelative06() {
		Test "../c" (PathGetRelative "a/b" "a/c")
	}

	[TestMethod()]
	[void] PathGetRelative07() {
		Test "../../d/e" (PathGetRelative "a/b/c" "a/d/e")
	}

	[TestMethod()]
	[void] PathGetRelative08() {
		Test "d" (PathGetRelative "a/b/c" "a/b/c/d")
	}

	[TestMethod()]
	[void] PathGetRelative10() {
		Test "c/d" (PathGetRelative "a/b" "a/b/c/d")
	}

	[TestMethod()]
	[void] PathGetRelative11() {
		Test "../.." (PathGetRelative "a/b/c/d" "a/b")
	}

	[TestMethod()]
	[void] PathGetRelative_BackslashesInBase() {
		Test "../.." (PathGetRelative "a\b\c\d" "a/b")
	}

	[TestMethod()]
	[void] PathGetRelative_BackslashesInPath() {
		Test "../.." (PathGetRelative "a/b/c/d" "a\b")
	}

	[TestMethod()]
	[void] PathGetRelative_DifferingCapitalization() {
		Test "c/d" (PathGetRelative "A/B" "a\b\c\d")
	}

	[TestMethod()]
	[void] PathGetRelative_StartingWithSlash() {
		Test "c/d" (PathGetRelative "/A/B" "a\b\c\d")
	}

	[TestMethod()]
	[void] PathGetRelative_RealPaths() {
		Test "../../../Microsoft Office/Office16" (PathGetRelative "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\" "C:\Program Files (x86)\Microsoft Office\Office16")
	}

	[TestMethod()]
	[void] PathGetRelative_TargetPathWithFileName() {
		Test "../System32/Notepad.exe" (PathGetRelative "C:\Windows\Globalization" "c:\windows\System32\Notepad.exe")
	}
}

$tests = ([PathNormalizeTests]), ([PathFileBaseNameTests]), ([PathJoinTests]), ([PathAsUriTests]), ([PathGetRelativeTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RuntTests" { RunTests "$env:TEMP\PathTests.log" @tests }
}
