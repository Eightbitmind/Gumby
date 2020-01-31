using module Path
using module TestUtils
using module TextBuffer

# notational shorthands
function coords($X, $Y) { return [System.Management.Automation.Host.Coordinates]::new($X, $Y) }
function rect($Left, $Top, $Right, $Bottom) { return [System.Management.Automation.Host.Rectangle]::new($Left, $Top, $Right, $Bottom) }
function white() {return ([ConsoleColor]::White)}
function black() {return ([ConsoleColor]::Black)}
function bca($text, $foregroundColor, $backgroundColor){ return $Host.UI.RawUI.NewBufferCellArray(@($text), $foregroundColor, $backgroundColor) }

[TestClass()]
class TextBufferTests {
	[TestMethod()]
	[void] AddLine(){
		$b = [TextBuffer]::new((white), (black))
		Test 0 $b.LineCount()
		
		$b.AddLine("abc", (white), (black))
		Test 1 $b.LineCount()
		Test "abc" $b.GetLine(0).Text
		
		$b.AddLine("def", (white), (black))
		Test 2 $b.LineCount()
		Test "abc" $b.GetLine(0).Text
		Test "def" $b.GetLine(1).Text
		
		$b.AddLine("ghi", (white), (black))
		Test 3 $b.LineCount() 3
		Test "abc" $b.GetLine(0).Text
		Test "def" $b.GetLine(1).Text
		Test "ghi" $b.GetLine(2).Text
	}

	[TestMethod()]
	[void] RemoveLine(){
		$b = [TextBuffer]::new((white), (black))
		
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))
		Test 3 $b.LineCount()

		$b.RemoveLine(0)
		Test 2 $b.LineCount()
		Test "def" $b.GetLine(0).Text
		Test "ghi" $b.GetLine(1).Text
		
		$b.RemoveLine(1)
		Test 1 $b.LineCount()
		Test "def" $b.GetLine(0).Text

		$b.RemoveLine(0)
		Test 0 $b.LineCount()
	}

	[TestMethod()]
	[void] ColumnCount(){
		$b = [TextBuffer]::new((white), (black))
		Test 0 $b.ColumnCount()
		
		$b.AddLine("", (white), (black))
		Test 0 $b.ColumnCount()

		$b.AddLine("a", (white), (black))
		Test 1 $b.ColumnCount()

		$b.AddLine("bbb", (white), (black))
		Test 3 $b.ColumnCount()

		$b.RemoveLine(2)
		Test 1 $b.ColumnCount()

		$b.RemoveLine(1)
		Test 0 $b.ColumnCount()
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords -1 -1))

		Test 3 $stripes.Count

		Test (coords 12 34) $stripes[0].Coordinates
		Test (bca "   " (white) (black)) $stripes[0].BufferCells

		Test (coords 12 35) $stripes[1].Coordinates
		Test (bca " ab" (white) (black)) $stripes[1].BufferCells

		Test (coords 12 36) $stripes[2].Coordinates
		Test (bca " de" (white) (black)) $stripes[2].BufferCells
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords -1 0))

		Test 3 $stripes.Count

		Test (coords 12 34) $stripes[0].Coordinates
		Test (bca " ab" (white) (black)) $stripes[0].BufferCells

		Test (coords 12 35) $stripes[1].Coordinates
		Test (bca " de" (white) (black)) $stripes[1].BufferCells

		Test (coords 12 36) $stripes[2].Coordinates
		Test (bca " gh" (white) (black)) $stripes[2].BufferCells
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords -1 1))

		Test 3 $stripes.Count

		Test (coords 0 0) $stripes[0].Coordinates
		Test (bca " de" (white) (black)) $stripes[0].BufferCells

		Test (coords 0 1) $stripes[1].Coordinates
		Test (bca " gh" (white) (black)) $stripes[1].BufferCells

		Test (coords 0 2) $stripes[2].Coordinates
		Test (bca "   " (white) (black)) $stripes[2].BufferCells
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_0_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 0 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "def" (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_0_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 0 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "def" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "ghi" (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_0_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 0 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "def" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "ghi" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "   " (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_p1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 1 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "bc " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "ef " (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_p1_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 1 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "bc " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "ef " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "hi " (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_p1_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords 1 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestObject $stripes[0].BufferCells (bca "ef " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestObject $stripes[1].BufferCells (bca "hi " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestObject $stripes[2].BufferCells (bca "   " (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_m1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords -1 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca " ef" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_m1_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords -1 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca " ef" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca " ij" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_m1_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords -1 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca " ef" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca " ij" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca " mn" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_0_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 0 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "efg" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_0_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 0 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "efg" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "ijk" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_0_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 0 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "efg" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "ijk" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "mno" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_p1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 1 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "bcd" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "fgh" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_p1_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 1 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "bcd" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "fgh" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "jkl" (white) (black))
	}

	[TestMethod()]
	[void] TextLargerThanTarget_Source_p1_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abcd", (white), (black))
		$b.AddLine("efgh", (white), (black))
		$b.AddLine("ijkl", (white), (black))
		$b.AddLine("mnop", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords 1 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestObject $stripes[0].BufferCells (bca "fgh" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestObject $stripes[1].BufferCells (bca "jkl" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestObject $stripes[2].BufferCells (bca "nop" (white) (black))
	}

	[TestMethod()]
	[void] TextSmallerThanTarget_Source_0_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 10 20 15 25), (coords 0 0))

		TestAreEqual $stripes.Count 6

		TestAreEqual $stripes[0].Coordinates (coords 10 20)
		TestObject $stripes[0].BufferCells (bca "abc   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestObject $stripes[1].BufferCells (bca "def   " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestObject $stripes[2].BufferCells (bca "ghi   " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestObject $stripes[3].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestObject $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestObject $stripes[5].BufferCells (bca "      " (white) (black))
	}

	[TestMethod()]
	[void] TextSmallerThanTarget_Source_m1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 10 20 15 25), (coords -1 -1))

		TestAreEqual $stripes.Count 6

		TestAreEqual $stripes[0].Coordinates (coords 10 20)
		TestObject $stripes[0].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestObject $stripes[1].BufferCells (bca " abc  " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestObject $stripes[2].BufferCells (bca " def  " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestObject $stripes[3].BufferCells (bca " ghi  " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestObject $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestObject $stripes[5].BufferCells (bca "      " (white) (black))
	}

	[TestMethod()]
	[void] TextSmallerThanTarget_Source_m5_m5(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 10 20 15 25), (coords -5 -5))

		TestAreEqual $stripes.Count 6

		TestAreEqual $stripes[0].Coordinates (coords 10 20)
		TestObject $stripes[0].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestObject $stripes[1].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestObject $stripes[2].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestObject $stripes[3].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestObject $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestObject $stripes[5].BufferCells (bca "     a" (white) (black))
	}

	[TestMethod()]
	[void] TextOfOneLineTooShort(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("de", (white), (black)) # this line is too short for the target area
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 10 20 13 23), (coords 2 0))

		TestAreEqual $stripes.Count 4

		TestAreEqual $stripes[0].Coordinates (coords 10 20)
		TestObject $stripes[0].BufferCells (bca "c   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestObject $stripes[1].BufferCells (bca "    " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestObject $stripes[2].BufferCells (bca "i   " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestObject $stripes[3].BufferCells (bca "    " (white) (black))
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([TextBufferTests])
