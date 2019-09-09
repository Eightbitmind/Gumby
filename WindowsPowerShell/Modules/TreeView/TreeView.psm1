using module ListBox
using module Log
using module Window

class TVItemBase {
	TVItemBase() {}

	hidden TVItemBase([uint32] $level) {
		$this._level = $level
	}

	[string] Name() { throw "abstract" }
	[uint32] Level() {return $this._level }
	[bool] IsContainer() { throw "abstract" }
	[bool] IsExpanded() { return $this._isExpanded }
	[TVItemBase] Parent() { throw "abstract" }
	[Collections.Generic.IList`1[TVItemBase]] Children() { throw "abstract" }
	[void] Expand() {
		if (!$this.IsContainer() -or $this.IsExpanded()) { throw "invalid operation" }
		$this._isExpanded = $true
	}
	[void] Collapse() {
		if (!$this.IsExpanded()) { throw "invalid operation" }
		$this._isExpanded = $false
	}

	hidden [bool] $_isExpanded = $false
	hidden [uint32] $_level = 0
}

class SimpleObjectTVItem : TVItemBase {
	SimpleObjectTVItem([object] $simpleObject) {
		$this.simpleObject = $simpleObject
	}

	hidden SimpleObjectTVItem([object] $simpleObject, [TVItemBase] $parent, [uint32] $level) : base($level) {
		$this.simpleObject = $simpleObject
		$this._parent = $parent
	}

	[string] Name() { return $this.simpleObject.Name }

	[bool] IsContainer() {
		return $this.simpleObject.ContainsKey('Children') -and
			$this.simpleObject.Children.Count -gt 0
	}

	[TVItemBase] Parent() {return $this._parent }

	[Collections.Generic.IList`1[TVItemBase]] Children() {
		if ($this._children -eq $null) {
			if ($this.simpleObject.ContainsKey('Children')) {
				$this._children = [Collections.Generic.List`1[TVItemBase]]::new($this.simpleObject.Children.Count)
				foreach ($simpleChild in $this.simpleObject.Children) {
					$this._children.Add([SimpleObjectTVItem]::new($simpleChild, $this, $this.Level() + 1)) | Out-Null
				}
			} else {
				$this._children = [Collections.Generic.List`1[TVItemBase]]::new()
			}
		}

		return $this._children
	}

	[object] Object() {
		return $this.simpleObject
	}

	hidden [object] $simpleObject
	hidden [TVItemBase] $_parent = $null
	hidden [Collections.Generic.IList`1[TVItemBase]] $_children = $null
}

class FileTVItem : TVItemBase {
	FileTVItem([IO.FileSystemInfo] $fsInfo) {
		$this.fsInfo = $fsInfo
		# TODO: determine level
	}

	hidden FileTVItem([IO.FileSystemInfo] $fsInfo, [uint32] $level) : base($level) {
		$this.fsInfo = $fsInfo
	}

	[string] Name() { return $this.fsInfo.Name }

	[bool] IsContainer() {
		return ($this.fsInfo -is [System.IO.DirectoryInfo])
	}

	[TVItemBase] Parent() {
		$fsParent = if ($this.fsInfo -is [System.IO.DirectoryInfo]) {
			$this.fsInfo.Parent
		} else {
			$this.fsInfo.Directory
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

			$fsDirInfo = $this.fsInfo -as [System.IO.DirectoryInfo]

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

	hidden [IO.FileSystemInfo] $fsInfo
	hidden [TVItemBase] $_parent = $null
	hidden [Collections.Generic.IList`1[TVItemBase]] $_children = $null
}

class FileTreeView : ListBox {
	<# const #> [uint32] $MaxLevelCount = 4

	FileTreeView(
		[string] $path,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base(
		(New-Object System.Collections.ArrayList),
		$left,
		$top,
		$width,
		$height,
		$foregroundColor,
		$backgroundColor
	) {
		[System.IO.DirectoryInfo] $startDir = Get-Item $path

		foreach ($fsItem in $this.GetDirectoryContent($startDir)) {
			$this.Items.Add(@{Level = 0; Value = $fsItem}) | Out-Null
		}
	}

	[void] TraceItems() {
		for ($i = 0; $i -lt $this.Items.Count; ++$i) {
			if ($i -eq $this.FirstIndexInView) { $fiiv = ", FIIV" } else { $fiiv = "" }
			if ($i -eq $this.SelectedIndex) { $sii = ", SII" } else { $sii = "" }
			[Log]::Trace(("{0}: `"{1}`" L={2}{3}{4}" -f
				$i,
				$this.GetItemLabel($i),
				$this.Items[$i].Level,
				$fiiv,
				$sii))
		}
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

			$this.WriteLine($i, $this.GetItemLabel($i), $fc, $bc)
		}

		$si = if ($this.Items.Count -gt 0) { $this.SelectedIndex + 1 } else { 0 }
		$this.WriteStatusBar("$si/$($this.Items.Count)")

		# skipping ListBox.OnShown()
		([Window]$this).OnShown()
	}

	[void] DisplayItems() {
		for ($y = 0; $y -lt $this.ClientHeight(); ++$y) {
			if ($this.FirstIndexInView + $y -lt $this.Items.Count) {
				if ($this.FirstIndexInView + $y -eq $this.SelectedIndex) {
					$fc = $this._backgroundColor
					$bc = $this._foregroundColor
				} else {
					$fc = $this._foregroundColor
					$bc = $this._backgroundColor
				}

				$this.WriteLine($y, $this.GetItemLabel($this.FirstIndexInView + $y), $fc, $bc)
			} else {
				$this.WriteLine($y, "", $this._foregroundColor, $this._backgroundColor)
			}
		}
	}

	[string] GetItemLabel($itemIndex) {
		[char] $icon = if ($this.Items[$itemIndex].Value -is [System.IO.DirectoryInfo]) {
			if (($itemIndex -lt $this.Items.Count - 1) -and ($this.Items[$itemIndex + 1].Level -gt $this.Items[$itemIndex].Level)) {
				# expanded directory
				<# black down-pointing triangle #> 0x25BC
			} else {
				# unexpanded directory
				<# black right-pointing pointer #> 0x25BA
			}
		} else {
			# file
			# <# black square #> 0x25A0
			<# black small square #> 0x25AA
		}

		return (' ' * 4 * $this.Items[$itemIndex].Level) + $icon + ' ' + $this.Items[$itemIndex].Value.Name
	}

	[void] OnKey([System.ConsoleKeyInfo] $key) {
		[Log]::Trace("TV.OnKey: SII=$($this.SelectedIndex); SIN='$($this.SelectedItem().Value.FullName)'; K=$($key.Key)")

		switch ($key.Key) {
			([ConsoleKey]::RightArrow) {
				$this.OpenSubDir()
			}
			
			([ConsoleKey]::LeftArrow) {
				$this.CloseSubDir()
			}

			default {
				([ListBox]$this).OnKey($key)
			}
		}
	}

	[int[]] GetAncestralSiblingRange([uint32] $itemIndex, [uint32] $levelCount) {
		function GetFirstAtLevel([uint32] $i) {
			[uint32] $level = $this.Items[$i].Level
			for (; ($i -gt 0) -and ($this.Items[$i - 1].Level -ge $level); --$i) {}
			return $i
		}

		function GetLastAtLevel([uint32] $i) {
			[uint32] $level = $this.Items[$i].Level
			for (; ($i -lt $this.Items.Count - 1) -and ($this.Items[$i + 1].Level -ge $level); ++$i) {}
			return $i
		}

		[uint32] $first = GetFirstAtLevel $itemIndex
		[uint32] $last = GetLastAtLevel $itemIndex

		for ([uint32] $i = 1; $i -le $levelCount; ++$i) {
			if (($first -gt 0) -and ($this.Items[$first - 1].Level -eq $this.Items[$itemIndex].Level - $i)) {
				# assert($this.Items[$first - 1].Level -eq $this.Items[$first].Level - 1)
				$first = GetFirstAtLevel ($first - 1)
			}

			if (($last -lt $this.Items.Count - 1) -and ($this.Items[$last + 1].Level -eq $this.Items[$itemIndex].Level - $i)) {
				# assert($this.Items[$last + 1].Level -lt $this.Items[$last].Level)
				$last = GetLastAtLevel ($last + 1)
			}
		}

		return $first, $last
	}

	[void] OpenSubDir() {
		[Log]::BeginSection("TV.OpenSubDir: FIIV=$($this.FirstIndexInView); SII=$($this.SelectedIndex)")

		# Is the item already expanded?
		if (($this.SelectedIndex -lt $this.Items.Count - 1) -and
			($this.Items[$this.SelectedIndex + 1].Level -eq $this.SelectedItem().Level + 1)
		) {
			[console]::Beep(300, 100)
			return
		}

		# Can the item be expanded?

		if (!($this.SelectedItem().Value -is [System.IO.DirectoryInfo])) {
			[console]::Beep(300, 100)
			return
		}

		$directoryContent = $this.GetDirectoryContent($this.SelectedItem().Value)

		if ($directoryContent.Count -eq 0) {
			[console]::Beep(300, 100)
			return
		}

		#region fix up data

		[uint32] $ii = $this.SelectedIndex
		foreach ($fsItem in $directoryContent) {
			$this.Items.Insert(++$ii, @{Level = $this.SelectedItem().Level + 1; Value = $fsItem})
		}

		if ($this.SelectedItem().Level -eq $this.MaxLevelCount - 1) {
			if ([Log]::Listeners.Count -gt 0) {
				[Log]::Trace("TV.OpenSubDir: MaxLevel overflow")
				$this.TraceItems()
			}

			# I0-00
			#     I1-00 <-- first
			#     I1-01
			#         I2-00
			#         I2-01
			#             I3-00 *
			#                 ... (items about to get expanded)
			#             I3-01
			#         I2-02
			#     I1-02 <-- last
			# I0-1

			# Level we're about to expand would exceed maximum levels. "Left-shift" levels.

			$first, $last = $this.GetAncestralSiblingRange($this.SelectedIndex, $this.SelectedItem().Level - 1)
			[Log]::Trace("TV.OpenSubDir: first=$first, last=$last")

			# Prune every item outside of [$first, $last], promote everything inside that range.

			for ($i = $this.Items.Count - 1; $i -gt $last; --$i) { $this.Items.RemoveAt($i) }

			for ($i = $first; $i -gt 0; --$i) { $this.Items.RemoveAt($i - 1) }

			foreach ($item in $this.Items) { --$item.Level }

			$this.SelectedIndex -= $first - 1
			$this.FirstIndexInView = [Math]::Max(0, $this.SelectedIndex - $this.ClientHeight() + 1)

			# Scrolling left doesn't make sense as abbreviated items would need to get
			# "un-abbreviated". Therefore, we'll just re-render everything.

			$this.DisplayItems()
			return
		}

		#endregion fix up data

		#region fix up visuals

		# ==========================================================================================
		# Scenarios:
		#
		# Terminology:
		#   Ix-yy     tree item at depth x with child index yy
		#   *         marks selected item
		#
		# Scenario 1:
		#
		#       Before                  After
		#       +---                    +---
		#  00:  | I1-05   ^             | I1-05       ^
		#  01:  | I1-06   | a           | I1-06       | a
		#  02:  | I1-07*  v             | I1-07       v
		#  03:  | I1-08   ^             |    I2-00*   ^
		#  04:  | I1-09   |             |    I2-01    | c
		#  05:  | I1-10   | b           |    I2-02    v
		#  06:  | I1-11   |             | I1-08       ^
		#  07:  | I1-12   |             | I1-09       | d = b - c
		#  08:  | I1-13   v             | I1-10       v
		#       +---                    +---
		#
		# Scenario 2:
		#
		#       Before                  After
		#       +---                    +---
		#  00:  | I1-05   ^             | I1-05       ^
		#  01:  | I1-06   |             | I1-06       |
		#  02:  | I1-07   | a           | I1-07       | a
		#  03:  | I1-08   |             | I1-08       |
		#  04:  | I1-09   |             | I1-09       |
		#  05:  | I1-10*  v             | I1-10       v
		#  06:  | I1-11   ^             |    I2-00*   ^
		#  07:  | I1-12   | b           |    I2-01    | c (might be less than child count)
		#  08:  | I1-13   v             |    I2-02    v
		#       +---                    +---
		#
		# Scenario 3:
		#
		#       Before                  After
		#       +---                    +---
		#  00:  | I1-05   ^             | I1-06       ^
		#  01:  | I1-06   |             | I1-07       |
		#  02:  | I1-07   |             | I1-08       |
		#  03:  | I1-08   |             | I1-09       | a - 1
		#  04:  | I1-09   | a           | I1-10       |
		#  05:  | I1-10   |             | I1-11       |
		#  06:  | I1-11   |             | I1-12       |
		#  07:  | I1-12   |             | I1-13       v
		#  08:  | I1-13*  v             |    I2-00*
		#       +---                    +---
		#

		$a = $this.SelectedIndex - $this.FirstIndexInView + 1
		$b = $this.ClientHeight() - $a;
		$c = [Math]::Min($directoryContent.Count, $b)
		$d = $b - $c

		if ($b -gt 0) {
			# scenarios 1, 2
			[Log]::Trace("TV.OpenSubDir: Scen1and2")

			if ($b -gt $c) {
				[Log]::Trace("TV.OpenSubDir: Scen1")

				# scenario 1

				# un-invert the selected item and change its icon to indicate expansion
				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)

				# make room for child items
				$this.ScrollAreaVertically($a, $this.ClientHeight() - 1, $c)

				# render child items
				for ($i = 0; $i -lt $c; ++$i) {

					if ($i -eq 0) {
						$fc = $this._backgroundColor
						$bc = $this._foregroundColor
					} else {
						$fc = $this._foregroundColor
						$bc = $this._backgroundColor
					}

					$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedIndex + $i + 1), $fc, $bc)
				}

				++$this.SelectedIndex

			} else {
				# scenario 2
				[Log]::Trace("TV.OpenSubDir: Scen2")

				# un-invert the selected item and change its icon to indicate expansion
				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)

				# render child items
				for ($i = 0; $i -lt $c; ++$i) {

					if ($i -eq 0) {
						$fc = $this._backgroundColor
						$bc = $this._foregroundColor
					} else {
						$fc = $this._foregroundColor
						$bc = $this._backgroundColor
					}

					$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedIndex + $i + 1), $fc, $bc)
				}

				++$this.SelectedIndex
			}
			
		} else {
			[Log]::Trace("TV.OpenSubDir: Scen3")
			
			assert ($b -eq 0)
			
			# scenario 3
			
			# un-invert the selected item and change its icon to indicate expansion
			$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)
			
			# make room for child items
			$this.ScrollAreaVertically(1, $this.ClientHeight() - 1, -1)

			$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex + 1), $this._backgroundColor, $this._foregroundColor)

			++$this.FirstIndexInView
			++$this.SelectedIndex
		}
		#endregion

		[Log]::EndSection("TV.OpenSubDir: FIIV=$($this.FirstIndexInView); SII=$($this.SelectedIndex)")
	}

	[void] CloseSubDir() {
		[Log]::BeginSection("TV.CloseSubDir")

		# Going up deepens the displayed tree. Is there a way to return it to the depth we started
		# at? Perhaps we can have a "sliding window" of the last n ancestral levels?

		# Q: should we right-shift a) whenever we drop beneath MaxLevelCount or b) when we're closing
		# level 0?
		# As we could have left folders expanded by going out of them via CursorUp/-Down, right-shifting
		# could create more than MaxLevelCount levels.

		if ($this.SelectedItem().Level -gt 0) {
			[uint32] $firstSibling, $lastSibling = $this.GetAncestralSiblingRange($this.SelectedIndex, 0)

			# iterating backwards for index consistency
			for ([uint32] $i = $lastSibling; $i -ge $firstSibling; --$i) { $this.Items.RemoveAt($i) }

			$this.SelectedIndex = $firstSibling - 1

			$this.FirstIndexInView = [Math]::Min($this.FirstIndexInView, $this.SelectedIndex)
			$this.DisplayItems()
		} else {
			$parent = if ($this.SelectedItem().Value -is [System.IO.DirectoryInfo]) {
				$this.SelectedItem().Value.Parent
			} else {
				$this.SelectedItem().Value.Directory
			}

			if ($parent -eq $null) { return }

			# As we're expanding the tree view toward the root, trim the nodes that would exceed the
			# maximum view depth. Also, adjust each node's level for the impending "right-shift".
			for ([uint32] $i = $this.Items.Count - 1; ; --$i) {
				if ($this.Items[$i].Level -eq $this.MaxLevelCount - 1) {
					$this.Items.RemoveAt($i)
				} else {
					++$this.Items[$i].Level
				}

				if ($i -eq 0) { break }
			}

			$this.Items.Insert(0, @{Level = 0; Value = $parent})

			if ($parent.Parent -ne $null) {
				[uint32] $insertPosition = 0

				foreach ($grandParentChild in $this.GetDirectoryContent($parent.Parent)) {
					if ($grandParentChild.Name -eq $parent.Name) {
						# item has already been inserted per the line above
						$this.SelectedIndex = $insertPosition
						$this.FirstIndexInView = [Math]::Min($this.FirstIndexInView, $this.SelectedIndex)
						$insertPosition = $this.Items.Count
					} else {
						$this.Items.Insert($insertPosition++, @{Level = 0; Value = $grandParentChild})
					}
				}
			}

			$this.DisplayItems()
		}

		[Log]::EndSection("TV.CloseSubDir")
	}

	[System.Collections.ArrayList] GetDirectoryContent([System.IO.DirectoryInfo] $directory) {
		# Be aware that FS items retrieved via PS drive provider commands (e.g. Get-Item or
		# Get-ChildItem) are annotated with 'PS*' properties (e.g. PSIsContainer). FS items
		# retrieved via "native" .NET methods or properties do not have these annotations.
		# Therefore, mixing drive provider and native retrieval methods can result in incongruous
		# objects and obscure bugs. Better exclusively use one or the other kind of retrieval
		# methods.

		$items = [System.Collections.ArrayList]::new()

		# TODO:
		# - accommodate a 'directories only' option
		# - accommodate file name patterns (perhaps by using the '-like' operator)

		foreach ($subDir in $directory.GetDirectories()) {
			if (($subDir.Attributes -band ([System.IO.FileAttributes]::Hidden)) -eq ([System.IO.FileAttributes]::Hidden)) { continue }
			if (($subDir.Attributes -band ([System.IO.FileAttributes]::System)) -eq ([System.IO.FileAttributes]::System)) { continue }

			$items.Add($subDir)
		}
		foreach ($file in $directory.GetFiles()) {
			if (($file.Attributes -band ([System.IO.FileAttributes]::Hidden)) -eq ([System.IO.FileAttributes]::Hidden)) { continue }
			if (($file.Attributes -band ([System.IO.FileAttributes]::System)) -eq ([System.IO.FileAttributes]::System)) { continue }
			$items.Add($file)
		}

		return $items
	}
}

class TreeView : ListBox {
	<# const #> [uint32] $MaxLevelCount = 4

	TreeView(
		[object[]] $items,
		[object] <# TypeInfo? #> $itemType,
		[int] $left,
		[int] $top,
		[int] $width,
		[int] $height,
		[ConsoleColor] $foregroundColor = $Global:Host.UI.RawUI.BackgroundColor,
		[ConsoleColor] $backgroundColor = $Global:Host.UI.RawUI.ForegroundColor
	) : base(
		(New-Object System.Collections.ArrayList),
		$left,
		$top,
		$width,
		$height,
		$foregroundColor,
		$backgroundColor
	) {
		$this.itemType = $itemType

		foreach ($item in $items) {
			$this.Items.Add($itemType::new($item)) | Out-Null
		}
	}

	[void] TraceItems() {
		for ($i = 0; $i -lt $this.Items.Count; ++$i) {
			if ($i -eq $this.FirstIndexInView) { $fiiv = ", FIIV" } else { $fiiv = "" }
			if ($i -eq $this.SelectedIndex) { $sii = ", SII" } else { $sii = "" }
			[Log]::Trace(("{0}: `"{1}`" L={2}{3}{4}" -f
				$i,
				$this.GetItemLabel($i),
				$this.Items[$i].Level(),
				$fiiv,
				$sii))
		}
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

			$this.WriteLine($i, $this.GetItemLabel($i), $fc, $bc)
		}

		$si = if ($this.Items.Count -gt 0) { $this.SelectedIndex + 1 } else { 0 }
		$this.WriteStatusBar("$si/$($this.Items.Count)")

		# skipping ListBox.OnShown()
		([Window]$this).OnShown()
	}

	[void] DisplayItems() {
		for ($y = 0; $y -lt $this.ClientHeight(); ++$y) {
			if ($this.FirstIndexInView + $y -lt $this.Items.Count) {
				if ($this.FirstIndexInView + $y -eq $this.SelectedIndex) {
					$fc = $this._backgroundColor
					$bc = $this._foregroundColor
				} else {
					$fc = $this._foregroundColor
					$bc = $this._backgroundColor
				}

				$this.WriteLine($y, $this.GetItemLabel($this.FirstIndexInView + $y), $fc, $bc)
			} else {
				$this.WriteLine($y, "", $this._foregroundColor, $this._backgroundColor)
			}
		}
	}

	[string] GetItemLabel($itemIndex) {
		[char] $icon = if ($this.Items[$itemIndex].IsContainer()) {
			if ($this.Items[$itemIndex].IsExpanded()) {
				<# black down-pointing triangle #> 0x25BC
			} else {
				<# black right-pointing pointer #> 0x25BA
			}
		} else {
			# <# black square #> 0x25A0
			<# black small square #> 0x25AA
		}

		return (' ' * 4 * ($this.Items[$itemIndex].Level() - $this.topLevelInView)) + $icon + ' ' + $this.Items[$itemIndex].Name()
	}

	[void] OnKey([System.ConsoleKeyInfo] $key) {
		[Log]::Trace("TV.OnKey: SII=$($this.SelectedIndex); SIN='$($this.SelectedItem().Name())'; K=$($key.Key)")

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

	[int[]] GetAncestralSiblingRange([uint32] $itemIndex, [uint32] $levelCount) {
		function GetFirstAtLevel([uint32] $i) {
			[uint32] $level = $this.Items[$i].Level()
			for (; ($i -gt 0) -and ($this.Items[$i - 1].Level() -ge $level); --$i) {}
			return $i
		}

		function GetLastAtLevel([uint32] $i) {
			[uint32] $level = $this.Items[$i].Level()
			for (; ($i -lt $this.Items.Count - 1) -and ($this.Items[$i + 1].Level() -ge $level); ++$i) {}
			return $i
		}

		[uint32] $first = GetFirstAtLevel $itemIndex
		[uint32] $last = GetLastAtLevel $itemIndex

		for ([uint32] $i = 1; $i -le $levelCount; ++$i) {
			if (($first -gt 0) -and ($this.Items[$first - 1].Level() -eq $this.Items[$itemIndex].Level() - $i)) {
				# assert($this.Items[$first - 1].Level() -eq $this.Items[$first].Level() - 1)
				$first = GetFirstAtLevel ($first - 1)
			}

			if (($last -lt $this.Items.Count - 1) -and ($this.Items[$last + 1].Level() -eq $this.Items[$itemIndex].Level() - $i)) {
				# assert($this.Items[$last + 1].Level() -lt $this.Items[$last].Level())
				$last = GetLastAtLevel ($last + 1)
			}
		}

		return $first, $last
	}

	[void] Expand() {
		[Log]::BeginSection("TV.Expand: FIIV=$($this.FirstIndexInView); SII=$($this.SelectedIndex)")

		do { # curb nesting depth

			# Can the item be expanded?
			if (!$this.SelectedItem().IsContainer()) {
				[console]::Beep(300, 100)
				break
			}

			# Is the item already expanded?
			if ($this.SelectedItem().IsExpanded()) {
				[console]::Beep(300, 100)
				break
			}

			$children = $this.SelectedItem().Children()

			if ($children.Count -eq 0) {
				[console]::Beep(300, 100)
				break
			}

			#region fix up data

			[uint32] $ii = $this.SelectedIndex
			foreach ($child in $children) {
				$this.Items.Insert(++$ii, $child)
			}

			if (($this.SelectedItem().Level() - $this.topLevelInView) -eq ($this.MaxLevelCount - 1)) {
				if ([Log]::Listeners.Count -gt 0) {
					[Log]::Trace("TV.Expand: MaxLevel overflow")
					$this.TraceItems()
				}

				# I0-00
				#     I1-00 <-- first
				#     I1-01
				#         I2-00
				#         I2-01
				#             I3-00 *
				#                 ... (items about to get expanded)
				#             I3-01
				#         I2-02
				#     I1-02 <-- last
				# I0-1

				# Level we're about to expand would exceed maximum levels. "Left-shift" levels.

				$first, $last = $this.GetAncestralSiblingRange($this.SelectedIndex, $this.SelectedItem().Level() - 1)
				[Log]::Trace("TV.Expand: first=$first, last=$last")

				# Prune every item outside of [$first, $last]
				for ($i = $this.Items.Count - 1; $i -gt $last; --$i) { $this.Items.RemoveAt($i) }
				for ($i = $first; $i -gt 0; --$i) { $this.Items.RemoveAt($i - 1) }

				++$this.topLevelInView

				$this.SelectedIndex -= $first - 1
				$this.FirstIndexInView = [Math]::Max(0, $this.SelectedIndex - $this.ClientHeight() + 1)

				# Scrolling left doesn't make sense as abbreviated items would need to get
				# "un-abbreviated". Therefore, we'll just re-render everything.

				$this.DisplayItems()
				break
			}

			#endregion fix up data

			#region fix up visuals

			# ==========================================================================================
			# Scenarios:
			#
			# Terminology:
			#   Ix-yy     tree item at depth x with child index yy
			#   *         marks selected item
			#
			# Scenario 1:
			#
			#       Before                  After
			#       +---                    +---
			#  00:  | I1-05   ^             | I1-05       ^
			#  01:  | I1-06   | a           | I1-06       | a
			#  02:  | I1-07*  v             | I1-07       v
			#  03:  | I1-08   ^             |    I2-00*   ^
			#  04:  | I1-09   |             |    I2-01    | c
			#  05:  | I1-10   | b           |    I2-02    v
			#  06:  | I1-11   |             | I1-08       ^
			#  07:  | I1-12   |             | I1-09       | d = b - c
			#  08:  | I1-13   v             | I1-10       v
			#       +---                    +---
			#
			# Scenario 2:
			#
			#       Before                  After
			#       +---                    +---
			#  00:  | I1-05   ^             | I1-05       ^
			#  01:  | I1-06   |             | I1-06       |
			#  02:  | I1-07   | a           | I1-07       | a
			#  03:  | I1-08   |             | I1-08       |
			#  04:  | I1-09   |             | I1-09       |
			#  05:  | I1-10*  v             | I1-10       v
			#  06:  | I1-11   ^             |    I2-00*   ^
			#  07:  | I1-12   | b           |    I2-01    | c (might be less than child count)
			#  08:  | I1-13   v             |    I2-02    v
			#       +---                    +---
			#
			# Scenario 3:
			#
			#       Before                  After
			#       +---                    +---
			#  00:  | I1-05   ^             | I1-06       ^
			#  01:  | I1-06   |             | I1-07       |
			#  02:  | I1-07   |             | I1-08       |
			#  03:  | I1-08   |             | I1-09       | a - 1
			#  04:  | I1-09   | a           | I1-10       |
			#  05:  | I1-10   |             | I1-11       |
			#  06:  | I1-11   |             | I1-12       |
			#  07:  | I1-12   |             | I1-13       v
			#  08:  | I1-13*  v             |    I2-00*
			#       +---                    +---
			#

			$a = $this.SelectedIndex - $this.FirstIndexInView + 1
			$b = $this.ClientHeight() - $a;
			$c = [Math]::Min($children.Count, $b)
			$d = $b - $c

			if ($b -gt 0) {
				# scenarios 1, 2
				[Log]::Trace("TV.Expand: Scen1and2")

				if ($b -gt $c) {
					[Log]::Trace("TV.Expand: Scen1")

					# scenario 1

					# un-invert the selected item and change its icon to indicate expansion
					$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)

					# make room for child items
					$this.ScrollAreaVertically($a, $this.ClientHeight() - 1, $c)

					# render child items
					for ($i = 0; $i -lt $c; ++$i) {

						if ($i -eq 0) {
							$fc = $this._backgroundColor
							$bc = $this._foregroundColor
						} else {
							$fc = $this._foregroundColor
							$bc = $this._backgroundColor
						}

						$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedIndex + $i + 1), $fc, $bc)
					}

					++$this.SelectedIndex

				} else {
					# scenario 2
					[Log]::Trace("TV.Expand: Scen2")

					# un-invert the selected item and change its icon to indicate expansion
					$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)

					# render child items
					for ($i = 0; $i -lt $c; ++$i) {

						if ($i -eq 0) {
							$fc = $this._backgroundColor
							$bc = $this._foregroundColor
						} else {
							$fc = $this._foregroundColor
							$bc = $this._backgroundColor
						}

						$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedIndex + $i + 1), $fc, $bc)
					}

					++$this.SelectedIndex
				}
				
			} else {
				[Log]::Trace("TV.Expand: Scen3")
				
				assert ($b -eq 0)
				
				# scenario 3
				
				# un-invert the selected item and change its icon to indicate expansion
				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex), $this._foregroundColor, $this._backgroundColor)
				
				# make room for child items
				$this.ScrollAreaVertically(1, $this.ClientHeight() - 1, -1)

				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedIndex + 1), $this._backgroundColor, $this._foregroundColor)

				++$this.FirstIndexInView
				++$this.SelectedIndex
			}
			#endregion

		} while ($false)

		[Log]::EndSection("TV.Expand: FIIV=$($this.FirstIndexInView); SII=$($this.SelectedIndex)")
	}

	[void] Collapse() {
		[Log]::BeginSection("TV.Collapse")
		try {

			# Going up deepens the displayed tree. Is there a way to return it to the depth we started
			# at? Perhaps we can have a "sliding window" of the last n ancestral levels?

			# Q: should we right-shift a) whenever we drop beneath MaxLevelCount or b) when we're closing
			# level 0?
			# As we could have left folders expanded by going out of them via CursorUp/-Down, right-shifting
			# could create more than MaxLevelCount levels.

			if ($this.SelectedItem().Level() -gt $this.topLevelInView) {
				[uint32] $firstSibling, $lastSibling = $this.GetAncestralSiblingRange($this.SelectedIndex, 0)

				# remove collapsed items (iterating backwards for index consistency)
				for ([uint32] $i = $lastSibling; $i -ge $firstSibling; --$i) { $this.Items.RemoveAt($i) }

				$this.SelectedIndex = $firstSibling - 1

				$this.FirstIndexInView = [Math]::Min($this.FirstIndexInView, $this.SelectedIndex)
				$this.DisplayItems()
			} else {
				$parent = $this.SelectedItem().Parent()

				if ($parent -eq $null) { return }

				# As we're expanding the tree view toward the root, trim the nodes that would exceed the
				# maximum view depth.
				for ([uint32] $i = $this.Items.Count - 1; ; --$i) {
					if (($this.Items[$i].Level() - $this.topLevelInView) -ge ($this.MaxLevelCount - 1)) {
						$this.Items.RemoveAt($i)
					}
					if ($i -eq 0) { break }
				}

				
				$this.Items.Insert(0, $parent)
				--$this.topLevelInView # equivalent to assigning '$parent.Level()'

				if ($parent.Parent() -ne $null) {
					[uint32] $insertPosition = 0

					foreach ($grandParentChild in $parent.Parent().Children()) {
						if ($grandParentChild.Name -eq $parent.Name) {
							# item has already been inserted per the line above
							$this.SelectedIndex = $insertPosition
							$this.FirstIndexInView = [Math]::Min($this.FirstIndexInView, $this.SelectedIndex)
							$insertPosition = $this.Items.Count
						} else {
							$this.Items.Insert($insertPosition++, $grandParentChild)
						}
					}
				}

				$this.DisplayItems()
			}
		} finally {

			[Log]::EndSection("TV.Collapse")
		}
	}

	hidden [object] <# TypeInfo? #> $itemType
	hidden [uint32] $topLevelInView = 0
}

