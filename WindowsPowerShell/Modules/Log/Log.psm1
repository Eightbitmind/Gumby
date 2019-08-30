# abstain from using module Assert here as it might use the Log module

enum LogMessageType {
	Comment
	Warning
	Error
	BeginSection
	EndSection
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

	static [void] Trace([string] $Message) {
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

	static [void] BeginSection([string] $Message) {
		[Log]::DispatchMessage([LogMessageType]::BeginSection, $Message)
	}

	static [void] EndSection([string] $Message) {
		[Log]::DispatchMessage([LogMessageType]::EndSection, $Message)
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

	# ArrayList over standard array for mutability
	static [Collections.ArrayList] $Listeners = [Collections.ArrayList]::new()

	static hidden [uint32] $_nextListenerId = 0
	static hidden [uint32] $_warningCount = 0
	static hidden [uint32] $_errorCount = 0
}

class FileLogListener {
	FileLogListener([string] $fileName) {
		$this._fileName = $fileName
	}

	[void] ProcessMessage([LogMessageType] $messageType, [string] $message) {
		if ($messageType -eq [LogMessageType]::EndSection) {
			if ($this._nestingLevel -eq 0) { throw "mismatching log sections" }
			--$this._nestingLevel
		}

		Write-Output ("{0,-14} {1}{2}: {3}" -f
			(Get-Date).ToString("HH:mm:ss.FFFFF"),
			<# indent #> (" " * 4 * $this._nestingLevel),
			[FileLogListener]::GetMessageTypeString($messageType),
			$message
		) >> $this._fileName

		if ($messageType -eq [LogMessageType]::BeginSection) { ++$this._nestingLevel }
	}

	static hidden [string] GetMessageTypeString([LogMessageType] $messageType) {
		switch ($messageType) {
			([LogMessageType]::Comment) { return "COMMENT" }
			([LogMessageType]::Warning) { return "WARNING" }
			([LogMessageType]::Error) { return "ERROR" }
			([LogMessageType]::BeginSection) { return "BEGIN" }
			([LogMessageType]::EndSection) { return "END" }
		}
		throw "unknown message type '$messageType'"
	}

	hidden [string] $_fileName
	hidden [uint32] $_nestingLevel = 0
}
