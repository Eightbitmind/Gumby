using module Log
using module ListBox

$fll = $null
$logFileName = "$env:TEMP\_ShowListBox.log"
if (Test-Path $logFileName) { Remove-Item $logFileName }
$fll = [FileLogListener]::new($logFileName)
[Log]::Listeners.Add($fll) | Out-Null

$horizontalPercent = 0.3
$verticalPercent = 0.3

$width = [console]::WindowWidth * $horizontalPercent
$left = [int](([console]::WindowWidth - $width) / 2)

$height = [console]::WindowHeight * $verticalPercent
$top = [int](([console]::WindowHeight - $height) / 2)

$fc = ([console]::ForegroundColor)
$bc = ([console]::BackgroundColor)

$items =
	"Alabama",
	"Alaska",
	"Arizona",
	"Arkansas",
	"California",
	"Colorado",
	"Connecticut",
	"Delaware",
	"Florida",
	"Georgia",
	"Hawaii",
	"Idaho",
	"Illinois",
	"Indiana",
	"Iowa",
	"Kansas",
	"Kentucky",
	"Louisiana",
	"Maine",
	"Maryland",
	"Massachusettsassachusettsssachusettssachusettsachusetts",
	"Michigan",
	"Minnesota",
	"Mississippi",
	"Missouri",
	"Montana",
	"Nebraska",
	"Nevada",
	"New Hampshire",
	"New Jersey",
	"New Mexico",
	"South Dakota",
	"Washington"

$sv = [SVListBox]::new($items, $left, $top, $width, $height, $bc, $fc)
$sv.Title = "Select a state"

$sv.Run()

[Log]::Listeners.Remove($fll)