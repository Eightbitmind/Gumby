using module Log
using module TestUtils

# The file is named to *not* match the pattern used in RunAllTests.ps1.

# FUTURE: By utilizing test-method-local log observers, it might be possible to rearrange these
# tests in a test class.

& {
	[Log]::Error("slogblog")
	if ([Log]::WarningCount() -ne 0) { throw "WarningCount is not 0" }
	if ([Log]::ErrorCount() -ne 1) { throw "ErrorCount is not 1"}
	[Log]::Reset()
}

& {
	[Log]::Warning("slobglog")
	if ([Log]::WarningCount() -ne 1) { throw "WarningCount is not 1" }
	if ([Log]::ErrorCount() -ne 0) { throw "ErrorCount is not 0" }
	[Log]::Reset()
}

& {
	$logFileName = "$env:TEMP\TestLog.log"
	$fll = [FileLogListener]::new($logFileName)
	[Log]::Listeners.Add($fll) | Out-Null
	[Log]::Comment("lobsglog")
	[Log]::Warning("logsblog")
	$content = Get-Content $logFileName

	if (!(Test-Path $logFileName)) { throw "log file doesn't exist" }
	if ([Log]::WarningCount() -ne 1) { throw "WarningCount is not 1" }
	if ([Log]::ErrorCount() -ne 0) { throw "ErrorCount is not 0" }

	if ($content[0] -notmatch "COMMENT: lobsglog") { throw "log line 1 does not match expectation" }
	if ($content[1] -notmatch "WARNING: logsblog") { throw "log line 2 does not match expectation" }

	Remove-Item $logFileName
	[Log]::Reset()
	[Log]::Listeners.Remove($fll)
}