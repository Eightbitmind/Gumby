using module Log
using module TestUtils

& {
	[Log]::Error("slogblog")
	TestAreEqual ([Log]::WarningCount()) 0
	TestAreEqual ([Log]::ErrorCount()) 1
	[Log]::Reset()
}

& {
	[Log]::Warning("slogblog")
	TestAreEqual ([Log]::WarningCount()) 1
	TestAreEqual ([Log]::ErrorCount()) 0
	[Log]::Reset()
}