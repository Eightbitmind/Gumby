using module Gumby.Log
using module Gumby.String

class TextBuffer {
	TextBuffer(
		[System.ConsoleColor] $defaultForegroundColor = $Global:Host.UI.RawUI.ForegroundColor,
		[System.ConsoleColor] $defaultBackgroundColor = $Global:Host.UI.RawUI.BackgroundColor) {
		$this.DefaultForegroundColor = $defaultForegroundColor
		$this.DefaultBackgroundColor = $defaultBackgroundColor
	}

	[void] SetScreenBuffer(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$stripes = $this.GetStripes($targetArea, $sourceOrigin)
		foreach ($stripe in $stripes) {
			$Global:Host.UI.RawUI.SetBufferContents($stripe.Coordinates, $stripe.BufferCells)
		}
	}

	# The implementation below is an attempt to allocate a BufferCell array with a single allocation.
	# It results in about the same performance as the original implementation.
	<#
	[void] SetScreenBuffer(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$targetAreaStringList = [System.Collections.ArrayList]::new()

		$targetWidth = $targetArea.Right - $targetArea.Left + 1
		$targetHeight = $targetArea.Bottom - $targetArea.Top + 1

		for ($i = 0; $i -lt $targetHeight; ++$i) {

			if (($sourceOrigin.Y + $i -lt 0) </# above the text #/> -or 
				($sourceOrigin.Y + $i -ge $this._lines.Count) </# below the text #/> -or
				($sourceOrigin.X + $targetWidth -lt 0) </# to the left of the text #/> -or
				($sourceOrigin.X -gt $this._lines[$sourceOrigin.Y + $i].Text.Length) </# to the right of the right #/>) {
				$targetAreaString = ' ' * $targetWidth
			} else {

				$line = $this._lines[$sourceOrigin.Y + $i]

				$targetAreaString = if ($sourceOrigin.X -lt 0) {
					EnsureStringLength ((" " * -$sourceOrigin.X) + $line.Text) $targetWidth
				} else {
					EnsureStringLength $line.Text.Substring($sourceOrigin.X) $targetWidth
				}
			}
			$targetAreaStringList.Add($targetAreaString) | Out-Null
		}

		$targetAreaStringArray = $targetAreaStringList.ToArray()

		[System.Management.Automation.Host.BufferCell[,]] $bufferCells = $Global:Host.UI.RawUI.NewBufferCellArray($targetAreaStringArray, $this.DefaultForegroundColor, $this.DefaultBackgroundColor)

		# correct colors
		for ($i = 0; $i -lt $targetHeight; ++$i) {
			[Log]::Trace("TB.SetScreenBuffer.CorrectColors: i=$i")
			if ($sourceOrigin.Y + $i -lt 0) { </# above the text #/> continue }
			if ($sourceOrigin.Y + $i -ge $this._lines.Count) {</# below the text #/> break }
			$line = $this._lines[$sourceOrigin.Y + $i]
			[Log]::Trace("TB.SetScreenBuffer.CorrectColors: FC=$($line.ForegroundColor); BC=$($line.BackgroundColor)")
			for ($j = 0; $j -lt $targetWidth; ++$j) {
				#[Log]::Trace("TB.SetScreenBuffer.CorrectColors: [$i, $j].FC=$($bufferCells[$i, $j].ForegroundColor); line.FC=$($line.ForegroundColor)")
	
				# Work around the fact that calling the 'ForegroundColor' and 'BackgroundColor'
				# setters on an array element seem to have no effect.

				$temp = $bufferCells[$i, $j] 
				$temp.ForegroundColor = $line.ForegroundColor
				$temp.BackgroundColor = $line.BackgroundColor
				$bufferCells[$i, $j] = $temp

				#[Log]::Trace("TB.SetScreenBuffer.CorrectColors: [$i, $j].FC=$($bufferCells[$i, $j].ForegroundColor)")
			}
		}

		$targetOrigin = [System.Management.Automation.Host.Coordinates]::new($targetArea.Left, $targetArea.Top)
		$Global:Host.UI.RawUI.SetBufferContents($targetOrigin, $bufferCells)
	}
	#>

	# The implementation below is an attempt to allocate a BufferCell array with a single allocation.
	# It results in about the same performance as the original implementation.
	<#
	[void] SetScreenBuffer(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		# The structure of the code below is based on the fact the BufferCell.ForegroundColor and
		# BufferCell.BackgroundColor properties appear to be read-only.

		$targetAreaStringList = [System.Collections.ArrayList]::new()

		$targetWidth = $targetArea.Right - $targetArea.Left + 1
		$targetHeight = $targetArea.Bottom - $targetArea.Top + 1

		for ($i = 0; $i -lt $targetHeight; ++$i) {
			if (($sourceOrigin.Y + $i -lt 0) <!# above the text #!> -or
				($sourceOrigin.Y + $i -ge $this._lines.Count) <!# below the text #!> -or
				($sourceOrigin.X + $targetWidth -lt 0) <!# to the left of the text #!> -or
				($sourceOrigin.X -gt $this._lines[$sourceOrigin.Y + $i].Text.Length) <!# to the right of the right #!>) {

				$targetAreaString = ' ' * $targetWidth

			} else {

				$line = $this._lines[$sourceOrigin.Y + $i]

				$targetAreaString = if ($sourceOrigin.X -lt 0) {
					EnsureStringLength ((" " * -$sourceOrigin.X) + $line.Text) $targetWidth
				} else {
					EnsureStringLength $line.Text.Substring($sourceOrigin.X) $targetWidth
				}
			}
			$targetAreaStringList.Add($targetAreaString) | Out-Null
		}

		$targetAreaStringArray = $targetAreaStringList.ToArray()
		$targetOrigin = [System.Management.Automation.Host.Coordinates]::new($targetArea.Left, $targetArea.Top)
		[System.Management.Automation.Host.BufferCell[,]] $bufferCells =
			$Global:Host.UI.RawUI.NewBufferCellArray(
				$targetAreaStringArray,
				$this.DefaultForegroundColor,
				$this.DefaultBackgroundColor)
		$Global:Host.UI.RawUI.SetBufferContents($targetOrigin, $bufferCells)

		# correct colors
		for ($i = 0; $i -lt $targetHeight; ++$i) {
			if ($sourceOrigin.Y + $i -lt 0 <!# above the text #!>) { continue }
			if ($sourceOrigin.Y + $i -ge $this._lines.Count <!# below the text #!>) { break }

			$line = $this._lines[$sourceOrigin.Y + $i]

			if ($line.ForegroundColor -ne $this.DefaultForegroundColor -or
				$line.BackgroundColor -ne $this.DefaultBackgroundColor) {

				$targetOrigin = [System.Management.Automation.Host.Coordinates]::new($targetArea.Left, $targetArea.Top + $i)

				[System.Management.Automation.Host.BufferCell[,]] $bufferCells =
					$Global:Host.UI.RawUI.NewBufferCellArray(
						@($targetAreaStringArray[$i]),
						$line.ForegroundColor,
						$line.BackgroundColor)

				$Global:Host.UI.RawUI.SetBufferContents($targetOrigin, $bufferCells)
			}
		}
	}
	#>

	# for unit testing

	[object] GetStripes(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$stripes = [System.Collections.ArrayList]::new()

		$targetWidth = $targetArea.Right - $targetArea.Left + 1
		$targetHeight = $targetArea.Bottom - $targetArea.Top + 1

		for ($i = 0; $i -lt $targetHeight; ++$i) {
			$stripe = @{Coordinates = [System.Management.Automation.Host.Coordinates]::new($targetArea.Left, $targetArea.Top + $i)}

			if (($sourceOrigin.Y + $i -lt 0) <# above the text #> -or
				($sourceOrigin.Y + $i -ge $this._lines.Count) <# below the text #>) {
				$stripe.BufferCells = $Global:Host.UI.RawUI.NewBufferCellArray( @(' ' * $targetWidth), $this.DefaultForegroundColor, $this.DefaultBackgroundColor)
			} else {
				$line = $this._lines[$sourceOrigin.Y + $i]

				if (($sourceOrigin.X + $targetWidth -lt 0) <# to the left of the text #> -or
					($sourceOrigin.X -gt $line.Text.Length) <# to the right of the right#>) {
					$stripe.BufferCells = $Global:Host.UI.RawUI.NewBufferCellArray( @(' ' * $targetWidth), $line.ForegroundColor, $line.BackgroundColor)
				} else {
					$text = if ($sourceOrigin.X -lt 0) {
						EnsureStringLength ((" " * -$sourceOrigin.X) + $line.Text) $targetWidth
					} else {
						EnsureStringLength $line.Text.Substring($sourceOrigin.X) $targetWidth
					}

					$stripe.BufferCells = $Global:Host.UI.RawUI.NewBufferCellArray(@($text), $line.ForegroundColor, $line.BackgroundColor)
				}
			}
			[void] $stripes.Add($stripe)
		}

		return $stripes
	}

	[int] LineCount() { return $this._lines.Count }
	[int] ColumnCount() { return $this._lines[$this._maxLengthLineNumber].Text.Length }

	[void] AddLine([string] $text, [ConsoleColor] $foregroundColor, [ConsoleColor] $backgroundColor) {
		$i = $this._lines.Add(@{Text = $text; ForegroundColor = $foregroundColor; BackgroundColor = $backgroundColor})

		if (($this._maxLengthLineNumber -eq -1) -or ($text.Length -gt $this._lines[$this._maxLengthLineNumber].Text.Length)) {
			$this._maxLengthLineNumber = $i
		}
	}

	[void] InsertLine([int] $lineNumber, [string] $text, [ConsoleColor] $foregroundColor, [ConsoleColor] $backgroundColor) {
		if (($this._maxLengthLineNumber -eq -1) -or ($text.Length -gt $this._lines[$this._maxLengthLineNumber].Text.Length)) {
			$this._maxLengthLineNumber = $lineNumber
		}

		$this._lines.Insert($lineNumber, @{Text = $text; ForegroundColor = $foregroundColor; BackgroundColor = $backgroundColor})
	}

	[object] GetLine([int] $lineNumber) { return $this._lines[$lineNumber] }

	[void] RemoveLine([int] $lineNumber) {
		$this._lines.RemoveAt($lineNumber)
		if ($lineNumber -eq $this._maxLengthLineNumber) { $this.DetermineMaxLengthLineNumber() }
	}

	[void] ClearLines() {
		$this._lines.Clear()
		$this._maxLengthLineNumber = -1
	}

	[ConsoleColor] $DefaultForegroundColor = $Global:Host.UI.RawUI.ForegroundColor
	[ConsoleColor] $DefaultBackgroundColor = $Global:Host.UI.RawUI.BackgroundColor

	hidden [void] DetermineMaxLengthLineNumber() {
		$this._maxLengthLineNumber = -1
		$maxLength = -1
		for ($i = 0; $i -lt $this._lines.Count; ++$i) {
			if ($this._lines[$i].Text.Length -gt $maxLength) {
				$maxLength = $this._lines[$i].Text.Length
				$this._maxLengthLineNumber = $i
			}
		}
	}

	hidden [System.Collections.ArrayList] $_lines = [System.Collections.ArrayList]::new()
	hidden [int] $_maxLengthLineNumber = -1
}
