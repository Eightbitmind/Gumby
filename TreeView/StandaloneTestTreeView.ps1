using module TestUtils
using module TreeView

# The file is named to *not* match the pattern used in RunAllTests.ps1.

#		0	1	2	3
#	0	A
#	1		C
#	2	B
#	3		D
#	4			F
#	5				I
#	6			G
#	7			H
#	8		E

$tc = [FileTreeView]::TestOnly_Make($host)
$tc.Items.Add(@{Name = 'A'; Level = 0}) | Out-Null
$tc.Items.Add(	@{Name = 'C'; Level = 1}) | Out-Null
$tc.Items.Add(@{Name = 'B'; Level = 0}) | Out-Null
$tc.Items.Add(	@{Name = 'D'; Level = 1}) | Out-Null
$tc.Items.Add(		@{Name = 'F'; Level = 2}) | Out-Null
$tc.Items.Add(			@{Name = 'I'; Level = 3}) | Out-Null
$tc.Items.Add(		@{Name = 'G'; Level = 2}) | Out-Null
$tc.Items.Add(		@{Name = 'H'; Level = 2}) | Out-Null
$tc.Items.Add(	@{Name = 'E'; Level = 1}) | Out-Null

TestTuplesAreEqual $tc.GetAncestralSiblingRange(0, 0) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(0, 1) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(1, 0) (1, 1)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(1, 1) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(2, 0) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(2, 1) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(3, 0) (3, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(3, 1) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(3, 2) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(4, 0) (4, 7)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(4, 1) (3, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(4, 2) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(4, 3) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(5, 0) (5, 5)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(5, 1) (4, 7)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(5, 2) (3, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(5, 3) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(5, 4) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(6, 0) (4, 7)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(6, 1) (3, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(6, 2) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(6, 3) (0, 8)

TestTuplesAreEqual $tc.GetAncestralSiblingRange(7, 0) (4, 7)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(7, 1) (3, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(7, 2) (0, 8)
TestTuplesAreEqual $tc.GetAncestralSiblingRange(7, 3) (0, 8)


#		0	1	2	3
#	0	A
#	1		C
#	2			F
#	3				G
#	4	B
#	5		D
#	6		E

$tc1 = [FileTreeView]::TestOnly_Make($host)
$tc1.Items.Add(@{Name = 'A'; Level = 0}) | Out-Null
$tc1.Items.Add(	@{Name = 'C'; Level = 1}) | Out-Null
$tc1.Items.Add(		@{Name = 'F'; Level = 2}) | Out-Null
$tc1.Items.Add(			@{Name = 'G'; Level = 3}) | Out-Null
$tc1.Items.Add(@{Name = 'B'; Level = 0}) | Out-Null
$tc1.Items.Add(	@{Name = 'D'; Level = 1}) | Out-Null
$tc1.Items.Add(	@{Name = 'E'; Level = 1}) | Out-Null

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(0, 0) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(0, 1) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(0, 2) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(1, 0) (1, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(1, 1) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(1, 2) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(2, 0) (2, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(2, 1) (1, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(2, 2) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(2, 3) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(3, 0) (3, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(3, 1) (2, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(3, 2) (1, 3)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(3, 3) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(3, 4) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(4, 0) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(4, 1) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(5, 0) (5, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(5, 1) (0, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(5, 2) (0, 6)

TestTuplesAreEqual $tc1.GetAncestralSiblingRange(6, 0) (5, 6)
TestTuplesAreEqual $tc1.GetAncestralSiblingRange(6, 1) (0, 6)
