using module String

class TextBuffer {
	TextBuffer(
		[System.ConsoleColor] $defaultForegroundColor = $Global:Host.UI.RawUI.ForegroundColor,
		[System.ConsoleColor] $defaultBackgroundColor = $Global:Host.UI.RawUI.BackgroundColor) {
		$this.DefaultForegroundColor = $defaultForegroundColor
		$this.DefaultBackgroundColor = $defaultBackgroundColor
	}

	# Can we speed things up by doing buffer "block" operations instead?
	#   $cell = [System.Management.Automation.Host.BufferCell]::new(' ', $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete))
	#   [System.Management.Automation.Host.BufferCell[,]] $buffer = $Global:Host.UI.RawUI.NewBufferCellArray($windowWidth, $windowHeight, $cell)
	#   $buffer[($this._rect.Bottom - $this._rect.Top), $i] = $horizontalBar
	#   $Global:Host.UI.RawUI.SetBufferContents($this.WindowCoordinates(), $buffer)
	# Unlikely if we'd have to make individual BufferCell allocations for every character - but what
	# if we'd assign to the 'Character' property of the block-allocated BufferCell array?

	[void] SetScreenBuffer(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$stripes = $this.GetStripes($targetArea, $sourceOrigin)
		foreach ($stripe in $stripes) {
			$Global:Host.UI.RawUI.SetBufferContents($stripe.Coordinates, $stripe.BufferCells)
		}
	}

	# for unit testing

	[object] GetStripes(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$stripes = [System.Collections.ArrayList]::new()

		$targetWidth = $targetArea.Right - $targetArea.Left + 1
		$targetHeight = $targetArea.Bottom - $targetArea.Top + 1

		for ($i = 0; $i -lt $targetHeight; ++$i) {
			$stripe = @{Coordinates = [System.Management.Automation.Host.Coordinates]::new($targetArea.Left, $targetArea.Top + $i)}
			$line = $this._lines[$sourceOrigin.Y + $i]

			if (($sourceOrigin.Y + $i -lt 0) <# above the text #> -or 
				($sourceOrigin.Y + $i -ge $this._lines.Count) <# below the text #> -or
				($sourceOrigin.X + $targetWidth -lt 0) <# to the left of the text #> -or
				($sourceOrigin.X -gt $line.Text.Length) <# to the right of the right#>) {
				$stripe.BufferCells = $Global:Host.UI.RawUI.NewBufferCellArray( @(' ' * $targetWidth), $this.DefaultForegroundColor, $this.DefaultBackgroundColor)
			} else {
				$text = if ($sourceOrigin.X -lt 0) {
					EnsureStringLength ((" " * -$sourceOrigin.X) + $line.Text) $targetWidth
				} else {
					EnsureStringLength $line.Text.Substring($sourceOrigin.X) $targetWidth
				}

				$stripe.BufferCells = $Global:Host.UI.RawUI.NewBufferCellArray(@($text), $line.ForegroundColor, $line.BackgroundColor)
			}
			$stripes.Add($stripe) | Out-Null
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
