using module Assert
using module Log
using module Math
using module String

enum WindowResult {
	OK
	Cancel
}

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

	# for unit testing

	[object] GetStripes(
		[System.Management.Automation.Host.Rectangle] $targetArea,
		[System.Management.Automation.Host.Coordinates] $sourceOrigin) {

		$stripes = New-Object Collections.ArrayList

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

class Window {
	Window(
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor) {
		$this._rect = New-Object System.Management.Automation.Host.Rectangle ([console]::WindowLeft + $left), ([console]::WindowTop + $top), ([console]::WindowLeft + $left + $width - 1), ([console]::WindowTop + $top + $height - 1)
		$this._foregroundColor = $foregroundColor
		$this._backgroundColor = $backgroundColor
	}

	[Management.Automation.Host.Coordinates] WindowCoordinates() {
		return [System.Management.Automation.Host.Coordinates]::new($this._rect.left, $this._rect.Top)
	}

	[Management.Automation.Host.Rectangle] WindowRectangle() {
		return $this._rect
	}

	[Management.Automation.Host.Coordinates] ClientCoordinates() {
		return (New-Object System.Management.Automation.Host.Coordinates $this._rect.left + 1, $this._rect.Top + 1)
	}

	[Management.Automation.Host.Rectangle] ClientRectangle() {
		return (New-Object System.Management.Automation.Host.Rectangle ($this._rect.Left + 1), ($this._rect.Top + 1), ($this._rect.Right - 1), ($this._rect.Bottom - 1))
	}

	[int] ClientWidth() {
		return $this._rect.Right - $this._rect.Left - 1;
	}

	[int] ClientHeight() {
		return $this._rect.Bottom - $this._rect.Top - 1;
	}

	[Management.Automation.Host.Coordinates] GetClientCoordinates([int] $x, [int] $y) {
		[int] $absX = $this._rect.Left + 1 + $x
		[int] $absY = $this._rect.Top + 1 + $y
		return (New-Object System.Management.Automation.Host.Coordinates $absX, $absY)
	}

	[System.ConsoleColor] ForegroundColor() {
		return $this._foregroundColor
	}

	[System.ConsoleColor] BackgroundColor() {
		return $this._backgroundColor
	}

	[void] WriteLine([int] $y, [string] $text, $foregroundColor, $backgroundColor) {
		assert ($y -lt ($this._rect.Bottom - $this._rect.Top - 1)) "line index outside of client area"
		[Management.Automation.Host.BufferCell[,]] $buffer = 
			$Global:Host.UI.RawUI.NewBufferCellArray(
				@(EnsureStringLength $text ($this._rect.Right - $this._rect.Left - 1)),
				$foregroundColor, $backgroundColor)

		$Global:Host.UI.RawUI.SetBufferContents($this.GetClientCoordinates(0, $y), $buffer)
	}

	[void] WriteStatusBar($text) {
		$windowWidth = $this._rect.Right - $this._rect.Left + 1
		$t = $text.Substring(0, [math]::Min($text.Length, $windowWidth - 4))
		$cell = New-Object System.Management.Automation.Host.BufferCell ' ', $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		[Management.Automation.Host.BufferCell[,]] $buffer = $Global:Host.UI.RawUI.NewBufferCellArray($windowWidth - 2, 1, $cell)

		$hBar = New-Object System.Management.Automation.Host.BufferCell ([char]0x2500), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$t90 = New-Object System.Management.Automation.Host.BufferCell ([char]0x2524), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$t270 = New-Object System.Management.Automation.Host.BufferCell ([char]0x251C), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)

		[int] $a = 0
		[int] $b = 0

		if (IsEven $windowWidth) {
			if (IsEven $t.Length) {
				# 01234567890123456789
				# └──────┤abcd├──────┘
				$a = $b = ($windowWidth - 4 - $t.Length) / 2
			} else {
				# 01234567890123456789
				# └──────┤abc├───────┘

				# Note that in Powershell, casting to integer performs banker's rounding.
				$a = [Math]::Truncate(($windowWidth - 4 - $t.Length) / 2)
				$b = [Math]::Truncate(($windowWidth - 3 - $t.Length) / 2)
			}
		} else { # odd window width
			if (IsEven $t.Length) {
				# 0123456789012345678
				# └─────┤abcd├──────┘
				$a = [Math]::Truncate(($windowWidth - 4 - $t.Length) / 2)
				$b = [Math]::Truncate(($windowWidth - 3 - $t.Length) / 2)
			} else {
				# 0123456789012345678
				# └──────┤abc├──────┘
				$a = $b = ($windowWidth - 4 - $t.Length) / 2
			}
		}

		$x = 0
		for($i = 0; $i -lt $a; ++$i) { $buffer[0, $x++] = $hBar }
		$buffer[0, $x++]= $t90
		for($i = 0; $i -lt $t.Length; ++$i) { $buffer[0, $x++] = (New-Object System.Management.Automation.Host.BufferCell ($t[$i]), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)) }
		$buffer[0, $x++]= $t270
		for($i = 0; $i -lt $b; ++$i) { $buffer[0, $x++] = $hBar }

		$p = New-Object System.Management.Automation.Host.Coordinates ($this._rect.Left + 1), $this._rect.Bottom
		$Global:Host.UI.RawUI.SetBufferContents($p, $buffer)
	}

	[void] ScrollAreaVertically([UInt32] $top, [UInt32] $bottom, [int] $amount) {
		[Management.Automation.Host.Rectangle] $source = $this.ClientRectangle()
		$bufferTop = $source.Top + $top
		$bufferBottom = $source.Top + $bottom
		$source.Top = $bufferTop
		$source.Bottom = $bufferBottom

		[Management.Automation.Host.Rectangle] $clip = $this.ClientRectangle()

		[Management.Automation.Host.Coordinates] $destination = $this.GetClientCoordinates(0, $top + $amount)

		[Management.Automation.Host.BufferCell] $fill = New-Object System.Management.Automation.Host.BufferCell ' ', $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)

		$Global:Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $fill)
	}

	[WindowResult] Run() {
		$this._originalBufferContent = $Global:Host.UI.RawUI.GetBufferContents($this._rect)
		$this.DrawFrame()
		$this.DrawClientArea()
		$this.OnShown()

		while ($this._running) {
			$this.OnKey([console]::ReadKey([Management.Automation.Host.ReadKeyOptions]::NoEcho))
		}

		$Global:Host.UI.RawUI.SetBufferContents($this.WindowCoordinates(), $this._originalBufferContent)
		return $this.Result
	}

	hidden [void] DrawFrame() {
		$windowWidth = $this._rect.Right - $this._rect.Left + 1
		$windowHeight = $this._rect.Bottom - $this._rect.Top + 1

		<#
		0x2500: ─
		0x2501: ━
		0x2502: │
		0x2503: ┃
		0x2504: ┄
		0x2505: ┅
		0x2506: ┆
		0x2507: ┇
		0x2508: ┈
		0x2509: ┉
		0x250A: ┊
		0x250B: ┋
		0x250C: ┌
		0x250D: ┍
		0x250E: ┎
		0x250F: ┏
		0x2510: ┐
		0x2511: ┑
		0x2512: ┒
		0x2513: ┓
		0x2514: └
		0x2515: ┕
		0x2516: ┖
		0x2517: ┗
		0x2518: ┘
		0x2519: ┙
		0x251A: ┚
		0x251B: ┛
		0x251C: ├
		0x251D: ┝
		0x251E: ┞
		0x251F: ┟
		0x2520: ┠
		0x2521: ┡
		0x2522: ┢
		0x2523: ┣
		0x2524: ┤
		0x2525: ┥
		0x2526: ┦
		0x2527: ┧
		0x2528: ┨
		0x2529: ┩
		0x252A: ┪
		0x252B: ┫
		0x252C: ┬
		0x252D: ┭
		0x252E: ┮
		0x252F: ┯
		0x2530: ┰
		0x2531: ┱
		0x2532: ┲
		0x2533: ┳
		0x2534: ┴
		0x2535: ┵
		0x2536: ┶
		0x2537: ┷
		0x2538: ┸
		0x2539: ┹
		0x253A: ┺
		0x253B: ┻
		0x253C: ┼
		0x253D: ┽
		0x253E: ┾
		0x253F: ┿
		0x2540: ╀
		0x2541: ╁
		0x2542: ╂
		0x2543: ╃
		0x2544: ╄
		0x2545: ╅
		0x2546: ╆
		0x2547: ╇
		0x2548: ╈
		0x2549: ╉
		0x254A: ╊
		0x254B: ╋
		0x254C: ╌
		0x254D: ╍
		0x254E: ╎
		0x254F: ╏
		0x2550: ═
		0x2551: ║
		0x2552: ╒
		0x2553: ╓
		0x2554: ╔
		0x2555: ╕
		0x2556: ╖
		0x2557: ╗
		0x2558: ╘
		0x2559: ╙
		0x255A: ╚
		0x255B: ╛
		0x255C: ╜
		0x255D: ╝
		0x255E: ╞
		0x255F: ╟
		0x2560: ╠
		0x2561: ╡
		0x2562: ╢
		0x2563: ╣
		0x2564: ╤
		0x2565: ╥
		0x2566: ╦
		0x2567: ╧
		0x2568: ╨
		0x2569: ╩
		0x256A: ╪
		0x256B: ╫
		0x256C: ╬
		0x256D: ╭
		0x256E: ╮
		0x256F: ╯
		0x2570: ╰
		0x2571: ╱
		0x2572: ╲
		0x2573: ╳
		0x2574: ╴
		0x2575: ╵
		0x2576: ╶
		0x2577: ╷
		0x2578: ╸
		0x2579: ╹
		0x257A: ╺
		0x257B: ╻
		0x257C: ╼
		0x257D: ╽
		0x257E: ╾
		#>

		$cell = New-Object System.Management.Automation.Host.BufferCell ' ', $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		[Management.Automation.Host.BufferCell[,]] $buffer = $Global:Host.UI.RawUI.NewBufferCellArray($windowWidth, $windowHeight, $cell)

		$horizontalBar = New-Object System.Management.Automation.Host.BufferCell ([char]0x2500), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$verticalBar = New-Object System.Management.Automation.Host.BufferCell ([char]0x2502), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$topLeftCorner = New-Object System.Management.Automation.Host.BufferCell ([char]0x250C), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$topRightCorner = New-Object System.Management.Automation.Host.BufferCell ([char]0x2510), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$bottomLeftCorner = New-Object System.Management.Automation.Host.BufferCell ([char]0x2514), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$bottomRightCorner = New-Object System.Management.Automation.Host.BufferCell ([char]0x2518), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$t90 = New-Object System.Management.Automation.Host.BufferCell ([char]0x2524), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)
		$t270 = New-Object System.Management.Automation.Host.BufferCell ([char]0x251C), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)

		if ($this.Title) {
			assert ($this.Title.Length -lt ($windowWidth - 3)) "title too wide for window"
			$t = $this.Title.Substring(0, [math]::Min($this.Title.Length, $windowWidth - 4))

			#  <-a-> <-l-> <-b-->
			# ┌─────┤abcde├──────┐
			[int] $a = 0
			[int] $b = 0

			if (IsEven $windowWidth) {
				if (IsEven $t.Length) {
					# 01234567890123456789
					# ┌──────┤abcd├──────┐
					$a = $b = ($windowWidth - 4 - $t.Length) / 2
				} else {
					# 01234567890123456789
					# ┌──────┤abc├───────┐
					$a = [int](($windowWidth - 4 - $t.Length) / 2)
					$b = [int](($windowWidth - 3 - $t.Length) / 2)
				}
			} else { # odd window width
				if (IsEven $t.Length) {
					# 0123456789012345678
					# ┌─────┤abcd├──────┐
					$a = [int](($windowWidth - 4 - $t.Length) / 2)
					$b = [int](($windowWidth - 3 - $t.Length) / 2)
				} else {
					# 0123456789012345678
					# ┌──────┤abc├──────┐
					$a = $b = ($windowWidth - 4 - $t.Length) / 2
				}
			}

			$x = 1
			for($i = 0; $i -lt $a; ++$i) { $buffer[0, $x++] = $horizontalBar }
			$buffer[0, $x++]= $t90
			for($i = 0; $i -lt $t.Length; ++$i) { $buffer[0, $x++] = (New-Object System.Management.Automation.Host.BufferCell ($t[$i]), $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete)) }
			$buffer[0, $x++]= $t270
			for($i = 0; $i -lt $b; ++$i) { $buffer[0, $x++] = $horizontalBar }
		} else {
			for ($i = 1; $i -lt ($this._rect.Right - $this._rect.Left); ++$i) { $buffer[0, $i] = $horizontalBar }
		}

		for ($i = 1; $i -lt ($this._rect.Right - $this._rect.Left); ++$i) { $buffer[($this._rect.Bottom - $this._rect.Top), $i] = $horizontalBar }
		for ($i = 1; $i -lt ($this._rect.Bottom - $this._rect.Top); ++$i) { $buffer[$i, 0] = $verticalBar }
		for ($i = 1; $i -lt ($this._rect.Bottom - $this._rect.Top); ++$i) { $buffer[$i, ($this._rect.Right - $this._rect.Left)] = $verticalBar }

		$buffer[0, 0] = $topLeftCorner
		$buffer[0, ($this._rect.Right - $this._rect.Left)] = $topRightCorner
		$buffer[($this._rect.Bottom - $this._rect.Top), 0] = $bottomLeftCorner
		$buffer[($this._rect.Bottom - $this._rect.Top), ($this._rect.Right - $this._rect.Left)] = $bottomRightCorner

		$Global:Host.UI.RawUI.SetBufferContents($this.WindowCoordinates(), $buffer)
	}

	hidden [void] DrawClientArea() {}

	hidden [void] OnShown() {}

	hidden [void] OnKey([System.ConsoleKeyInfo] $key) {
		# [Log]::Comment("Window.OnKey: Key=$($key.Key), Modifiers=$($key.Modifiers), KeyChar=$($key.KeyChar)")

		# We do not receive:
		#   Alt+Home
		#   Ctrl+Home
		#   Shift+Home
		#   Alt+(Left|Right|Up|Down)
		#   Ctrl+(Left|Right|Up|Down)
		#   Shift+(Left|Right|Up|Down)

		switch ($key.Key) {
			([ConsoleKey]::Escape) {
				$this._running = $false
				$this.Result = [WindowResult]::Cancel
			}

			([ConsoleKey]::Enter) {
				$this._running = $false
				$this.Result = [WindowResult]::OK
			}
		}
	}

	[WindowResult] $Result = [WindowResult]::OK

	[string] $Title = $null

	hidden [bool] $_running = $true
	hidden [Management.Automation.Host.Rectangle] $_rect
	hidden [System.ConsoleColor] $_foregroundColor
	hidden [System.ConsoleColor] $_backgroundColor
	hidden [Management.Automation.Host.BufferCell[,]] $_originalBufferContent
}

class ScrollView : Window {
	ScrollView(
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {

		$this._textBuffer = [TextBuffer]::new($foregroundColor, $backgroundColor)
	}

	[int] $FirstColumnInView = 0
	[int] $FirstRowInView = 0

	[int] LineCount() { return $this._textBuffer.LineCount() }

	[void] AddLine([string] $text, [ConsoleColor] $foregroundColor, [ConsoleColor] $backgroundColor) {
		$this._textBuffer.AddLine($text, $foregroundColor, $backgroundColor)
	}

	[void] InsertLine([int] $lineNumber, [string] $text, [ConsoleColor] $foregroundColor, [ConsoleColor] $backgroundColor) {
		# FirstRowInView should remain valid under all circumstances
		$this._textBuffer.InsertLine($lineNumber, $text, $foregroundColor, $backgroundColor)
	}

	[object] GetLine([int] $lineNumber) {
		return $this._textBuffer.GetLine($lineNumber)
	}

	[void] RemoveLine([int] $lineNumber) {
		# if FirstRowInView < LineCount - 1:
		#     if lineNumber <= FirstRowInView: line removal causes FirstRowInView to point to the next line
		#     if lineNumber > FirstRowInView: line removal does not affect validity of FirstRowInView
		if ($this.FirstRowInView -eq ($this.LineCount() - 1)) { $this.FirstRowInView = -1 }

		$this._textBuffer.RemoveLine($lineNumber)
	}

	[void] ClearLines() {
		$this._textBuffer.ClearLines()
		$this.FirstColumnInView = 0
		$this.FirstRowInView = 0
	}

	hidden [void] DrawClientArea() {
		$this._textBuffer.SetScreenBuffer($this.ClientRectangle(), [System.Management.Automation.Host.Coordinates]::new($this.FirstColumnInView, $this.FirstRowInView))
	}

	hidden [void] OnKey([System.ConsoleKeyInfo] $key) {
		#[Log]::Comment("SV.OnKey: Key=$($key.Key), Modifiers=$($key.Modifiers)")
		switch ($key.Key) {
			([System.ConsoleKey]::A) {
				if ($this.FirstColumnInView -eq 0) { break }
				--$this.FirstColumnInView
				$this.DrawClientArea()
			}

			([System.ConsoleKey]::D) {
				if ($this.FirstColumnInView + $this.ClientWidth() -eq $this._textBuffer.ColumnCount()) { break }
				++$this.FirstColumnInView
				$this.DrawClientArea()
			}

			([System.ConsoleKey]::W) {
				if ($this.FirstRowInView -eq 0) { break }
				--$this.FirstRowInView
				$this.DrawClientArea()
			}

			([System.ConsoleKey]::X) {
				if ($this.FirstRowInView + $this.ClientHeight() -eq $this._textBuffer.LineCount()) { break }
				++$this.FirstRowInView
				$this.DrawClientArea()
			}

			([System.ConsoleKey]::Home) {
				# We do not receive Alt+Home, Ctrl+Home and Shift+Home :(
				$this.FirstColumnInView = 0
				if ($key.Modifiers -eq ([System.ConsoleModifiers]::Control)) {
					$this.FirstRowInView = 0
				}
				$this.DrawClientArea()
			}

			# Alternative for 'Home' key to enable modifier key combinations.
			([System.ConsoleKey]::Q) {
				$this.FirstColumnInView = 0
				if ($key.Modifiers -eq ([System.ConsoleModifiers]::Control)) {
					$this.FirstRowInView = 0
				}
				$this.DrawClientArea()
			}

			([System.ConsoleKey]::End) {
				# We do not receive Alt+End, Ctrl+End and Shift+End :(
				$this.FirstColumnInView = [System.Math]::Max(0, $this._textBuffer.ColumnCount() - $this.ClientWidth())
				$this.FirstRowInView = [System.Math]::Max(0, $this._textBuffer.LineCount() - $this.ClientHeight())
				$this.DrawClientArea()
			}

			# Alternative for 'End' key to enable modifier key combinations.
			([System.ConsoleKey]::Z) {
				$this.FirstColumnInView = [System.Math]::Max(0, $this._textBuffer.ColumnCount() - $this.ClientWidth())
				if ($key.Modifiers -eq ([System.ConsoleModifiers]::Control)) {
					$this.FirstRowInView = [System.Math]::Max(0, $this._textBuffer.LineCount() - $this.ClientHeight())
				}
				$this.DrawClientArea()
			}

			default {
				([Window]$this).OnKey($key)
			}
		}
	}

	hidden [TextBuffer] $_textBuffer
}
