using module Assert
using module Log
using module Math
using module String

enum WindowResult {
	OK
	Cancel
}

class Window {
	Window(
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		
		[System.ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[System.ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor) {
		$this._rect = [System.Management.Automation.Host.Rectangle]::new(
			[console]::WindowLeft + $left,
			[console]::WindowTop + $top,
			[console]::WindowLeft + $left + $width - 1,
			[console]::WindowTop + $top + $height - 1)
		$this._foregroundColor = $foregroundColor
		$this._backgroundColor = $backgroundColor
	}

	[System.Management.Automation.Host.Coordinates] WindowCoordinates() {
		return [System.Management.Automation.Host.Coordinates]::new($this._rect.left, $this._rect.Top)
	}

	[System.Management.Automation.Host.Rectangle] WindowRectangle() {
		return $this._rect
	}

	[int] WindowWidth() {
		return $this._rect.Right - $this._rect.Left + 1;
	}

	[int] WindowHeight() {
		return $this._rect.Bottom - $this._rect.Top + 1;
	}

	[System.Management.Automation.Host.Coordinates] ClientCoordinates() {
		return [System.Management.Automation.Host.Coordinates]::new($this._rect.left + 1, $this._rect.Top + 1)
	}

	[System.Management.Automation.Host.Rectangle] ClientRectangle() {
		return [System.Management.Automation.Host.Rectangle]::new($this._rect.Left + 1, $this._rect.Top + 1, $this._rect.Right - 1, $this._rect.Bottom - 1)
	}

	[int] ClientWidth() {
		return $this._rect.Right - $this._rect.Left - 1;
	}

	[int] ClientHeight() {
		return $this._rect.Bottom - $this._rect.Top - 1;
	}

	[System.Management.Automation.Host.Coordinates] GetClientCoordinates([int] $x, [int] $y) {
		[int] $absX = $this._rect.Left + 1 + $x
		[int] $absY = $this._rect.Top + 1 + $y
		return [System.Management.Automation.Host.Coordinates]::new($absX, $absY)
	}

	[System.ConsoleColor] ForegroundColor() {
		return $this._foregroundColor
	}

	[System.ConsoleColor] BackgroundColor() {
		return $this._backgroundColor
	}

	[void] WriteLine([int] $lineNumber, [string] $text, $foregroundColor, $backgroundColor) {
		assert ($lineNumber -lt $this.ClientHeight()) "line number outside of client area"
		[System.Management.Automation.Host.BufferCell[,]] $buffer = 
			$Global:Host.UI.RawUI.NewBufferCellArray(
				@(EnsureStringLength $text $this.ClientWidth()),
				$foregroundColor, $backgroundColor)

		$Global:Host.UI.RawUI.SetBufferContents($this.GetClientCoordinates(0, $lineNumber), $buffer)
	}

	[void] WriteStatusBar($text) {
		$windowWidth = $this.WindowWidth()
		$t = $text.Substring(0, [math]::Min($text.Length, $windowWidth - 4))
		$cell = [System.Management.Automation.Host.BufferCell]::new(' ', $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		[System.Management.Automation.Host.BufferCell[,]] $buffer = $Global:Host.UI.RawUI.NewBufferCellArray($windowWidth - 2, 1, $cell)

		$hBar = [System.Management.Automation.Host.BufferCell]::new([char]0x2500, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$t90 = [System.Management.Automation.Host.BufferCell]::new([char]0x2524, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$t270 = [System.Management.Automation.Host.BufferCell]::new([char]0x251C, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))

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
		for ($i = 0; $i -lt $a; ++$i) { $buffer[0, $x++] = $hBar }
		$buffer[0, $x++]= $t90
		for ($i = 0; $i -lt $t.Length; ++$i) {
			$buffer[0, $x++] = [System.Management.Automation.Host.BufferCell]::new($t[$i], $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		}
		$buffer[0, $x++]= $t270
		for ($i = 0; $i -lt $b; ++$i) { $buffer[0, $x++] = $hBar }

		$p = [System.Management.Automation.Host.Coordinates]::new($this._rect.Left + 1, $this._rect.Bottom)
		$Global:Host.UI.RawUI.SetBufferContents($p, $buffer)
	}

	[void] ScrollAreaVertically([UInt32] $top, [UInt32] $bottom, [int] $amount) {
		[System.Management.Automation.Host.Rectangle] $source = $this.ClientRectangle()
		$bufferTop = $source.Top + $top
		$bufferBottom = $source.Top + $bottom
		$source.Top = $bufferTop
		$source.Bottom = $bufferBottom

		[System.Management.Automation.Host.Rectangle] $clip = $this.ClientRectangle()

		[System.Management.Automation.Host.Coordinates] $destination = $this.GetClientCoordinates(0, $top + $amount)

		[System.Management.Automation.Host.BufferCell] $fill = [System.Management.Automation.Host.BufferCell]::new(' ', $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))

		$Global:Host.UI.RawUI.ScrollBufferContents($source, $destination, $clip, $fill)
	}

	[WindowResult] Run() {
		$this.SaveOriginalWindowArea()
		$this.DrawFrame()
		$this.DrawClientArea()
		$this.OnShown()

		while ($this._running) {
			$this.OnKey([console]::ReadKey([System.Management.Automation.Host.ReadKeyOptions]::NoEcho))
		}

		$this.RestoreOriginalWindowArea()

		return $this.Result
	}

	hidden [void] DrawFrame() {
		$windowWidth = $this.WindowWidth()
		$windowHeight = $this.WindowHeight()

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

		$cell = [System.Management.Automation.Host.BufferCell]::new(' ', $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete))
		[System.Management.Automation.Host.BufferCell[,]] $buffer = $Global:Host.UI.RawUI.NewBufferCellArray($windowWidth, $windowHeight, $cell)

		$horizontalBar = [System.Management.Automation.Host.BufferCell]::new([char]0x2500, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$verticalBar = [System.Management.Automation.Host.BufferCell]::new([char]0x2502, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$topLeftCorner = [System.Management.Automation.Host.BufferCell]::new([char]0x250C, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$topRightCorner = [System.Management.Automation.Host.BufferCell]::new([char]0x2510, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$bottomLeftCorner = [System.Management.Automation.Host.BufferCell]::new([char]0x2514, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$bottomRightCorner = [System.Management.Automation.Host.BufferCell]::new([char]0x2518, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$t90 = [System.Management.Automation.Host.BufferCell]::new([char]0x2524, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))
		$t270 = [System.Management.Automation.Host.BufferCell]::new([char]0x251C, $this._foregroundColor, $this._backgroundColor, ([System.Management.Automation.Host.BufferCellType]::Complete))

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
			for ($i = 0; $i -lt $a; ++$i) { $buffer[0, $x++] = $horizontalBar }
			$buffer[0, $x++]= $t90
			for ($i = 0; $i -lt $t.Length; ++$i) {
				$buffer[0, $x++] = [System.Management.Automation.Host.BufferCell]::new($t[$i], $this._foregroundColor, $this._backgroundColor, ([Management.Automation.Host.BufferCellType]::Complete))
			}
			$buffer[0, $x++]= $t270
			for ($i = 0; $i -lt $b; ++$i) { $buffer[0, $x++] = $horizontalBar }
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

	hidden [void] SaveOriginalWindowArea() {
		$this._originalBufferContent = $Global:Host.UI.RawUI.GetBufferContents($this._rect)
	}
	hidden [void] RestoreOriginalWindowArea() {
		$Global:Host.UI.RawUI.SetBufferContents($this.WindowCoordinates(), $this._originalBufferContent)
	}

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
	hidden [System.Management.Automation.Host.Rectangle] $_rect
	hidden [System.ConsoleColor] $_foregroundColor
	hidden [System.ConsoleColor] $_backgroundColor
	hidden [System.Management.Automation.Host.BufferCell[,]] $_originalBufferContent
}
