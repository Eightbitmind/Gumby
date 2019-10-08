using module Log
using module Window

$fll = $null
$logFileName = "$env:TEMP\_ShowScrollView.log"
if (Test-Path $logFileName) { Remove-Item $logFileName }
$fll = [FileLogListener]::new($logFileName)
[Log]::Listeners.Add($fll) | Out-Null

$horizontalPercent = 0.5
$verticalPercent = 0.3

$width = [console]::WindowWidth * $horizontalPercent
$left = [int](([console]::WindowWidth - $width) / 2)

$height = [console]::WindowHeight * $verticalPercent
$top = [int](([console]::WindowHeight - $height) / 2)

$fc = ([console]::ForegroundColor)
$bc = ([console]::BackgroundColor)

$sv = [ScrollView]::new($left, $top, $width, $height, $bc, $fc)
$sv.Title = 'A Window'
$sv.AddLine('Saint Francis of Assisi Receiving the Stigmata is the name given to two unsigned paintings completed around 1428-1432 that art historians usually attribute to the Flemish artist Jan van Eyck.', $bc, $fc)
$sv.AddLine('The panels are nearly identical, apart from a considerable difference in size.', $bc, $fc)
$sv.AddLine('Both are small paintings: the larger measures 29.3 cm x 33.4 cm and is in the Sabauda Gallery in Turin, Italy; the smaller panel is 12.7 cm x 14.6 cm and in the Philadelphia Museum of Art.', $bc, $fc)
$sv.AddLine("The earliest documentary evidence is in the 1470 inventory of Anselme Adornes of Bruges's will; he may have owned both panels.", $bc, $fc)
$sv.AddLine('The paintings show a famous incident from the life of Saint Francis of Assisi, who is shown kneeling by a rock as he receives the stigmata of the crucified Christ on the palms of his hands and soles of his feet.', $bc, $fc)
$sv.AddLine('Behind him are rock formations, shown in great detail, and a panoramic landscape that seems to relegate the figures to secondary importance. ', $bc, $fc)
$sv.AddLine('This treatment of Francis is the first such to appear in northern Renaissance art.', $bc, $fc)
$sv.AddLine('The arguments attributing the works to van Eyck are circumstantial and based mainly on the style and quality of the panels.', $bc, $fc)
$sv.AddLine('(A later, third version is in the Museo del Prado in Madrid, but is weaker and strays significantly in tone and design.)', $bc, $fc)
$sv.AddLine("From the 19th to mid-20th centuries, most scholars attributed the two versions either to a pupil or follower of van Eyck's working from a design by the master.", $bc, $fc)
# $sv.AddLine('', $bc, $fc)
# $sv.AddLine('', $bc, $fc)

$sv.Run()

[Log]::Listeners.Remove($fll)
