using module Path
using module TestUtils

[TestClass()]
class PathModuleTests {
	[TestMethod()]
	[void] PathNormalize01() {
		TestAreEqual (PathNormalize "a:/b/c.txt") "a:\b\c.txt"
	}

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

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([PathModuleTests])