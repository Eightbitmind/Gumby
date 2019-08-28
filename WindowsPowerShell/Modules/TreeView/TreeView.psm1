using module ListBox
using module Window

function Log($message) {
	#Write-Host 
	$message | Out-File -Append -FilePath "$($env:TEMP)\TreeView.log"
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

	[void] OnShown() {
		for ($i = 0; $i -lt [Math]::Min($this.Items.Count, $this.ClientHeight()); ++$i) {

			if ($i -eq $this.SelectedItemIndex) {
				$fc = $this._backgroundColor
				$bc = $this._foregroundColor
			} else {
				$fc = $this._foregroundColor
				$bc = $this._backgroundColor
			}

			$this.WriteLine($i, $this.GetItemLabel($i), $fc, $bc)
		}

		$si = if ($this.Items.Count -gt 0) { $this.SelectedItemIndex + 1 } else { 0 }
		$this.WriteStatusBar("$si/$($this.Items.Count)")

		# skipping ListBox.OnShown()
		([Window]$this).OnShown()
	}

	[void] DisplayItems() {
		for ($y = 0; $y -lt $this.ClientHeight(); ++$y) {
			if ($this._firstIndexInView + $y -lt $this.Items.Count) {
				if ($this._firstIndexInView + $y -eq $this.SelectedItemIndex) {
					$fc = $this._backgroundColor
					$bc = $this._foregroundColor
				} else {
					$fc = $this._foregroundColor
					$bc = $this._backgroundColor
				}

				$this.WriteLine($y, $this.GetItemLabel($this._firstIndexInView + $y), $fc, $bc)
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
		# debug
		# Log "L='$($this.SelectedItem().Value.FullName)'; KC=$key"

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
Log "entering TV.OpenSubDir"

		# Is the item already expanded?
		if (($this.SelectedItemIndex -lt $this.Items.Count - 1) -and
			($this.Items[$this.SelectedItemIndex + 1].Level -eq $this.SelectedItem().Level + 1)
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

		$a = $this.SelectedItemIndex - $this._firstIndexInView + 1
		$b = $this.ClientHeight() - $a;
		$c = [Math]::Min($directoryContent.Count, $b)
		$d = $b - $c

		# --- fix up data ---

		if ($this.SelectedItem().Level -eq $this.MaxLevelCount - 1) {
			# Level we're about to expand would exceed maximum levels. "Left-shift" levels.

			$first, $last = $this.GetAncestralSiblingRange($this.SelectedItemIndex, $this.SelectedItem().Level - 1)

			# Prune every item outside of [$first, $last], promote everything inside that range.

			for ($i = $this.Items.Count - 1; $i -gt $last; --$i) { $this.Items.RemoveAt($i) }

			for ($i = $first; $i -gt 0; --$i) { $this.Items.RemoveAt($i - 1) }

			foreach ($item in $this.Items) { --$item.Level }

			$this.SelectedItemIndex -= $first
		}

		[uint32] $ii = $this.SelectedItemIndex
		foreach ($fsItem in $directoryContent) {
			$this.Items.Insert(++$ii, @{Level = $this.SelectedItem().Level + 1; Value = $fsItem})
		}

		++$this.SelectedItemIndex

		$this.DisplayItems()

		return

		# --- fix up visuals ---

		if ($b -gt 0) {
			# scenarios 1, 2
#Log "TV.OpenSubDir.Scen1and2"

			if ($b -gt $c) {
#Log "TV.OpenSubDir.Scen1"

				# scenario 1

				# un-invert the selected item and change its icon to indicate expansion
				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedItemIndex), $this._foregroundColor, $this._backgroundColor)

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

					$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedItemIndex + $i + 1), $fc, $bc)
				}

				++$this.SelectedItemIndex

			} else {
				# scenario 2
#Log "TV.OpenSubDir.Scen2"

				# un-invert the selected item and change its icon to indicate expansion
				$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedItemIndex), $this._foregroundColor, $this._backgroundColor)

				# render child items
				for ($i = 0; $i -lt $c; ++$i) {

					if ($i -eq 0) {
						$fc = $this._backgroundColor
						$bc = $this._foregroundColor
					} else {
						$fc = $this._foregroundColor
						$bc = $this._backgroundColor
					}

					$this.WriteLine($a + $i, $this.GetItemLabel($this.SelectedItemIndex + $i + 1), $fc, $bc)
				}

				++$this.SelectedItemIndex
			}
			
		} else {
#Log "TV.OpenSubDir.Scen3"
			
			assert ($b -eq 0)
			
			# scenario 3
			
			# un-invert the selected item and change its icon to indicate expansion
			$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedItemIndex), $this._foregroundColor, $this._backgroundColor)
			
			# make room for child items
			$this.ScrollAreaVertically(1, $this.ClientHeight() - 1, -1)

			$this.WriteLine($a - 1, $this.GetItemLabel($this.SelectedItemIndex + 1), $this._backgroundColor, $this._foregroundColor)

			++$this._firstIndexInView
			++$this.SelectedItemIndex
		}

Log "leaving TV.OpenSubDir"
	}

	[void] CloseSubDir() {
Log "entering TV.CloseSubDir"

		# Going up deepens the displayed tree. Is there a way to return it to the depth we started
		# at? Perhaps we can have a "sliding window" of the last n ancestral levels?

		# Q: should we right-shift a) whenever we drop beneath MaxLevelCount or b) when we're closing
		# level 0?
		# As we could have left folders expanded by going out of them via CursorUp/-Down, right-shifting
		# could create more than MaxLevelCount levels.

		if ($this.SelectedItem().Level -gt 0) {
			[uint32] $firstSibling, $lastSibling = $this.GetAncestralSiblingRange($this.SelectedItemIndex, 0)

			# iterating backwards for index consistency
			for ([uint32] $i = $lastSibling; $i -ge $firstSibling; --$i) { $this.Items.RemoveAt($i) }

			$this.SelectedItemIndex = $firstSibling - 1

			$this._firstIndexInView = [Math]::Min($this._firstIndexInView, $this.SelectedItemIndex)
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
						$this.SelectedItemIndex = $insertPosition
						$this._firstIndexInView = [Math]::Min($this._firstIndexInView, $this.SelectedItemIndex)
						$insertPosition = $this.Items.Count
					} else {
						$this.Items.Insert($insertPosition++, @{Level = 0; Value = $grandParentChild})
					}
				}
			}

			$this.DisplayItems()
		}
Log "leaving TV.CloseSubDir"
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
