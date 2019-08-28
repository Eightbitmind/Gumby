using module ListBox
using module Window

#$dirHistory = New-Object 'System.Collections.Generic.Queue`1[System.String]'
$dirHistory = New-Object 'System.Collections.ArrayList'
$dirHistorySize = 10

function DirHistoryPush($dir)
{
	$index = $dirHistory.IndexOf($dir)

	if ($index -lt 0)
	{
		$dirHistory.Add($dir) | Out-Null
		while ($dirHistory.Count -gt $dirHistorySize) { $dirHistory.RemoveAt(0) }
	}
	elseif($index -lt $dirHistory.Count - 1)
	{
		$temp = $dirHistory[$index]
		$dirHistory[$index] = $dirHistory[$dirHistory.Count - 1]
		$dirHistory[$dirHistory.Count - 1] = $temp
	}
}

function DirHistorySelect()
{
	$horizontalPercent = 0.5
	$verticalPercent = 0.5

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$lb = [ListBox]::new($dirHistory, $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$lb.Title = 'Directory History'

	if (($lb.Run() -eq [WindowResult]::OK) -and ($lb.SelectedItemIndex -lt $lb.Items.Count))
	{
		Set-Location $lb.SelectedItem()
	}
}

Export-ModuleMember -Function DirHistoryPush
Export-ModuleMember -Function DirHistorySelect
