using module ScrollView

class LBItemBase {
	[string] Name() { throw "abstract" }
	[object] Value() { throw "abstract" }
}

class StringLBItem : LBItemBase {
	StringLBItem([string] $value) {
		$this._value = $value
	}

	[string] Name() { return $this._value }
	[string] Value() { return $this._value }

	hidden [string] $_value
}

class ListBox : ScrollView {

	ListBox(
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[System.ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[System.ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {
	}

	ListBox(
		[System.Collections.IEnumerable] $items,
		[System.Reflection.TypeInfo] $lbItemType,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[System.ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[System.ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {

		$lbItems = [System.Collections.Generic.List`1[LBItemBase]]::new()
		foreach($item in $items) {
			$lbItems.Add($lbItemType::new($item)) | Out-Null
		}

		$this.InitializeItems($lbItems)
	}

	hidden [void] InitializeItems([System.Collections.Generic.IEnumerable`1[LBItemBase]] $lbItems) {
		foreach ($lbItem in $lbItems) {
			$this._items.Add($lbitem) | Out-Null
			$this.AddLine($this.GetItemLabel($lbItem), $this.ForegroundColor(), $this.BackgroundColor())
		}

		if ($this.ItemCount() -gt 0) { $this.SelectItem(0) }
	}

	[int] ItemCount() { return $this._items.Count }

	[void] AddItem([object] $item) {
		$this._items.Add($item) | Out-Null
		$this.AddLine($this.GetItemLabel($item), $this.ForegroundColor(), $this.BackgroundColor())
	}

	[void] InsertItem([int] $index, [object] $item) {
		if ($this._selectedIndex -ne -1) {
			if ($index -le $this._selectedIndex) { ++$this._selectedIndex }
		}

		$this._items.Insert($index, $item)
		$this.InsertLine($index, $this.GetItemLabel($item), $this.ForegroundColor(), $this.BackgroundColor())
	}

	[LBItemBase] GetItem([int] $index) { return $this._items[$index] }

	[void] RemoveItem([int] $index) {
		if ($this._selectedIndex -ne -1) {
			if ($index -lt $this._selectedIndex) {
				--$this._selectedIndex
			} elseif ($index -eq $this._selectedIndex) { 
				$this._selectedIndex = -1
			}
		}

		$this._items.RemoveAt($index)
		$this.RemoveLine($index)
	}

	[void] SelectItem([int] $index) {
		if ($index -ge 0) {
			if ($index -ne $this._selectedIndex) {

				if ($this._selectedIndex -ge 0) {
					# deselect currently selected item
					$this.GetLine($this._selectedIndex).ForegroundColor = $this.ForegroundColor()
					$this.GetLine($this._selectedIndex).BackgroundColor = $this.BackgroundColor()
				}
	
				# select new item
				$this.GetLine($index).ForegroundColor = $this.BackgroundColor()
				$this.GetLine($index).BackgroundColor = $this.ForegroundColor()
	
				$this._selectedIndex = $index
			}
		} else {
			# removing selection

			if ($this._selectedIndex -ge 0) {
				# deselect currently selected item
				$this.GetLine($this._selectedIndex).ForegroundColor = $this.ForegroundColor()
				$this.GetLine($this._selectedIndex).BackgroundColor = $this.BackgroundColor()
			}

			$this._selectedIndex = -1 # normalizing to -1
		}
	}

	[int] SelectedIndex() {
		return $this._selectedIndex
	}

	[LBItemBase] SelectedItem() {
		return $this._items[$this._selectedIndex]
	}

	hidden DrawClientArea() {
		([ScrollView]$this).DrawClientArea()
		$si = if ($this._items.Count -gt 0) { $this._selectedIndex + 1 } else { 0 }
		$this.WriteStatusBar("$si/$($this._items.Count)")
	}

	hidden [void] OnKey([System.ConsoleKeyInfo] $key) {
		#[Log]::Comment("SVListBox.OnKey: Key=$($key.Key), Modifiers=$($key.Modifiers)")

		switch ($key.Key) {
			([ConsoleKey]::DownArrow) { $this.MoveSelectionDown() }
			([ConsoleKey]::UpArrow) { $this.MoveSelectionUp() }
			default { ([ScrollView]$this).OnKey($key) }
		}
	}

	hidden [void] MoveSelectionDown() {
		if ($this._items.Count -eq 0) {
			# empty list
			return
		}

		if ($this._selectedIndex -eq ($this._items.Count - 1)) {
			# at end of list, no change
			return
		}

		if (($this._selectedIndex - $this.FirstRowInView) -ge ($this.ClientHeight() - 1)) {
			# last line in view is selected, scroll up one line

			$this.ScrollAreaVertically(0, $this.ClientHeight() - 2, -1)
			++$this.FirstRowInView
		}

		$previouslySelectedIndex = $this._selectedIndex
		$this.SelectItem($this._selectedIndex + 1)
		$this.DrawLine($this._selectedIndex)
		$this.DrawLine($previouslySelectedIndex)

		$this.WriteStatusBar("$($this._selectedIndex + 1)/$($this._items.Count)")
	}

	hidden [void] MoveSelectionUp() {
		if ($this._selectedIndex -eq 0) {
			# at start of list, no change
			# also handles empty list
			return
		}

		if ($this._selectedIndex -eq $this.FirstRowInView) {
			# first line in view is selected, scroll down one line

			$this.ScrollAreaVertically(1, $this.ClientHeight() - 2, 1)
			--$this.FirstRowInView
		}

		$previouslySelectedIndex = $this._selectedIndex
		$this.SelectItem($this._selectedIndex - 1)
		$this.DrawLine($this._selectedIndex)
		$this.DrawLine($previouslySelectedIndex)

		$this.WriteStatusBar("$($this._selectedIndex + 1)/$($this._items.Count)")
	}

	hidden [string] GetItemLabel([object]$item) {
		return $item.Name()
	}

	hidden [System.Collections.ICollection] $_items = ([System.Collections.ArrayList]::new())
	hidden [int] $_selectedIndex = -1
}
