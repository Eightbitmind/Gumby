using module TestUtils

[TestClass()]
class DeepCopyTests {
	[TestMethod()]
	[void] DeepCopy_Bool() {
		$original = $true
		$copy = DeepCopy $original

		TestIsType $copy ([bool])
		TestIsTrue $copy
	}

	[TestMethod()]
	[void] DeepCopy_Int() {
		$original = 1
		$copy = DeepCopy $original

		TestIsType $copy ([int])
		TestAreEqual $copy 1
	}

	[TestMethod()]
	[void] DeepCopy_String() {
		$original = "abc"
		$copy = DeepCopy $original

		TestIsType $copy ([string])
		TestAreEqual $copy "abc"
	}

	[TestMethod()]
	[void] DeepCopy_Scriptblock() {
		$original = {param($n) $n + 1}
		$copy = DeepCopy $original

		TestIsType $copy ([scriptblock])
		TestAreEqual $copy.Invoke(1) 2
	}

	[TestMethod()]
	[void] DeepCopy_Array() {
		$original = (1, 2, 3)
		$copy = DeepCopy $original

		# modify original
		++$original[0]
		TestAreEqual $original[0] 2

		# modification of original should have no effect on copy
		TestIsType $copy ([array])
		TestTuplesAreEqual $copy (1, 2, 3)
	}

	[TestMethod()]
	[void] DeepCopy_Object() {
		$original = @{Name = "Anton"; Age = 27}
		$copy = DeepCopy $original

		# modify original
		++$original.Age
		TestAreEqual $original.Age 28

		# modification of original should have no effect on copy
		TestAreEqual $copy.Keys.Count 2
		TestAreEqual $copy.Name "Anton"
		TestAreEqual $copy.Age 27
	}

	[TestMethod()]
	[void] DeepCopy_ArrayOfArrays() {
		$original = @( @(1,2,3), @(10,20,30), @(100, 200, 300) )
		$copy = DeepCopy $original

		# modify original
		++$original[1][0]
		TestAreEqual $original[1][0] 11

		# modification of original should have no effect on copy

		TestIsType $copy ([array])
		TestAreEqual $copy.Count 3
		TestTuplesAreEqual $copy[0] (1, 2, 3)
		TestTuplesAreEqual $copy[1] (10, 20, 30)
		TestTuplesAreEqual $copy[2] (100, 200, 300)
	}

	[TestMethod()]
	[void] DeepCopy_ObjectOfObjects() {
		$original = @{
			Portland = @{ Population = 583776; Area = 145; Demonym = { return "Portlander" } }
			SanFrancisco = @{ Population = 883305; Area = 232; Demonym = { return "San Franciscan" } }
			Seattle = @{ Population = 608660; Area = 142; Demonym = { return "Seattleite" } }
		}
		$copy = DeepCopy $original

		# modify original
		++$original.Portland.Population
		TestAreEqual $original.Portland.Population 583777

		# modification of original should have no effect on copy

		TestAreEqual $copy.Keys.Count 3

		TestAreEqual $copy.Portland.Keys.Count 3
		TestAreEqual $copy.Portland.Population 583776
		TestAreEqual $copy.Portland.Area 145
		TestAreEqual $copy.Portland.Demonym.Invoke() "Portlander"

		TestAreEqual $copy.SanFrancisco.Keys.Count 3
		TestAreEqual $copy.SanFrancisco.Population 883305
		TestAreEqual $copy.SanFrancisco.Area 232
		TestAreEqual $copy.SanFrancisco.Demonym.Invoke() "San Franciscan"
		
		TestAreEqual $copy.Seattle.Keys.Count 3
		TestAreEqual $copy.Seattle.Population 608660
		TestAreEqual $copy.Seattle.Area 142
		TestAreEqual $copy.Seattle.Demonym.Invoke() "Seattleite"
	}

	[TestMethod()]
	[void] DeepCopy_ArrayOfObjects() {
		$original = 
			@{ Name = "Anton"; Age = 27; },
			@{ Name = "Jimi"; Age = 27; },
			@{ Name = "Kurt"; Age = 27; }

		$copy = DeepCopy $original

		# modify original
		++$original[0].Age
		TestAreEqual $original[0].Age 28

		# modification of original should have no effect on copy

		TestIsType $copy ([array])
		TestAreEqual $copy.Count 3
		TestAreEqual $copy[0].Name "Anton"
		TestAreEqual $copy[0].Age 27
		TestAreEqual $copy[1].Name "Jimi"
		TestAreEqual $copy[1].Age 27
		TestAreEqual $copy[2].Name "Kurt"
		TestAreEqual $copy[2].Age 27
	}
}

[TestClass()]
class MergeObjectsTests {
	[TestMethod()]
	[void] MergeObjects_ArraysOfSameLength() {
		$a = 1, 3, 5
		$b = 2, 4, 6

		$m = MergeObjects $a $b

		TestTuplesAreEqual $m (1, 2, 3, 4, 5, 6)
	}

	[TestMethod()]
	[void] MergeObjects_ShortArrayIntoLongArray() {
		$a = 1, 3, 5, 7, 8
		$b = 2, 4, 6

		$m = MergeObjects $a $b

		TestTuplesAreEqual $m (1, 2, 3, 4, 5, 6, 7, 8)
	}

	[TestMethod()]
	[void] MergeObjects_LongArrayIntoShortArray() {
		$a = 1, 3, 5
		$b = 2, 4, 6, 7, 8

		$m = MergeObjects $a $b

		TestTuplesAreEqual $m (1, 2, 3, 4, 5, 6, 7, 8)
	}

	[TestMethod()]
	[void] MergeObjects_Objects() {
		$a = @{ Name = "Anton" }
		$b = @{ Age = 27 }

		$m = MergeObjects $a $b

		TestAreEqual $m.Keys.Count 2
		TestAreEqual $m.Name "Anton"
		TestAreEqual $m.Age 27
	}


	[TestMethod()]
	[void] MergeObjects_ObjectsWithSharedProperties() {
		$a = @{ Name = "Anton"; Age = 27 }
		$b = @{ Name = "Kurt" }

		$m = MergeObjects $a $b

		TestAreEqual $m.Keys.Count 2
		TestAreEqual $m.Name "Kurt"
		TestAreEqual $m.Age 27
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithObjects() {
		$a = @{ Name = "Washington"; Seattle = @{ Area = 142 } }
		$b = @{ Seattle = @{ Population = 608660 } }

		$m = MergeObjects $a $b

		TestAreEqual $m.Keys.Count 2
		TestAreEqual $m.Name "Washington"

		TestAreEqual $m.Seattle.Keys.Count 2
		TestAreEqual $m.Seattle.Area 142
		TestAreEqual $m.Seattle.Population 608660
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithArrays() {
		$a = @{ Name = "Seattle";       ZipCodes = @(98101, 98103) }
		$b = @{ Demonym = "Seattleite"; ZipCodes = @(98102, 98104, 98105) }

		$m = MergeObjects $a $b

		TestAreEqual $m.Keys.Count 3
		TestAreEqual $m.Name "Seattle"
		TestAreEqual $m.Demonym "Seattleite"
		TestTuplesAreEqual $m.ZipCodes (98101, 98102, 98103, 98104, 98105)
	}

	[TestMethod()]
	[void] MergeObjects_ArraysOfObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) },      @{ Name = "Seattle";       ZipCodes = (98101, 98103) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) },             @{ Demonym = "Seattleite"; ZipCodes = (98102, 98104, 98105) }

		$m = MergeObjects $a $b

		TestAreEqual $m.Count 2

		TestAreEqual $m[0].Keys.Count 3
		TestAreEqual $m[0].Name "Portland"
		TestAreEqual $m[0].Demonym "Portlander"
		TestTuplesAreEqual $m[0].ZipCodes (97086, 97087, 97088, 97089, 97090)
		
		TestAreEqual $m[1].Keys.Count 3
		TestAreEqual $m[1].Name "Seattle"
		TestAreEqual $m[1].Demonym "Seattleite"
		TestTuplesAreEqual $m[1].ZipCodes (98101, 98102, 98103, 98104, 98105)
	}

	[TestMethod()]
	[void] MergeObjects_ThreeObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) }
		$c = @{ State = "Oregon" }

		$m = MergeObjects $a $b $c

		TestAreEqual $m.Keys.Count 4
		TestAreEqual $m.Name "Portland"
		TestAreEqual $m.Demonym "Portlander"
		TestAreEqual $m.State "Oregon"
		TestTuplesAreEqual $m.ZipCodes (97086, 97087, 97088, 97089, 97090)
	}
}

[TestClass()]
class ZipTests {
	[TestMethod()]
	[void] ThreeItems() {
		$r = Zip ("a", "b", "c") (1, 2, 3)
		TestAreEqual $r.Count 3
		TestAreEqual $r.a 1
		TestAreEqual $r.b 2
		TestAreEqual $r.c 3
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([DeepCopyTests]) ([MergeObjectsTests]) ([ZipTests])
