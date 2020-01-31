using module Path
using module TestUtils

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
		Test "file:C:/foo/bar" (PathAsUri "C:\foo\bar")
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([PathNormalizeTests]) ([PathFileBaseNameTests]) ([PathJoinTests]) ([PathAsUriTests])
