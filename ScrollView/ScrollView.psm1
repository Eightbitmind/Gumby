using module Gumby.Debug
using module Gumby.Log
using module Gumby.TextBuffer
using module Gumby.Window

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

	hidden [void] DrawLine([int] $lineNumber) {
		Assert ($lineNumber -ge $this.FirstRowInView) "trying to draw a line that is scrolled out of view"

		$lineRect = $this.ClientRectangle()
		$lineRect.Top += ($lineNumber - $this.FirstRowInView)
		$lineRect.Bottom = $lineRect.Top

		$this._textBuffer.SetScreenBuffer($lineRect, [System.Management.Automation.Host.Coordinates]::new($this.FirstColumnInView, $lineNumber))
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
