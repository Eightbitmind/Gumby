
enum LogMessageType {
	Comment
	Warning
	Error
}

# Would 'Trace' be a better name?
class Log {
	static [void] Comment([string] $Message) {

		foreach ($l in [Log]::Listeners) {
			$l.ProcessMessage([LogMessageType]::Comment, $Message)
		}
	}

	static [void] Warning([string] $Message) {
		foreach ($l in [Log]::Listeners) {
			$l.ProcessMessage([LogMessageType]::Warning, $Message)
		}
		++[Log]::_warningCount
	}

	static [void] Error([string] $Message) {
		foreach ($l in [Log]::Listeners) {
			$l.ProcessMessage([LogMessageType]::Error, $Message)
		}
		++[Log]::_errorCount
	}

	static [uint32] WarningCount() { return [Log]::_warningCount }
	static [uint32] ErrorCount() { return [Log]::_errorCount }

	static [void] Reset() {
		[Log]::_errorCount = 0
		[Log]::_warningCount = 0
	}

	static [Object[]] $Listeners = @()

	static hidden [uint32] $_warningCount = 0
	static hidden [uint32] $_errorCount = 0
}
