using module Path
using module TestUtils

[TestClass()]
class PathModuleTests {
	[TestMethod()]
	[void] PathNormalize01() {
		TestAreEqual (PathNormalize "a:/b/c.txt") "a:\b\c.txt"
	}
}

RunTests([PathModuleTests])