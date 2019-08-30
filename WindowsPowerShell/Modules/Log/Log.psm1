enum LogMessageType {
	Comment
	Warning
	Error
}

# Design considerations:
# I want to enable the use of Log calls without having to worry about performance. Therefore, Log
# calls in the absence of log listeners should have a negligible overhead.
#
# Should taking of time stamps be centralized in the log dispatcher?
# I think not for not all log outputs might utilize them (e.g. a file-based listener might while a
# screen-based listener might not).
#
# Should verbosity-gating be centralized in the log dispatcher?
# I think not. It is conceivable to have a run with multiple listeners that operate with different
# verbosity settings (e.g. a screen-based listener that shows only "important" output while a
# file-based listener logs everything).
#
# Should the log dispatcher keep track of nesting depth (sections)?
# I think not for not all log outputs might utilize them (e.g. an XML-based log listener might
# represent sections with respective tags rather than through indentation).

# Would 'Trace' be a better name?
class Log {
	static [void] Comment([string] $Message) {
		[Log]::DispatchMessage([LogMessageType]::Comment, $Message)
	}

	static [void] Warning([string] $Message) {
		[Log]::DispatchMessage([LogMessageType]::Warning, $Message)
		++[Log]::_warningCount
	}

	static [void] Error([string] $Message) {
		[Log]::DispatchMessage([LogMessageType]::Error, $Message)
		++[Log]::_errorCount
	}

	static hidden [void] DispatchMessage([LogMessageType] $MessageType, [string] $Message) {
		foreach ($l in [Log]::Listeners) { $l.ProcessMessage($MessageType, $Message) }
	}

	static [uint32] WarningCount() { return [Log]::_warningCount }
	static [uint32] ErrorCount() { return [Log]::_errorCount }

	static [void] Reset() {
		[Log]::_errorCount = 0
		[Log]::_warningCount = 0
	}

	# static [Object[]] $Listeners = (New-Object -TypeName Collections.ArrayList)
	static [Object[]] $Listeners = @()

	static hidden [uint32] $_warningCount = 0
	static hidden [uint32] $_errorCount = 0
}

class FileLogListener {
	FileLogListener([string] $fileName) {
		$this._fileName = $fileName
	}

	[void] ProcessMessage([LogMessageType] $messageType, [string] $message) {
		#echo ("{0,-14} {1} {2}" -f ("{0:HH:mm:ss.FFFFF}" -f (Get-Date)), $messageType, $message) >> $this._fileName

		Write-Output "$((Get-Date).ToString("HH:mm:ss.FFFFF")) $([FileLogListener]::GetMessageTypeString($messageType)): $message" >> $this._fileName
	}

	static hidden [string] GetMessageTypeString([LogMessageType] $messageType) {
		switch ($messageType) {
			([LogMessageType]::Comment) { return "COMMENT" }
			([LogMessageType]::Warning) { return "WARNING" }
			([LogMessageType]::Error)   { return "ERROR" }
		}
		throw "unknown message type '$messageType'"
	}

	hidden [string] $_fileName
}
