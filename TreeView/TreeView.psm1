using module Gumby.Debug
using module Gumby.Log
using module ListBox
using module Window

class TVItemBase : LBItemBase {
	TVItemBase() {}

	hidden TVItemBase([uint32] $level) {
		$this._level = $level
	}

	[uint32] Level() {return $this._level }
	[bool] IsContainer() { throw "abstract" }
	[bool] IsExpanded() { return $this._isExpanded }
	[TVItemBase] Parent() { throw "abstract" }
	[Collections.Generic.IList`1[TVItemBase]] Children() { throw "abstract" }
	[void] Expand() {
		if (!$this.IsContainer()) {
			$errorMessage = "Item `"$($this.Name())`" is not a container."
			[Log]::Error($errorMessage)
			throw $errorMessage
		}
		if ($this.IsExpanded()) {
			$errorMessage = "Item `"$($this.Name())`" is already expanded."
			[Log]::Error($errorMessage)
			throw $errorMessage
		}
		$this._isExpanded = $true
	}
	[void] Collapse() {
		if (!$this.IsExpanded()) {
			$errorMessage = "Item `"$($this.Name())`" is not expanded."
			[Log]::Error($errorMessage)
			throw $errorMessage
		}
		$this._isExpanded = $false
	}

	hidden [bool] $_isExpanded = $false
	hidden [uint32] $_level = 0
}

class SimpleObjectTVItem : TVItemBase {
	SimpleObjectTVItem([object] $simpleObject) {
		$this._simpleObject = $simpleObject
	}

	hidden SimpleObjectTVItem([object] $simpleObject, [TVItemBase] $parent, [uint32] $level) : base($level) {
		$this._simpleObject = $simpleObject
		$this._parent = $parent
	}

	[string] Name() { return $this._simpleObject.Name }

	[object] Value() { return $this._simpleObject }

	[bool] IsContainer() {
		return $this._simpleObject.ContainsKey('Children') -and
			$this._simpleObject.Children.Count -gt 0
	}

	[TVItemBase] Parent() {return $this._parent }

	[Collections.Generic.IList`1[TVItemBase]] Children() {
		if ($this._children -eq $null) {
			if ($this._simpleObject.ContainsKey('Children')) {
				$this._children = [Collections.Generic.List`1[TVItemBase]]::new($this._simpleObject.Children.Count)
				foreach ($simpleChild in $this._simpleObject.Children) {
					$this._children.Add([SimpleObjectTVItem]::new($simpleChild, $this, $this.Level() + 1)) | Out-Null
				}
			} else {
				$this._children = [Collections.Generic.List`1[TVItemBase]]::new()
			}
		}

		return $this._children
	}

	hidden [object] $_simpleObject
	hidden [TVItemBase] $_parent = $null
	hidden [Collections.Generic.IList`1[TVItemBase]] $_children = $null
}

class FileTVItem : TVItemBase {
	FileTVItem([IO.FileSystemInfo] $fsInfo) {
		$this._fsInfo = $fsInfo
		# splitting the full name is between 4 and 6 times faster than a parent walk
		$this._level = $fsInfo.FullName.Split((PathSeparator)).Count - 1
	}

	hidden FileTVItem([IO.FileSystemInfo] $fsInfo, [uint32] $level) : base($level) {
		$this._fsInfo = $fsInfo
	}

	[string] Name() { return $this._fsInfo.Name }

	[object] Value() { return $this._fsInfo }

	[bool] IsContainer() {
		return ($this._fsInfo -is [System.IO.DirectoryInfo])
	}

	[TVItemBase] Parent() {
		$fsParent = if ($this._fsInfo -is [System.IO.DirectoryInfo]) {
			$this._fsInfo.Parent
		} else {
			$this._fsInfo.Directory
		}

		if ($fsParent -ne $null) {
			return [FileTVItem]::new($fsParent, $this.Level() - 1)
		} else {
			return $null
		}
	}

	[Collections.Generic.IList`1[TVItemBase]] Children() {

		# Be aware that FS items retrieved via PS drive provider commands (e.g. Get-Item or
		# Get-ChildItem) are annotated with 'PS*' properties (e.g. PSIsContainer). FS items
		# retrieved via "native" .NET methods or properties do not have these annotations.
		# Therefore, mixing drive provider and native retrieval methods can result in incongruous
		# objects and obscure bugs. Better exclusively use one or the other kind of retrieval
		# methods.

		if ($this._children -eq $null) {

			$this._children = [Collections.Generic.List`1[TVItemBase]]::new()

			$fsDirInfo = $this._fsInfo -as [System.IO.DirectoryInfo]

			if ($fsDirInfo -ne $null) {
				foreach ($fsChildDirInfo in $fsDirInfo.GetDirectories()) {
					if (($fsChildDirInfo.Attributes -band ([System.IO.FileAttributes]::Hidden)) -eq ([System.IO.FileAttributes]::Hidden)) { continue }
					if (($fsChildDirInfo.Attributes -band ([System.IO.FileAttributes]::System)) -eq ([System.IO.FileAttributes]::System)) { continue }
		
					$this._children.Add([FileTVItem]::new($fsChildDirInfo, $this.Level() + 1))
				}
				foreach ($fsChildFileInfo in $fsDirInfo.GetFiles()) {
					if (($fsChildFileInfo.Attributes -band ([System.IO.FileAttributes]::Hidden)) -eq ([System.IO.FileAttributes]::Hidden)) { continue }
					if (($fsChildFileInfo.Attributes -band ([System.IO.FileAttributes]::System)) -eq ([System.IO.FileAttributes]::System)) { continue }
					$this._children.Add([FileTVItem]::new($fsChildFileInfo, $this.Level() + 1))
				}
			}
		}

		return $this._children
	}

	hidden [IO.FileSystemInfo] $_fsInfo
	hidden [TVItemBase] $_parent = $null
	hidden [Collections.Generic.IList`1[TVItemBase]] $_children = $null
}

class TreeView : ListBox {
	<# const #> [uint32] $MaxLevelCount = 4

	TreeView(
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {
	}

	TreeView(
		[System.Collections.IEnumerable] $items,
		[System.Reflection.TypeInfo] $tvItemType,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base($left, $top, $width, $height, $foregroundColor, $backgroundColor) {

		# We cannot pass the items collection to the base class as it would layout the text prior
		# to having determined the top indentation level.

		$i = 0
		$tvItems = [System.Collections.Generic.List`1[LBItemBase]]::new()
		foreach ($item in $items) {
			$tvItem = $tvItemType::new($item)
			$tvItems.Add($tvItem) | Out-Null

			if ($i++ -eq 0) {
				$this.topLevelInView = $tvItem.Level()
			} else {
				Assert ($tvItem.Level() -eq $this.topLevelInView)
			}
		}

		$this.InitializeItems($tvItems)
	}

	# for debugging purposes
	hidden [void] TraceItems() {
		for ($i = 0; $i -lt $this.ItemCount(); ++$i) {
			$item = $this.GetItem($i)
			
			if ($item.IsExpanded()) { $expansionState = "expanded" } else { $expansionState = "collapsed" }
			if ($i -eq $this.FirstRowInView) { $firstInView = ", firstInView" } else { $firstInView = "" }
			if ($i -eq $this.SelectedIndex()) { $selected = ", selected" } else { $selected = "" }

			[Log]::Trace(("{0}: N=`"{1}`"; L={2}; {3}{4}{5}" -f
				$i,
				$this.GetItemLabel($item),
				$item.Level(),
				$expansionState,
				$firstInView,
				$selected))
		}
	}

	# for debugging purposes
	[string] TraceInfo() {
		return "Name=`"$($this.SelectedItem().Name())`"; SIx=$($this.SelectedIndex()); FRIV=$($this.FirstRowInView); TLIV=$($this.topLevelInView)"
	}

	<#
	.PARAMETER item
	The item to get a label for. The type of this parameter is 'object' rather than a more specific
	type like 'LBItemBase' or 'TVItemBase' to avoid method overloading and allow for method
	overriding.
	#>
	[string] GetItemLabel([object] $item) {
		[char] $icon = if ($item.IsContainer()) {
			if ($item.IsExpanded()) {
				<# black down-pointing triangle #> 0x25BC
			} else {
				<# black right-pointing pointer #> 0x25BA
			}
		} else {
			# <# black square #> 0x25A0
			<# black small square #> 0x25AA
		}

		return ((' ' * 4 * ($item.Level() - $this.topLevelInView)) + $icon + ' ' + $item.Name())
	}

	[void] RemoveItem([int] $index) {
		if ($this.GetItem($index).IsExpanded()) {
			# otherwise the icon is wrong if we re-use the item
			$this.GetItem($index).Collapse()
		}
		([ListBox]$this).RemoveItem($index)
	}

	[void] OnKey([System.ConsoleKeyInfo] $key) {
		[Log]::Trace("TV.OnKey: Name=`"$($this.SelectedItem().Name())`"; SII=$($this.SelectedIndex()); K=$($key.Key)")

		switch ($key.Key) {
			([ConsoleKey]::RightArrow) {
				$this.Expand()
			}

			([ConsoleKey]::LeftArrow) {
				$this.Collapse()
			}

			default {
				([ListBox]$this).OnKey($key)
			}
		}
	}

	<#
	.SYNOPSIS
	Gets the range of items that are - along the ancestor axis - within a "level distance" of a
	start item.

	.PARAMETER startIndex
	Index of the item to get range for.

	.PARAMETER levelDistance
	Number of levels determining the size of the range (relative to the level of the start item).

	.DESCRIPTION
	Given the tree ...

	    0   1   2   3   4         level
	        |<--:---|             level distance 2
	00: A1  |   :   |
	01:     B1  :   |          <- first return value
	02:     B2  :   |
	03:         C1  |
	04:             D1
	05:             |   E1
	06:         C2  |
	07:             D2
	08:             D3         <- startIndex
	09:             D4
	10:         C3
	11:     B3                 <- second return value
	12: A2

	... calling this method the start item index 8 (item D3) and a level distance of 2 would return
	(1, 11).

	.OUTPUTS
	Pair of item indices, the first marking the start of the range, the second its end.
	#>
	[int[]] GetAncestralSiblingRange([uint32] $startIndex, [uint32] $levelDistance) {
		function GetFirstAtLevel([uint32] $i) {
			[uint32] $level = $this.GetItem($i).Level()
			for (; ($i -gt 0) -and ($this.GetItem($i - 1).Level() -ge $level); --$i) {}
			return $i
		}

		function GetLastAtLevel([uint32] $i) {
			[uint32] $level = $this.GetItem($i).Level()
			for (; ($i -lt $this.ItemCount() - 1) -and ($this.GetItem($i + 1).Level() -ge $level); ++$i) {}
			return $i
		}

		[uint32] $first = GetFirstAtLevel $startIndex
		[uint32] $last = GetLastAtLevel $startIndex

		for ([uint32] $i = 1; $i -le $levelDistance; ++$i) {
			if (($first -gt 0) -and ($this.GetItem($first - 1).Level() -eq $this.GetItem($startIndex).Level() - $i)) {
				# Assert ($this.Items[$first - 1].Level() -eq $this.Items[$first].Level() - 1)
				$first = GetFirstAtLevel ($first - 1)
			}

			if (($last -lt $this.ItemCount() - 1) -and ($this.GetItem($last + 1).Level() -eq $this.GetItem($startIndex).Level() - $i)) {
				# Assert ($this.Items[$last + 1].Level() -lt $this.Items[$last].Level())
				$last = GetLastAtLevel ($last + 1)
			}
		}

		return $first, $last
	}

	[void] Expand() {
		[Log]::BeginSection("TV.Expand: $($this.TraceInfo())")

		try {

			# Can the item be expanded?
			if (!$this.SelectedItem().IsContainer()) {
				[console]::Beep(300, 100)
				return
			}

			# Is the item already expanded?
			if ($this.SelectedItem().IsExpanded()) {
				[console]::Beep(300, 100)
				return
			}

			$children = $this.SelectedItem().Children()

			if ($children.Count -eq 0) {
				[console]::Beep(300, 100)
				return
			}

			if ([Log]::Listeners.Count -gt 0) { $this.TraceItems() }

			if (($this.SelectedItem().Level() - $this.topLevelInView) -eq ($this.MaxLevelCount - 1)) {
				# With the level we're about to expand, we would exceed the maximum level count.
				# Prune ancestors and unindent remaining items.

				# 00: I0-00
				# 01:    I1-00 <-- first
				# 02:    I1-01
				# 03:        I2-00
				# 04:        I2-01
				# 05:            I3-00 *
				# 06:                ... (items about to get expanded)
				# 07:            I3-01
				# 08:        I2-02
				# 09:    I1-02 <-- last
				# 10: I0-1

				$first, $last = $this.GetAncestralSiblingRange($this.SelectedIndex(), $this.MaxLevelCount - <# one for gaps vs. items, another one for the add'l level inserted above #> 2)
				#[Log]::Trace("TV.Expand.MaxLevelOverflow2: first=$first, last=$last")

				# Prune every item outside of [$first, $last]
				for ($i = $this.ItemCount() - 1; $i -gt $last; --$i) { $this.RemoveItem($i) }
				for ($i = $first; $i -gt 0; --$i) { $this.RemoveItem($i - 1) }

				++$this.topLevelInView
				$this.FirstRowInView = [Math]::Max(0, $this._selectedIndex - $this.ClientHeight())
				#[Log]::Trace("TV.Expand.MaxLevelOverflow3: SIx=$($this._selectedIndex); FRIV=$($this.FirstRowInView); TLIV=$($this.topLevelInView)")

				# As indentation has changed due to the pruning above, we need to re-render the
				# text buffer.

				for ($i = 0; $i -lt $this.ItemCount(); ++$i) {
					# We deal with the selected item below.
					if ($i -ne $this.SelectedIndex()) {
						$this.GetLine($i).Text = $this.GetItemLabel($this.GetItem($i));
					}
				}
			}

			# [Log]::Trace("TV.Expand.SelectedItemExpand, Name='$($this.SelectedItem().Name())', IsExpanded=$($this.SelectedItem().IsExpanded()), IsContainer=$($this.SelectedItem().IsContainer())")
			$this.SelectedItem().Expand() # only changes the state of the item itself, does not add or remove children

			# re-render text for expansion state icon
			$this.GetLine($this.SelectedIndex()).Text = $this.GetItemLabel($this.GetItem($this.SelectedIndex()));

			[uint32] $ii = $this.SelectedIndex()
			foreach ($child in $children) {
				$this.InsertItem(++$ii, $child)
			}

			$this.SelectItem($this.SelectedIndex() + 1)

			# ensure selected item is in view
			#
			# 00:
			# 01: +-
			# 02: | FirstRowInView
			# 03: |
			# 04: |
			# 05: +- SelectedIndex
			if (($this.SelectedIndex() - $this.FirstRowInView) -ge $this.ClientHeight()) {
				$this.FirstRowInView = $this.SelectedIndex() - $this.ClientHeight() + 1
			}

			$this.DrawClientArea()

		} finally {
			[Log]::EndSection("TV.Expand: $($this.TraceInfo())")
		}
	}

	[void] Collapse() {
		[Log]::BeginSection("TV.Collapse: $($this.TraceInfo())")
		try {
			if ([Log]::Listeners.Count -gt 0) { $this.TraceItems() }

			# Going up deepens the displayed tree. Is there a way to return it to the depth we started
			# at? Perhaps we can have a "sliding window" of the last n ancestral levels?

			# Q: should we right-shift a) whenever we drop beneath MaxLevelCount or b) when we're closing
			# level 0?
			# As we could have left folders expanded by going out of them via CursorUp/-Down, right-shifting
			# could create more than MaxLevelCount levels.

			if ($this.SelectedItem().Level() -gt $this.topLevelInView) {
				[Log]::Trace("TV.Collapse.ParentPresent")

				[uint32] $first, $last = $this.GetAncestralSiblingRange($this.SelectedIndex(), 0)

				# remove collapsed items (iterating backwards for index consistency)
				for ([uint32] $i = $last; $i -ge $first; --$i) { $this.RemoveItem($i) }

				$this.SelectItem($first - 1)

				$this.SelectedItem().Collapse() # only changes expand/collapse state, does not manipulate children

				# re-render text for expansion-state indicating icon
				$this.GetLine($this.SelectedIndex()).Text = $this.GetItemLabel($this.SelectedItem())

				$this.FirstRowInView = [Math]::Min($this.FirstRowInView, $this.SelectedIndex())

			} else {
				[Log]::Trace("TV.Collapse.NeedToFetchParent: Name='$($this.SelectedItem().Name())'")
				$parent = $this.SelectedItem().Parent()

				if ($parent -eq $null) { return }

				--$this.topLevelInView # equivalent to assigning '$parent.Level()'

				# As we're expanding the tree view toward the root, prune the nodes that would exceed the
				# maximum view depth.
				for ([int] $i = $this.ItemCount() - 1; $i -ge 0; --$i) {
					# [Log]::Trace("TV.Collapse.PruneReindentLoop: Name=$($this.GetItem($i).Name()), Level=$($this.GetItem($i).Level()), TLIV=$($this.topLevelInView)")
					if (($this.GetItem($i).Level() - $this.topLevelInView) -ge $this.MaxLevelCount) {
						# prune item as it would exceed maximum view depth
						$this.RemoveItem($i)
					} else {
						# re-render text to capture increased indentation
						# [Log]::Trace("TV.Collapse.Reindent: Name=$($this.GetItem($i).Name())")
						$this.GetLine($i).Text = $this.GetItemLabel($this.GetItem($i))
					}
				}

				if (!$parent.IsExpanded()) { $parent.Expand() }
				$this.InsertItem(0, $parent)
				$this.SelectItem(0)
				$this.FirstRowInView = 0

				# [Log]::Trace("TV.Collapse.FillInParentSiblings: TLIV=$($this.topLevelInView)")

				$grandParent = $parent.Parent()
				if ($grandParent -ne $null) {
					# insert the parent's siblings
					[uint32] $insertPosition = 0

					foreach ($grandParentChild in $grandParent.Children()) {

						#TODO: Name comparison might not be sufficient (it assumes unique names per level).
						# Perhaps we need an 'Equals' method on tree view items.

						if ($grandParentChild.Name() -eq $parent.Name()) {
							# item has already been inserted per the line above
							$this.SelectItem($insertPosition)

							# continue inserting grand parent children after the current items
							$insertPosition = $this.ItemCount()
						} else {
							$this.InsertItem($insertPosition++, $grandParentChild)
						}
					}

					$this.FirstRowInView = [Math]::Max(0, $this.SelectedIndex() - $this.ClientHeight() + 1)
				}
			}

			$this.DrawClientArea()

		} finally {
			[Log]::EndSection("TV.Collapse: $($this.TraceInfo())")
		}
	}

	hidden [uint32] $topLevelInView = 0
}
