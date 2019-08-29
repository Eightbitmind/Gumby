$LogMessageType = @{
	Comment = "C";
	Error = "E";
	Warning = "W";
}

function New-Log([string] $logFile, [int] $verbosityLimit = [int]::MaxValue)
{
    if(Test-Path $logFile) { rm $logFile }

   	echo ("Running on {0} on {1:yyyy-MM-dd} at {1:HH:mm}" -f $env:COMPUTERNAME, (Get-Date)) > $logFile

    New-Object Object |
        Add-Member -MemberType NoteProperty -Name LogFile -Value $logFile -PassThru |
        Add-Member -MemberType NoteProperty -Name VerbosityLimit -Value $verbosityLimit -PassThru |
        Add-Member -MemberType ScriptMethod -Name Log -PassThru {
            param([string] $message, $messageType = $LogMessageType.Comment, [int] $verbosityLevel = 1)

        	echo ("{0,-14} {1} {2}" -f ("{0:HH:mm:ss.FFFFF}" -f (Get-Date)), $messageType, $message) >> $this.LogFile

	        switch($messageType) {
		        $LogMessageType.Comment {
			        if($verbosityLevel -le $this.VerbosityLimit) {
				        Write-Host $message
			        }
		        }
		        $LogMessageType.Error {
                    # http://social.technet.microsoft.com/Forums/windowsserver/en-US/b5462361-2158-479d-90bd-b9365940a7f1/writeerror-in-script-method-writes-nothing?forum=winserverpowershell
			        # Write-Error -Message $message
                    Write-Host -ForegroundColor Red "ERROR: $message"
                }
		        $LogMessageType.Warning {
			        Write-Warning $message
		        }

	        }
        } |
        Add-Member -MemberType ScriptMethod -Name Comment -PassThru {
            param([string] $message, [int] $verbosityLevel = 1)
	        $this.Log($message, $LogMessageType.Comment, $verbosityLevel)
        } |
        Add-Member -MemberType ScriptMethod -Name Trace  -PassThru {
            param([string] $message)
	        $this.Log($message, $LogMessageType.Comment, 2)
        } |
        Add-Member -MemberType ScriptMethod -Name Error -PassThru {
            param([string] $message)
	        $this.Log($message, $LogMessageType.Error, 1)
        } |
        Add-Member -MemberType ScriptMethod -Name Warning -PassThru {
            param([string] $message)
	        $this.Log($message, $LogMessageType.Warning, 1)
        }
}

Export-ModuleMember -Function New-Log