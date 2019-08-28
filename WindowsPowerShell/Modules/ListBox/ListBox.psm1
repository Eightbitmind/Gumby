using module Window

class ListBox : Window {
	ListBox(
		[System.Collections.ICollection] $items,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {
		$this.Items = $items
	}

	[object] SelectedItem() {
		return $this.Items[$this.SelectedItemIndex]
	}

	[void] OnShown() {
		for ($i = 0; $i -lt [Math]::Min($this.Items.Count, $this.ClientHeight()); ++$i) {

			if ($i -eq $this.SelectedItemIndex) {
				$fc = $this._backgroundColor
				$bc = $this._foregroundColor
			} else {
				$fc = $this._foregroundColor
				$bc = $this._backgroundColor
			}

			$this.WriteLine($i, $this.Items[$i], $fc, $bc)
		}

		$si = if ($this.Items.Count -gt 0) { $this.SelectedItemIndex + 1 } else { 0 }

		$this.WriteStatusBar("$si/$($this.Items.Count)")
		([Window]$this).OnShown()
	}

	[void] OnKey([System.ConsoleKeyInfo] $key) {
		#$key.Key
		#$key.KeyChar
		#$key.Modifiers

		switch ($key.Key) {
			([ConsoleKey]::DownArrow) {
				if ($this.Items.Count -eq 0) {
					# empty list
					break
				}

				if ($this.SelectedItemIndex -eq ($this.Items.Count - 1)) {
					# at end of list, no change
					break
				}

				# unselect currently selected line
				$this.WriteLine($this.SelectedItemIndex - $this._firstIndexInView, $this.GetItemLabel($this.SelectedItemIndex) , $this._foregroundColor, $this._backgroundColor)

				if (($this.SelectedItemIndex - $this._firstIndexInView) -ge ($this.ClientHeight() - 1)) {
					# last line is selected, scroll up one line
					$this.ScrollAreaVertically(0, $this.ClientHeight() - 1, -1)
					++$this._firstIndexInView
					# display next line
					$this.WriteLine($this.ClientHeight() - 1, $this.GetItemLabel($this.SelectedItemIndex + 1), $this._backgroundColor, $this._foregroundColor)
				} else {
					$this.WriteLine($this.SelectedItemIndex - $this._firstIndexInView + 1, $this.GetItemLabel($this.SelectedItemIndex + 1) , $this._backgroundColor, $this._foregroundColor)
				}

				++$this.SelectedItemIndex

				$this.WriteStatusBar("$($this.SelectedItemIndex + 1)/$($this.Items.Count)")
			}

			([ConsoleKey]::UpArrow) {
				if ($this.SelectedItemIndex -eq 0) {
					# at start of list, no change
					# also handles empty list
					break
				}

				# unselect currently selected line
				$this.WriteLine($this.SelectedItemIndex - $this._firstIndexInView, $this.GetItemLabel($this.SelectedItemIndex) , $this._foregroundColor, $this._backgroundColor)

				if ($this.SelectedItemIndex -eq $this._firstIndexInView) {
					# first line is selected, scroll down one line
					$this.ScrollAreaVertically(0, $this.ClientHeight() - 1, 1)
					--$this._firstIndexInView
					# display next line
					$this.WriteLine(0, $this.GetItemLabel($this.SelectedItemIndex - 1), $this._backgroundColor, $this._foregroundColor)
				} else {
					$this.WriteLine($this.SelectedItemIndex - $this._firstIndexInView - 1, $this.GetItemLabel($this.SelectedItemIndex - 1) , $this._backgroundColor, $this._foregroundColor)
				}

				--$this.SelectedItemIndex

				$this.WriteStatusBar("$($this.SelectedItemIndex + 1)/$($this.Items.Count)")
			}

			default {
				([Window]$this).OnKey($key)
			}
		}
	}

	[string] GetItemLabel($itemIndex) {
		return $this.Items[$itemIndex]
	}

	[System.Collections.ICollection] $Items
	[int] $SelectedItemIndex = 0
	[int] hidden $_firstIndexInView = 0
}
