using module ListBox
using module Window

<#
.SYNOPSIS
Selects and invokes a command from the command history.

.PARAMETER Count
Maximum number of command history items to select from.
#>
function CmdHistorySelect($Count = 50) {
	$rawCmdHistory = Get-History

	$omittedCommands = "Get-History", "ch"

	# Not using 'Get-Unique' cmdlet here as it requires alphabetical sorting, and I want to preserve
	# the historic order of commands.

	$cmdHistory = @()

	for ($i = $rawCmdHistory.Count - 1; $i -ge 0; --$i) {
		if (($omittedCommands -notcontains $rawCmdHistory[$i].CommandLine) -and
			($cmdHistory -notcontains $rawCmdHistory[$i].CommandLine)) {
			$cmdHistory += $rawCmdHistory[$i].CommandLine
			if ($cmdHistory.Count -eq $Count) { break }
		}
	}

	[Array]::Reverse($cmdHistory)

	$horizontalPercent = 0.5
	$verticalPercent = 0.5

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$lb = [ListBox]::new($cmdHistory, $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$lb.Title = 'Command History'

	if (($lb.Run() -eq [WindowResult]::OK) -and ($lb.SelectedIndex -lt $lb.Items.Count)) {
		Invoke-Expression $lb.SelectedItem()
	}
}

Export-ModuleMember -Function CmdHistorySelect
