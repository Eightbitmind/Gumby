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
		TestIsNull $tvi.Parent()
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
		TestIsNotNull $tvi.Children()[0].Parent()
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

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([SimpleObjectTVItemTests]) ([FileTVItemTests])
