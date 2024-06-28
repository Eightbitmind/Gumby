using module Gumby.ListBox
using module Gumby.Window

<#
.SYNOPSIS
Displays the command history and allows to select and invoke a command from it.

.PARAMETER Count
Maximum number of command history items to select from.

.DESCRIPTION
The command history is displayed in reverse chronologic order.
#>
function CmdHistorySelect($Count = 30) {
	$rawCmdHistory = Get-History -Count $Count

	$omittedCommands = "Get-History", "ch"

	# Not using 'Get-Unique' cmdlet here as it requires alphabetical sorting, and I want to preserve
	# the historic order of commands.

	$cmdHistory = [System.Collections.ArrayList]::new()

	for ($i = $rawCmdHistory.Count - 1; $i -ge 0; --$i) {
		if (($omittedCommands -notcontains $rawCmdHistory[$i].CommandLine) -and
			($cmdHistory -notcontains $rawCmdHistory[$i].CommandLine)) {
			$cmdHistory.Add($rawCmdHistory[$i].CommandLine) | Out-Null
		}
	}

	$horizontalPercent = 0.5
	$verticalPercent = 0.5

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$lb = [ListBox]::new($cmdHistory, ([StringLBItem]), $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$lb.Title = 'Command History'

	if (($lb.Run() -eq [WindowResult]::OK) -and ($lb.SelectedIndex() -lt $lb.ItemCount())) {
		Invoke-Expression $lb.SelectedItem().Value()
	}
}
