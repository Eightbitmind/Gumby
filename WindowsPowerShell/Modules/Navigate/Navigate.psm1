using module Log
using module Object
using module TreeView
using module Window

$debug = $true

function SetLocationVisually($startDir = (Get-Location)) {
	$fll = $null
	if ($debug) {
		$logFileName = "$env:TEMP\SetLocationVisually.log"
		if (Test-Path $logFileName) { Remove-Item $logFileName }
		$fll = [FileLogListener]::new($logFileName)
		[Log]::Listeners.Add($fll) | Out-Null
	}

	$sd = Get-Item $startDir

	$horizontalPercent = 0.8
	$verticalPercent = 0.8

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$tv = [TreeView]::new($sd, ([FileTVItem]), $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$tv.Title = 'Select Folder'

	if (($tv.Run() -eq [WindowResult]::OK) -and ($tv.SelectedIndex -lt $tv.Items.Count)) {
		Set-Location $tv.SelectedItem().Value.FullName
	}

	if ($fll -ne $null) { [Log]::Listeners.Remove($fll) }
}

function SelectVisually($startDir = (Get-Location)) {
	$sd = Get-Item $startDir

	$horizontalPercent = 0.8
	$verticalPercent = 0.8

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$tv = [FileTreeView]::new($sd, $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$tv.Title = 'Select File'

	if ($tv.Run() -eq [WindowResult]::OK  -and ($tv.SelectedIndex -lt $tv.Items.Count)) {
		return $tv.SelectedItem().Value.FullName
	}
}

function ProcessShortcuts($shortcuts) {

	function ConvertToTVItems($o) {
		$children = [Collections.ArrayList]::new()
		$actions = [Collections.ArrayList]::new()
		foreach ($k in ($o.Keys | Sort-Object)) {
			if ($o[$k] -is [hashtable]) {

				$children.Add(@{Name = "$k"; Children = (ConvertToTVItems $o[$k])}) | Out-Null

			} else {
				$actions.Add(@{Name = "$k"; Action = $o[$k]}) | Out-Null
			}
		}
		return $children + $actions
	}

	$tvItems = ConvertToTVItems $shortcuts

	$horizontalPercent = 0.8
	$verticalPercent = 0.8

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$tv = [TreeView]::new($tvItems, ([SimpleObjectTVItem]), $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$tv.Title = 'Select Shortcut'

	if ($tv.Run() -eq [WindowResult]::OK -and ($tv.SelectedIndex -lt $tv.Items.Count)) {
		return $tv.SelectedItem().Object().Action.Invoke()
	}
}
