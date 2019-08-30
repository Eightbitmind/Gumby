using module Log
using module TestUtils

& {
	[Log]::Error("slogblog")
	TestAreEqual ([Log]::WarningCount()) 0
	TestAreEqual ([Log]::ErrorCount()) 1
	[Log]::Reset()
}

& {
	[Log]::Warning("slobglog")
	TestAreEqual ([Log]::WarningCount()) 1
	TestAreEqual ([Log]::ErrorCount()) 0
	[Log]::Reset()
}

& {
	$logFileName = "$env:TEMP\TestLog.log"
	$fll = [FileLogListener]::new($logFileName)
	[Log]::Listeners.Add($fll) | Out-Null
	[Log]::Comment("lobsglog")
	[Log]::Warning("logsblog")

	TestIsTrue (Test-Path $logFileName) "log file exists"
	TestAreEqual ([Log]::WarningCount()) 1
	TestAreEqual ([Log]::ErrorCount()) 0

	TestTuplesMatch (Get-Content $logFileName) @("COMMENT: lobsglog", "WARNING: logsblog")

	Remove-Item $logFileName
	[Log]::Reset()
	[Log]::Listeners.Remove($fll)
}