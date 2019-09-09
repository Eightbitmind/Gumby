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

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([SimpleObjectTVItemTests])
