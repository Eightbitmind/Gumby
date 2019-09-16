using module Path
using module TestUtils

[TestClass()]
class PathNormalizeTests {
	[TestMethod()]
	[void] PathNormalize_PathWithForwardSlashes() {
		TestAreEqual (PathNormalize "a:/b/c.txt") "a:\b\c.txt"
	}
}

[TestClass()]
class PathFileBaseNameTests {
	[TestMethod()]
	[void] PathFileBaseName_EmptyPath() {
		TestAreEqual (PathFileBaseName "") ""
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutParentWithoutExt() {
		TestAreEqual (PathFileBaseName "a") "a"
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutParentWithExt() {
		TestAreEqual (PathFileBaseName "a.b") "a"
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithoutFilePart() {
		TestAreEqual (PathFileBaseName "a\b\") ""
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithoutExt() {
		TestAreEqual (PathFileBaseName "a\b\c") "c"
	}
	
	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithExtWithoutExt() {
		TestAreEqual (PathFileBaseName "a\b.c\d") "d"
	}

	[TestMethod()]
	[void] PathFileBaseName_PathWithParentWithExtWithExt() {
		TestAreEqual (PathFileBaseName "a\b.c\d.e") "d"
	}
}

[TestClass()]
class PathJoinTests {
	[TestMethod()]
	[void] PathJoin_Nothing() {
		# not sure if that's the right behavior, perhaps we should throw if there's no base name
		TestAreEqual (PathJoin) ""
	}

	[TestMethod()]
	[void] PathJoin_Base() {
		TestAreEqual (PathJoin -BaseName "a") "a"
	}

	[TestMethod()]
	[void] PathJoin_BaseWithExt() {
		TestAreEqual (PathJoin -BaseName "a.b") "a.b"
	}

	[TestMethod()]
	[void] PathJoin_BaseExtWithoutDot() {
		TestAreEqual (PathJoin -BaseName "a" -Extension "txt") "a.txt"
	}

	[TestMethod()]
	[void] PathJoin_BaseExtWithDot() {
		TestAreEqual (PathJoin -BaseName "a" -Extension ".txt") "a.txt"
	}

	[TestMethod()]
	[void] PathJoin_BaseWithExtDoubleExt() {
		TestAreEqual (PathJoin -BaseName "a.b" -Extension "c.d") "a.b.c.d"
	}

	[TestMethod()]
	[void] PathJoin_DirsBaseNoExt() {
		TestAreEqual (PathJoin -Directories "a", "b", "c" -BaseName "d") "a\b\c\d"
	}

	[TestMethod()]
	[void] PathJoin_DirsWithoutSepBaseExt() {
		TestAreEqual (PathJoin -Directories "a", "b", "c" -BaseName "d" -Extension "txt") "a\b\c\d.txt"
	}

	[TestMethod()]
	[void] PathJoin_DirsWithSepBaseExt() {
		TestAreEqual (PathJoin -Directories "a\", "/b", "c" -BaseName "d" -Extension "txt") "a\b\c\d.txt"
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([PathNormalizeTests]) ([PathFileBaseNameTests]) ([PathJoinTests])
