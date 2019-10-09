using module Window

class LBItemBase {
	[string] Name() { throw "abstract" }
	[object] Value() { throw "abstract" }
}

class StringLBItem {
	StringLBItem([string] $value) {
		$this._value = $value
	}

	[string] Name() { return $this._value }
	[string] Value() { return $this._value }

	hidden [string] $_value
}


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
		return $this.Items[$this.SelectedIndex]
	}

	[void] OnShown() {
		for ($i = 0; $i -lt [Math]::Min($this.Items.Count, $this.ClientHeight()); ++$i) {

			if ($i -eq $this.SelectedIndex) {
				$fc = $this._backgroundColor
				$bc = $this._foregroundColor
			} else {
				$fc = $this._foregroundColor
				$bc = $this._backgroundColor
			}

			$this.WriteLine($i, $this.Items[$i], $fc, $bc)
		}

		$si = if ($this.Items.Count -gt 0) { $this.SelectedIndex + 1 } else { 0 }

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

				if ($this.SelectedIndex -eq ($this.Items.Count - 1)) {
					# at end of list, no change
					break
				}

				# unselect currently selected line
				$this.WriteLine($this.SelectedIndex - $this.FirstIndexInView, $this.GetItemLabel($this.SelectedIndex) , $this._foregroundColor, $this._backgroundColor)

				if (($this.SelectedIndex - $this.FirstIndexInView) -ge ($this.ClientHeight() - 1)) {
					# last line is selected, scroll up one line
					$this.ScrollAreaVertically(0, $this.ClientHeight() - 1, -1)
					++$this.FirstIndexInView
					# display next line
					$this.WriteLine($this.ClientHeight() - 1, $this.GetItemLabel($this.SelectedIndex + 1), $this._backgroundColor, $this._foregroundColor)
				} else {
					$this.WriteLine($this.SelectedIndex - $this.FirstIndexInView + 1, $this.GetItemLabel($this.SelectedIndex + 1) , $this._backgroundColor, $this._foregroundColor)
				}

				++$this.SelectedIndex

				$this.WriteStatusBar("$($this.SelectedIndex + 1)/$($this.Items.Count)")
			}

			([ConsoleKey]::UpArrow) {
				if ($this.SelectedIndex -eq 0) {
					# at start of list, no change
					# also handles empty list
					break
				}

				# unselect currently selected line
				$this.WriteLine($this.SelectedIndex - $this.FirstIndexInView, $this.GetItemLabel($this.SelectedIndex) , $this._foregroundColor, $this._backgroundColor)

				if ($this.SelectedIndex -eq $this.FirstIndexInView) {
					# first line is selected, scroll down one line
					$this.ScrollAreaVertically(0, $this.ClientHeight() - 1, 1)
					--$this.FirstIndexInView
					# display next line
					$this.WriteLine(0, $this.GetItemLabel($this.SelectedIndex - 1), $this._backgroundColor, $this._foregroundColor)
				} else {
					$this.WriteLine($this.SelectedIndex - $this.FirstIndexInView - 1, $this.GetItemLabel($this.SelectedIndex - 1) , $this._backgroundColor, $this._foregroundColor)
				}

				--$this.SelectedIndex

				$this.WriteStatusBar("$($this.SelectedIndex + 1)/$($this.Items.Count)")
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
	[int] $FirstIndexInView = 0
	[int] $SelectedIndex = 0
}

class SVListBox : ScrollView {
	SVListBox(
		[LBItemBase[]] $items,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[System.ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[System.ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {

		if ($null -ne $items) {
			for ($i = 0; $i -lt $items.Count; ++$i) {
				$item = $items[$i]
				$this._items.Add($item) | Out-Null

				if ($i -eq $this.SelectedIndex) {
					$this.AddLine($this.GetItemLabel($item), $this.BackgroundColor(), $this.ForegroundColor())
				} else {
					$this.AddLine($this.GetItemLabel($item), $this.ForegroundColor(), $this.BackgroundColor())
				}
			}
		}
	}

	[int] ItemCount() { return $this._items.Count }

	[void] AddItem([object] $item) {
		$this._items.Add($item) | Out-Null
		$this.AddLine($this.GetItemLabel($item), $this.ForegroundColor(), $this.BackgroundColor())
	}

	[void] InsertItem([int] $index, [object] $item) {
		$this._items.Insert($index, $item)
		$this.InsertLine($index, $this.GetItemLabel($item), $this.ForegroundColor(), $this.BackgroundColor())
	}

	[void] RemoveItem([int] $index) {
		if ($index -eq $this.SelectedIndex) { $this.SelectedIndex = -1 }
		$this._items.RemoveAt($index)
		$this.RemoveLine($index)
	}

	[LBItemBase] GetItem([int] $index) { return $this._items[$index] }

	[LBItemBase] SelectedItem() {
		return $this._items[$this.SelectedIndex]
	}

	hidden DrawClientArea() {
		([ScrollView]$this).DrawClientArea()
		$si = if ($this._items.Count -gt 0) { $this.SelectedIndex + 1 } else { 0 }
		$this.WriteStatusBar("$si/$($this._items.Count)")
	}

	hidden [void] OnKey([System.ConsoleKeyInfo] $key) {
		#[Log]::Comment("SVListBox.OnKey: Key=$($key.Key), Modifiers=$($key.Modifiers)")

		switch ($key.Key) {
			([ConsoleKey]::DownArrow) {
				if ($this._items.Count -eq 0) {
					# empty list
					break
				}

				if ($this.SelectedIndex -eq ($this._items.Count - 1)) {
					# at end of list, no change
					break
				}

				# unselect currently selected line
				$this.GetLine($this.SelectedIndex).ForegroundColor = $this.ForegroundColor()
				$this.GetLine($this.SelectedIndex).BackgroundColor = $this.BackgroundColor()

				if (($this.SelectedIndex - $this.FirstRowInView) -ge ($this.ClientHeight() - 1)) {
					# last line is selected, scroll up one line
					++$this.FirstRowInView
				}

				++$this.SelectedIndex

				$this.GetLine($this.SelectedIndex).ForegroundColor = $this.BackgroundColor()
				$this.GetLine($this.SelectedIndex).BackgroundColor = $this.ForegroundColor()

				$this.DrawClientArea()
			}

			([ConsoleKey]::UpArrow) {
				if ($this.SelectedIndex -eq 0) {
					# at start of list, no change
					# also handles empty list
					break
				}

				# unselect currently selected line
				$this.GetLine($this.SelectedIndex).ForegroundColor = $this.ForegroundColor()
				$this.GetLine($this.SelectedIndex).BackgroundColor = $this.BackgroundColor()

				if ($this.SelectedIndex -eq $this.FirstRowInView) {
					# first line is selected, scroll down one line
					--$this.FirstRowInView
				}

				--$this.SelectedIndex

				$this.GetLine($this.SelectedIndex).ForegroundColor = $this.BackgroundColor()
				$this.GetLine($this.SelectedIndex).BackgroundColor = $this.ForegroundColor()

				$this.DrawClientArea()
			}

			default {
				([ScrollView]$this).OnKey($key)
			}
		}
	}

	hidden [string] GetItemLabel([object]$item) {
		return $item.Name()
	}

	[int] $SelectedIndex = 0
	hidden [System.Collections.ICollection] $_items = ([System.Collections.ArrayList]::new())
}
