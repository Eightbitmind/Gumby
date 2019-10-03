using module Path
using module TestUtils
using module Window

# notational shorthands
function coords($X, $Y) { return [System.Management.Automation.Host.Coordinates]::new($X, $Y) }
function rect($Left, $Top, $Right, $Bottom) { return [System.Management.Automation.Host.Rectangle]::new($Left, $Top, $Right, $Bottom) }
function white() {return ([ConsoleColor]::White)}
function black() {return ([ConsoleColor]::Black)}


[TestClass()]
class TextBufferTests {

	[TestMethod()]
	[void] CongruentTextAndTarget(){
		
		$b = [TextBuffer]::new()
		$b.AddLine("aaa", (white), (black))
		$b.AddLine("bbb", (white), (black))
		$b.AddLine("ccc", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 0 0))

		TestTuplesAreEqual $stripes $tvi.Name() "Flintstone"
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
RunTests $standaloneLogFilePath ([TextBufferTests])
