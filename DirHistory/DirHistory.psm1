using module ListBox
using module Window

# an IEnumerable implementation as required by ListBox, but treated here as a stack
$dirHistory = [System.Collections.ArrayList]::new(<# history size #> 30)

<#
.SYNOPSIS
Adds an item to the directory history.

.PARAMETER Directory
Item to add to the directory history.
#>
function DirHistoryPush($Directory) {
	$index = $dirHistory.IndexOf($Directory)

	if ($index -lt 0) {
		if ($dirHistory.Count -eq ($dirHistory.Capacity - 1)) {
			# we'd overflow the max size
			$dirHistory.RemoveAt($dirHistory.Count - 1)
		}
		$dirHistory.Insert(0, $Directory)

	} elseif ($index -ne 0) {
		# directory is already in the history, but not at the top of the stack
		$dirHistory[$index] = $dirHistory[0]
		$dirHistory[0] = $Directory
	}
}

<#
.SYNOPSIS
Prompts the user to select an item from the directory history and makes it the current directory.
#>
function DirHistorySelect() {
	$horizontalPercent = 0.5
	$verticalPercent = 0.5

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$lb = [ListBox]::new($dirHistory, ([StringLBItem]), $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$lb.Title = 'Directory History'

	if (($lb.Run() -eq [WindowResult]::OK) -and ($lb.SelectedIndex() -lt $lb.ItemCount())) {
		Set-Location $lb.SelectedItem().Value()
	}
}
