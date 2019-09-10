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
		$original = 1, 2, 3
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
		TestTuplesAreEqual $copy.Name "Anton"
		TestTuplesAreEqual $copy.Age 27
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
		TestTuplesAreEqual $copy[0] (7, 2, 3)
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
	[void] MergeObjects_Array() {
		$a = 1, 2, 3
		$b = 4, 5, 6

		$r = MergeObjects $a $b

		TestAreEqual $r.Count 6
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([DeepCopyTests]) ([MergeObjectsTests])
