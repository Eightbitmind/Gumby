using module Gumby.Path
using module Gumby.Test

using module ".\TreeView.psm1"

[TestClass()]
class SimpleObjectTVItemTests {
	[object] $simpleObject = @{
		Name = "Flintstone"
		Children = @(
			@{ Name = "Fred" }
			@{ Name = "Wilma" }
			@{ Name = "Pebbles" }
		)
	}

	[TestMethod()]
	[void] Name_Root_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test "Flintstone" $tvi.Name()
	}

	[TestMethod()]
	[void] Level_Root_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test 0 $tvi.Level()
	}

	[TestMethod()]
	[void] IsContainer_Root_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test $true $tvi.IsContainer()
	}

	[TestMethod()]
	[void] IsExpanded_RootInitially_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test $false $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] IsExpanded_RootAfterExpansion_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		$tvi.Expand()
		Test $true $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] IsExpanded_RootAfterCollapse_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		$tvi.Expand()
		$tvi.Collapse()
		Test $false $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] Parent_Root_IsNull() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test $null $tvi.Parent()
	}

	[TestMethod()]
	[void] ChildrenCount_Root_AsExpected() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test 3 $tvi.Children().Count
	}

	[TestMethod()]
	[void] Name_FirstChild_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test "Fred" $tvi.Children()[0].Name()
	}

	[TestMethod()]
	[void] Level_FirstChild_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test 1 $tvi.Children()[0].Level()
	}

	[TestMethod()]
	[void] IsContainer_FirstChild_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test $false $tvi.Children()[0].IsContainer()
	}

	[TestMethod()]
	[void] IsExpanded_FirstChild_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test $false $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] Parent_FirstChild_IsNotNull() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test (ExpectNotNull) $tvi.Children()[0].Parent()
	}

	[TestMethod()]
	[void] Parent_FirstChild_HasExpectedName() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test "Flintstone" $tvi.Children()[0].Parent().Name()
	}

	[TestMethod()]
	[void] ChildrenCount_FirstChild_AsExpected() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		Test 0 $tvi.Children()[0].Children().Count
	}
}

[TestClass()]
class FileTVItemTests {
	hidden [string] $rootDirPath = "$env:TEMP\FileTVItemTests"
	hidden [IO.FileSystemInfo] $rootDir

	[TestClassSetup()]
	[void] CreateTestDirectories() {
		
		if (Test-Path $this.rootDirPath) { Remove-Item -Recurse -Force $this.rootDirPath }
		mkdir $this.rootDirPath
		mkdir "$($this.rootDirPath)\A1"
		mkdir "$($this.rootDirPath)\A2"

		mkdir "$($this.rootDirPath)\A1\B1"
		mkdir "$($this.rootDirPath)\A1\B2"
		mkdir "$($this.rootDirPath)\A2\B3"
		mkdir "$($this.rootDirPath)\A2\B4"

		mkdir "$($this.rootDirPath)\A1\B1\C1"
		mkdir "$($this.rootDirPath)\A1\B1\C2"
		mkdir "$($this.rootDirPath)\A1\B2\C3"
		mkdir "$($this.rootDirPath)\A1\B2\C4"

		mkdir "$($this.rootDirPath)\A2\B3\C5"
		mkdir "$($this.rootDirPath)\A2\B3\C6"
		mkdir "$($this.rootDirPath)\A2\B4\C7"
		mkdir "$($this.rootDirPath)\A2\B4\C8"

		Out-File -InputObject "a1f1" -FilePath "$($this.rootDirPath)\A1\a1f1.txt" -Encoding ascii
		Out-File -InputObject "a1f2" -FilePath "$($this.rootDirPath)\A1\a1f2.txt" -Encoding ascii

		Out-File -InputObject "b1f1" -FilePath "$($this.rootDirPath)\A1\B1\b1f1.txt" -Encoding ascii
		Out-File -InputObject "b1f2" -FilePath "$($this.rootDirPath)\A1\B1\b1f2.txt" -Encoding ascii

		$this.rootDir = Get-Item $this.rootDirPath
	}

	[TestClassTeardown()]
	[void] RemoveTestDirectories() {
		Remove-Item -Recurse -Force $this.rootDirPath
	}

	[TestMethod()]
	[void] Name_Root() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test "FileTVItemTests" $tvi.Name()
	}

	[TestMethod()]
	[void] IsContainer_Root() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test $true $tvi.IsContainer()
	}

	[TestMethod()]
	[void] Children_Root_ExpectedCount() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test 2 $tvi.Children().Count
	}

	[TestMethod()]
	[void] Children_Root_ExpectedItems() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test "A1" $tvi.Children()[0].Name()
		Test "A2" $tvi.Children()[1].Name()
	}

	[TestMethod()]
	[void] Children_A1_ExpectedCount() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test 4 $tvi.Children()[0].Children().Count
	}

	[TestMethod()]
	[void] Children_A1_ExpectedItems() {
		$tvi = [FileTVItem]::new($this.rootDir)
		Test "B1" $tvi.Children()[0].Children()[0].Name()
		Test "B2" $tvi.Children()[0].Children()[1].Name()
		Test "a1f1.txt" $tvi.Children()[0].Children()[2].Name()
		Test "a1f2.txt" $tvi.Children()[0].Children()[3].Name()
	}

	[TestMethod()]
	[void] IsContainer_B1_True() {
		$root = [FileTVItem]::new($this.rootDir)
		Test $true $root.Children()[0].Children()[0].IsContainer()
	}

	[TestMethod()]
	[void] Parent_B1_A1() {
		$root = [FileTVItem]::new($this.rootDir)
		Test "A1" $root.Children()[0].Children()[0].Parent().Name()
	}

	[TestMethod()]
	[void] IsContainer_a1f1_False() {
		$root = [FileTVItem]::new($this.rootDir)
		$a1f1 = $root.Children()[0].Children()[2]
		Test "a1f1.txt" $a1f1.Name()
		Test $false $a1f1.IsContainer()
	}

	[TestMethod()]
	[void] Parent_a1f1_A1() {
		$root = [FileTVItem]::new($this.rootDir)
		$a1f1 = $root.Children()[0].Children()[2]
		Test "a1f1.txt" $a1f1.Name()
		Test "A1" $a1f1.Parent().Name()
	}
}

class GASRTestItem : TVItemBase {
	GASRTestItem([object] $inner) {
		$this._inner = $inner
	}

	[string] Name() { return $this._inner.Name }
	[uint32] Level() {
		# Get past the initial "top-level in view" check
		if ($this._initialLevelCall) {
			$this._initialLevelCall = $false
			return 0
		}

		return $this._inner.Level
	}
	[bool] IsContainer() { return $true }

	hidden [object] $_inner
	hidden [uint32] $_initialLevelCall = $true
}

[TestClass()]
class TreeViewTests {

	[TestMethod()]
	[void] GetAncestralSiblingRange01() {
		$forest =
			<# 0 #> @{ Name = "A"            ; Level = 0},
			<# 1 #> @{ Name =     "C"        ; Level = 1},
			<# 2 #> @{ Name = "B"            ; Level = 0},
			<# 3 #> @{ Name =     "D"        ; Level = 1},
			<# 4 #> @{ Name =         "F"    ; Level = 2},
			<# 5 #> @{ Name =             "I"; Level = 3},
			<# 6 #> @{ Name =         "G"    ; Level = 2},
			<# 7 #> @{ Name =         "H"    ; Level = 2},
			<# 8 #> @{ Name =     "E"        ; Level = 1}

		$tv = [TreeView]::new(
			$forest,
			[GASRTestItem],
			0, 0, 10, 10, [System.ConsoleColor]::Black, [System.ConsoleColor]::White)

		Test (0, 8) $tv.GetAncestralSiblingRange(0, 0)
		Test (0, 8) $tv.GetAncestralSiblingRange(0, 1)

		Test (1, 1) $tv.GetAncestralSiblingRange(1, 0)
		Test (0, 8) $tv.GetAncestralSiblingRange(1, 1)

		Test (0, 8) $tv.GetAncestralSiblingRange(2, 0)
		Test (0, 8) $tv.GetAncestralSiblingRange(2, 1)

		Test (3, 8) $tv.GetAncestralSiblingRange(3, 0)
		Test (0, 8) $tv.GetAncestralSiblingRange(3, 1)
		Test (0, 8) $tv.GetAncestralSiblingRange(3, 2)

		Test (4, 7) $tv.GetAncestralSiblingRange(4, 0)
		Test (3, 8) $tv.GetAncestralSiblingRange(4, 1)
		Test (0, 8) $tv.GetAncestralSiblingRange(4, 2)
		Test (0, 8) $tv.GetAncestralSiblingRange(4, 3)

		Test (5, 5) $tv.GetAncestralSiblingRange(5, 0)
		Test (4, 7) $tv.GetAncestralSiblingRange(5, 1)
		Test (3, 8) $tv.GetAncestralSiblingRange(5, 2)
		Test (0, 8) $tv.GetAncestralSiblingRange(5, 3)
		Test (0, 8) $tv.GetAncestralSiblingRange(5, 4)

		Test (4, 7) $tv.GetAncestralSiblingRange(6, 0)
		Test (3, 8) $tv.GetAncestralSiblingRange(6, 1)
		Test (0, 8) $tv.GetAncestralSiblingRange(6, 2)
		Test (0, 8) $tv.GetAncestralSiblingRange(6, 3)

		Test (4, 7) $tv.GetAncestralSiblingRange(7, 0)
		Test (3, 8) $tv.GetAncestralSiblingRange(7, 1)
		Test (0, 8) $tv.GetAncestralSiblingRange(7, 2)
		Test (0, 8) $tv.GetAncestralSiblingRange(7, 3)
	}

	[TestMethod()]
	[void] GetAncestralSiblingRange02() {
		$forest =
			<# 0 #> @{ Name = "A"            ; Level = 0},
			<# 1 #> @{ Name =     "C"        ; Level = 1},
			<# 2 #> @{ Name =         "F"    ; Level = 2},
			<# 3 #> @{ Name =             "G"; Level = 3},
			<# 4 #> @{ Name = "B"            ; Level = 0},
			<# 5 #> @{ Name =     "D"        ; Level = 1},
			<# 6 #> @{ Name =     "E"        ; Level = 1}

		$tv = [TreeView]::new(
			$forest,
			[GASRTestItem],
			0, 0, 10, 10, [System.ConsoleColor]::Black, [System.ConsoleColor]::White)

		Test (0, 6) $tv.GetAncestralSiblingRange(0, 0)
		Test (0, 6) $tv.GetAncestralSiblingRange(0, 1)
		Test (0, 6) $tv.GetAncestralSiblingRange(0, 2)

		Test (1, 3) $tv.GetAncestralSiblingRange(1, 0)
		Test (0, 6) $tv.GetAncestralSiblingRange(1, 1)
		Test (0, 6) $tv.GetAncestralSiblingRange(1, 2)

		Test (2, 3) $tv.GetAncestralSiblingRange(2, 0)
		Test (1, 3) $tv.GetAncestralSiblingRange(2, 1)
		Test (0, 6) $tv.GetAncestralSiblingRange(2, 2)
		Test (0, 6) $tv.GetAncestralSiblingRange(2, 3)

		Test (3, 3) $tv.GetAncestralSiblingRange(3, 0)
		Test (2, 3) $tv.GetAncestralSiblingRange(3, 1)
		Test (1, 3) $tv.GetAncestralSiblingRange(3, 2)
		Test (0, 6) $tv.GetAncestralSiblingRange(3, 3)
		Test (0, 6) $tv.GetAncestralSiblingRange(3, 4)

		Test (0, 6) $tv.GetAncestralSiblingRange(4, 0)
		Test (0, 6) $tv.GetAncestralSiblingRange(4, 1)

		Test (5, 6) $tv.GetAncestralSiblingRange(5, 0)
		Test (0, 6) $tv.GetAncestralSiblingRange(5, 1)
		Test (0, 6) $tv.GetAncestralSiblingRange(5, 2)

		Test (5, 6) $tv.GetAncestralSiblingRange(6, 0)
		Test (0, 6) $tv.GetAncestralSiblingRange(6, 1)
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([SimpleObjectTVItemTests]) ([FileTVItemTests]) ([TreeViewTests])
