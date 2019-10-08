using module Path
using module TestUtils
using module Window

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
		TestAreEqual $b.LineCount() 0
		
		$b.AddLine("abc", (white), (black))
		TestAreEqual $b.LineCount() 1
		TestAreEqual $b.GetLine(0).Text "abc"
		
		$b.AddLine("def", (white), (black))
		TestAreEqual $b.LineCount() 2
		TestAreEqual $b.GetLine(0).Text "abc"
		TestAreEqual $b.GetLine(1).Text "def"
		
		$b.AddLine("ghi", (white), (black))
		TestAreEqual $b.LineCount() 3
		TestAreEqual $b.GetLine(0).Text "abc"
		TestAreEqual $b.GetLine(1).Text "def"
		TestAreEqual $b.GetLine(2).Text "ghi"
	}

	[TestMethod()]
	[void] RemoveLine(){
		$b = [TextBuffer]::new((white), (black))
		
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))
		TestAreEqual $b.LineCount() 3

		$b.RemoveLine(0)
		TestAreEqual $b.LineCount() 2
		TestAreEqual $b.GetLine(0).Text "def"
		TestAreEqual $b.GetLine(1).Text "ghi"
		
		$b.RemoveLine(1)
		TestAreEqual $b.LineCount() 1
		TestAreEqual $b.GetLine(0).Text "def"

		$b.RemoveLine(0)
		TestAreEqual $b.LineCount() 0
	}

	[TestMethod()]
	[void] ColumnCount(){
		$b = [TextBuffer]::new((white), (black))
		TestAreEqual $b.ColumnCount() 0
		
		$b.AddLine("", (white), (black))
		TestAreEqual $b.ColumnCount() 0

		$b.AddLine("a", (white), (black))
		TestAreEqual $b.ColumnCount() 1

		$b.AddLine("bbb", (white), (black))
		TestAreEqual $b.ColumnCount() 3

		$b.RemoveLine(2)
		TestAreEqual $b.ColumnCount() 1

		$b.RemoveLine(1)
		TestAreEqual $b.ColumnCount() 0
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_m1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords -1 -1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " de" (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_0(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 12 34 14 36), (coords -1 0))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 12 34)
		TestTuplesAreEqual $stripes[0].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " de" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " gh" (white) (black))
	}

	[TestMethod()]
	[void] CongruentTextAndTarget_Source_m1_p1(){
		$b = [TextBuffer]::new((white), (black))
		$b.AddLine("abc", (white), (black))
		$b.AddLine("def", (white), (black))
		$b.AddLine("ghi", (white), (black))

		$stripes = $b.GetStripes((rect 0 0 2 2), (coords -1 1))

		TestAreEqual $stripes.Count 3

		TestAreEqual $stripes[0].Coordinates (coords 0 0)
		TestTuplesAreEqual $stripes[0].BufferCells (bca " de" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " gh" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "   " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "def" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "def" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "ghi" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "def" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "ghi" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "   " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "bc " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "ef " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "bc " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "ef " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "hi " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "ef " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 12 35)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "hi " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 12 36)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "   " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " ef" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca " ab" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " ef" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " ij" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca " ef" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " ij" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " mn" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "efg" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "abc" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "efg" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "ijk" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "efg" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "ijk" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "mno" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "bcd" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "fgh" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "bcd" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "fgh" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "jkl" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "fgh" (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 0 1)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "jkl" (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 0 2)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "nop" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "abc   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "def   " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "ghi   " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestTuplesAreEqual $stripes[3].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestTuplesAreEqual $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestTuplesAreEqual $stripes[5].BufferCells (bca "      " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestTuplesAreEqual $stripes[1].BufferCells (bca " abc  " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestTuplesAreEqual $stripes[2].BufferCells (bca " def  " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestTuplesAreEqual $stripes[3].BufferCells (bca " ghi  " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestTuplesAreEqual $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestTuplesAreEqual $stripes[5].BufferCells (bca "      " (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestTuplesAreEqual $stripes[3].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[4].Coordinates (coords 10 24)
		TestTuplesAreEqual $stripes[4].BufferCells (bca "      " (white) (black))

		TestAreEqual $stripes[5].Coordinates (coords 10 25)
		TestTuplesAreEqual $stripes[5].BufferCells (bca "     a" (white) (black))
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
		TestTuplesAreEqual $stripes[0].BufferCells (bca "c   " (white) (black))

		TestAreEqual $stripes[1].Coordinates (coords 10 21)
		TestTuplesAreEqual $stripes[1].BufferCells (bca "    " (white) (black))

		TestAreEqual $stripes[2].Coordinates (coords 10 22)
		TestTuplesAreEqual $stripes[2].BufferCells (bca "i   " (white) (black))

		TestAreEqual $stripes[3].Coordinates (coords 10 23)
		TestTuplesAreEqual $stripes[3].BufferCells (bca "    " (white) (black))
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([TextBufferTests])
