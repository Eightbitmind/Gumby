
using module ListBox

$width = 102
$height = 22

$rows = 2 * ($height - 2) # twice the height of the client area
$cols = 2 * ($width - 2) # twice the width of the client area

$items = [System.Collections.ArrayList]::new()

for ($row = 0; $row -lt $rows; ++$row) {

	$sb = [System.Text.StringBuilder]::new(2 * ($width - 2))
	$sb.AppendFormat("{0:D8}", $row) | Out-Null
	for ($col = 0; $col -lt $cols; ++$col) {
		$sb.Append([char]([int]'a'[0] + (($row + $col) % 26))) | Out-Null
	}
	$items.Add($sb.ToString()) | Out-Null
}

$lb = [ListBox]::new($items, ([StringLBItem]), 1, 1, $width, $height, [console]::BackgroundColor, [console]::ForegroundColor)
$lb.Title = "Speed Test"

# $lb.Run()

$lb.SaveOriginalWindowArea()
$lb.DrawFrame()
$lb.DrawClientArea()

$cursorDown = [System.ConsoleKeyInfo]::new(<# keyChar #> $null, <# key #> [System.ConsoleKey]::DownArrow, <# Shift #> $false, <# Alt #> $false, <# Control #> $false)
$cursorUp = [System.ConsoleKeyInfo]::new(<# keyChar #> $null, <# key #> [System.ConsoleKey]::UpArrow, <# Shift #> $false, <# Alt #> $false, <# Control #> $false)
$cursorRight = [System.ConsoleKeyInfo]::new(<# keyChar #> $null, <# key #> [System.ConsoleKey]::D, <# Shift #> $false, <# Alt #> $false, <# Control #> $false)
$cursorLeft = [System.ConsoleKeyInfo]::new(<# keyChar #> $null, <# key #> [System.ConsoleKey]::A, <# Shift #> $false, <# Alt #> $false, <# Control #> $false)

$verticalScrollSteps = $rows - 1
$horizontalScrollSteps = $cols - 1

$startTime = [datetime]::Now

for ($rep = 0; $rep -lt 5; ++$rep) {

	for ($i = 0; $i -lt $verticalScrollSteps; ++$i) {
		$lb.OnKey($cursorDown)
	}

	# for ($i = 0; $i -lt $horizontalScrollSteps; ++$i) {
	# 	$lb.OnKey($cursorRight)
	# }

	for ($i = 0; $i -lt $verticalScrollSteps; ++$i) {
		$lb.OnKey($cursorUp)
	}

	# for ($i = 0; $i -lt $horizontalScrollSteps; ++$i) {
	# 	$lb.OnKey($cursorLeft)
	# }
}

$endTime = [datetime]::Now

$lb.RestoreOriginalWindowArea()

$duration = $endTime - $startTime
Write-Host "start time: $startTime"
Write-Host "end time: $endTime"
Write-Host "duration: $duration"
