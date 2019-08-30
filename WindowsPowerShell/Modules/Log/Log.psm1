enum LogMessageType {
	Comment
	Warning
	Error
}

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
