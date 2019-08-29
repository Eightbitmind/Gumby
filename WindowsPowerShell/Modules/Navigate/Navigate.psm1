using module TreeView
using module Window

function SetLocationVisually($startDir = (Get-Location)) {
	$sd = Get-Item $startDir

	$horizontalPercent = 0.8
	$verticalPercent = 0.8

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$tv = [FileTreeView]::new($sd, $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$tv.Title = 'Select Folder'

	if (($tv.Run() -eq [WindowResult]::OK) -and ($tv.SelectedItemIndex -lt $tv.Items.Count)) {
		Set-Location $tv.SelectedItem().Value.FullName
	}
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

	$tv = [FileTreeView]::new($sd, $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	if ($tv.Run() -eq [WindowResult]::OK  -and ($tv.SelectedItemIndex -lt $tv.Items.Count)) {
		return $tv.SelectedItem().Value.FullName
	}
}

Export-ModuleMember -Function SetLocationVisually, SelectVisually
