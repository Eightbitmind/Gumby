using module Path
using module TreeView
using module TestUtils

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
		TestAreEqual $tvi.Name() "Flintstone"
	}

	[TestMethod()]
	[void] Level_Root_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Level() 0
	}

	[TestMethod()]
	[void] IsContainer_Root_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestIsTrue $tvi.IsContainer()
	}

	[TestMethod()]
	[void] IsExpanded_RootInitially_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestIsFalse $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] IsExpanded_RootAfterExpansion_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		$tvi.Expand()
		TestIsTrue $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] IsExpanded_RootAfterCollapse_IsTrue(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		$tvi.Expand()
		$tvi.Collapse()
		TestIsFalse $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] Parent_Root_IsNull() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestObject $tvi.Parent() $null
	}

	[TestMethod()]
	[void] ChildrenCount_Root_AsExpected() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Children().Count 3
	}

	[TestMethod()]
	[void] Name_FirstChild_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Children()[0].Name() "Fred"
	}

	[TestMethod()]
	[void] Level_FirstChild_AsExpected(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Children()[0].Level() 1
	}

	[TestMethod()]
	[void] IsContainer_FirstChild_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestIsFalse $tvi.Children()[0].IsContainer()
	}

	[TestMethod()]
	[void] IsExpanded_FirstChild_IsFalse(){
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestIsFalse $tvi.IsExpanded()
	}

	[TestMethod()]
	[void] Parent_FirstChild_IsNotNull() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestObject $tvi.Children()[0].Parent() (ExpectNotNull)
	}

	[TestMethod()]
	[void] Parent_FirstChild_HasExpectedName() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Children()[0].Parent().Name() "Flintstone"
	}

	[TestMethod()]
	[void] ChildrenCount_FirstChild_AsExpected() {
		$tvi = [SimpleObjectTVItem]::new($this.simpleObject)
		TestAreEqual $tvi.Children()[0].Children().Count 0
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
		TestAreEqual $tvi.Name() "FileTVItemTests"
	}

	[TestMethod()]
	[void] IsContainer_Root() {
		$tvi = [FileTVItem]::new($this.rootDir)
		TestIsTrue $tvi.IsContainer()
	}

	[TestMethod()]
	[void] Children_Root_ExpectedCount() {
		$tvi = [FileTVItem]::new($this.rootDir)
		TestAreEqual $tvi.Children().Count 2
	}

	[TestMethod()]
	[void] Children_Root_ExpectedItems() {
		$tvi = [FileTVItem]::new($this.rootDir)
		TestAreEqual $tvi.Children()[0].Name() "A1"
		TestAreEqual $tvi.Children()[1].Name() "A2"
	}

	[TestMethod()]
	[void] Children_A1_ExpectedCount() {
		$tvi = [FileTVItem]::new($this.rootDir)
		TestAreEqual $tvi.Children()[0].Children().Count 4
	}

	[TestMethod()]
	[void] Children_A1_ExpectedItems() {
		$tvi = [FileTVItem]::new($this.rootDir)
		TestAreEqual $tvi.Children()[0].Children()[0].Name() "B1"
		TestAreEqual $tvi.Children()[0].Children()[1].Name() "B2"
		TestAreEqual $tvi.Children()[0].Children()[2].Name() "a1f1.txt"
		TestAreEqual $tvi.Children()[0].Children()[3].Name() "a1f2.txt"
	}

	[TestMethod()]
	[void] IsContainer_B1_True() {
		$root = [FileTVItem]::new($this.rootDir)
		TestIsTrue $root.Children()[0].Children()[0].IsContainer()
	}

	[TestMethod()]
	[void] Parent_B1_A1() {
		$root = [FileTVItem]::new($this.rootDir)
		TestAreEqual $root.Children()[0].Children()[0].Parent().Name() "A1"
	}

	[TestMethod()]
	[void] IsContainer_a1f1_False() {
		$root = [FileTVItem]::new($this.rootDir)
		$a1f1 = $root.Children()[0].Children()[2]
		TestAreEqual $a1f1.Name() "a1f1.txt"
		TestIsFalse $a1f1.IsContainer()
	}

	[TestMethod()]
	[void] Parent_a1f1_A1() {
		$root = [FileTVItem]::new($this.rootDir)
		$a1f1 = $root.Children()[0].Children()[2]
		TestAreEqual $a1f1.Name() "a1f1.txt"
		TestAreEqual $a1f1.Parent().Name() "A1"
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

		TestObject $tv.GetAncestralSiblingRange(0, 0) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(0, 1) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(1, 0) (1, 1)
		TestObject $tv.GetAncestralSiblingRange(1, 1) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(2, 0) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(2, 1) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(3, 0) (3, 8)
		TestObject $tv.GetAncestralSiblingRange(3, 1) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(3, 2) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(4, 0) (4, 7)
		TestObject $tv.GetAncestralSiblingRange(4, 1) (3, 8)
		TestObject $tv.GetAncestralSiblingRange(4, 2) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(4, 3) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(5, 0) (5, 5)
		TestObject $tv.GetAncestralSiblingRange(5, 1) (4, 7)
		TestObject $tv.GetAncestralSiblingRange(5, 2) (3, 8)
		TestObject $tv.GetAncestralSiblingRange(5, 3) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(5, 4) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(6, 0) (4, 7)
		TestObject $tv.GetAncestralSiblingRange(6, 1) (3, 8)
		TestObject $tv.GetAncestralSiblingRange(6, 2) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(6, 3) (0, 8)

		TestObject $tv.GetAncestralSiblingRange(7, 0) (4, 7)
		TestObject $tv.GetAncestralSiblingRange(7, 1) (3, 8)
		TestObject $tv.GetAncestralSiblingRange(7, 2) (0, 8)
		TestObject $tv.GetAncestralSiblingRange(7, 3) (0, 8)
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

		TestObject $tv.GetAncestralSiblingRange(0, 0) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(0, 1) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(0, 2) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(1, 0) (1, 3)
		TestObject $tv.GetAncestralSiblingRange(1, 1) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(1, 2) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(2, 0) (2, 3)
		TestObject $tv.GetAncestralSiblingRange(2, 1) (1, 3)
		TestObject $tv.GetAncestralSiblingRange(2, 2) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(2, 3) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(3, 0) (3, 3)
		TestObject $tv.GetAncestralSiblingRange(3, 1) (2, 3)
		TestObject $tv.GetAncestralSiblingRange(3, 2) (1, 3)
		TestObject $tv.GetAncestralSiblingRange(3, 3) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(3, 4) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(4, 0) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(4, 1) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(5, 0) (5, 6)
		TestObject $tv.GetAncestralSiblingRange(5, 1) (0, 6)
		TestObject $tv.GetAncestralSiblingRange(5, 2) (0, 6)

		TestObject $tv.GetAncestralSiblingRange(6, 0) (5, 6)
		TestObject $tv.GetAncestralSiblingRange(6, 1) (0, 6)
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([SimpleObjectTVItemTests]) ([FileTVItemTests]) ([TreeViewTests])
