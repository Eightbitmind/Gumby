using module TestUtils

[TestClass()]
class DeepCopyTests {
	[TestMethod()]
	[void] DeepCopy_Bool() {
		$original = $true
		$copy = DeepCopy $original
		Test (ExpectAnd $true (ExpectType ([bool]))) $copy
	}

	[TestMethod()]
	[void] DeepCopy_Int() {
		$original = 1
		$copy = DeepCopy $original
		Test (ExpectAnd 1 (ExpectType ([int]))) $copy
	}

	[TestMethod()]
	[void] DeepCopy_String() {
		$original = "abc"
		$copy = DeepCopy $original
		Test (ExpectAnd "abc" (ExpectType ([string]))) $copy
	}

	[TestMethod()]
	[void] DeepCopy_Scriptblock() {
		$original = {param($n) $n + 1}
		$copy = DeepCopy $original

		Test (ExpectType ([scriptblock])) $copy
		Test 2 $copy.Invoke(1)
	}

	[TestMethod()]
	[void] DeepCopy_Array() {
		$original = (1, 2, 3)
		$copy = DeepCopy $original

		# modify original
		++$original[0]
		Test 2 $original[0]

		# modification of original should have no effect on copy
		Test (ExpectAnd (1, 2, 3) (ExpectType ([array]))) $copy
	}

	[TestMethod()]
	[void] DeepCopy_Object() {
		$original = @{Name = "Anton"; Age = 27}
		$copy = DeepCopy $original

		# modify original
		++$original.Age
		Test 28 $original.Age

		# modification of original should have no effect on copy
		Test (ExpectAnd @{Name = "Anton"; Age = 27} (ExpectKeyCountEqual 2)) $copy
	}

	[TestMethod()]
	[void] DeepCopy_ArrayOfArrays() {
		$original = @( @(1,2,3), @(10,20,30), @(100, 200, 300) )
		$copy = DeepCopy $original

		# modify original
		++$original[1][0]
		Test 11 $original[1][0]

		# modification of original should have no effect on copy
		Test @( @(1,2,3), @(10,20,30), @(100, 200, 300) ) $copy
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
		Test 583777 $original.Portland.Population

		# modification of original should have no effect on copy
		Test (ExpectAnd `
			(ExpectKeyCountEqual 3) `
			@{
				Portland =     (ExpectAnd (ExpectKeyCountEqual 3) @{ Population = 583776; Area = 145; Demonym = (Expect "Demonym" { param($actual) $actual.Invoke() -eq "Portlander"})})
				SanFrancisco = (ExpectAnd (ExpectKeyCountEqual 3) @{ Population = 883305; Area = 232; Demonym = (Expect "Demonym" { param($actual) $actual.Invoke() -eq "San Franciscan"})})
				Seattle =      (ExpectAnd (ExpectKeyCountEqual 3) @{ Population = 608660; Area = 142; Demonym = (Expect "Demonym" { param($actual) $actual.Invoke() -eq "Seattleite"})})
			}) `
			$copy
	}

	[TestMethod()]
	[void] DeepCopy_ArrayOfObjects() {
		$original = 
			@{ Name = "Anton"; Age = 27 },
			@{ Name = "Jimi"; Age = 27 },
			@{ Name = "Kurt"; Age = 27 }

		$copy = DeepCopy $original

		# modify original
		++$original[0].Age
		Test 28 $original[0].Age

		# modification of original should have no effect on copy

		Test (ExpectAnd `
			(ExpectType ([array])) `
			@( `
				@{Name = "Anton"; Age = 27}, `
				@{Name = "Jimi"; Age = 27}, `
				@{Name = "Kurt"; Age = 27} `
			)) `
			$copy
	}
}

[TestClass()]
class MergeObjectsTests {
	[TestMethod()]
	[void] MergeObjects_ArraysOfSameLength() {
		$a = 1, 3, 5
		$b = 2, 4, 6

		$m = MergeObjects $a $b

		Test (1, 2, 3, 4, 5, 6) $m
	}

	[TestMethod()]
	[void] MergeObjects_ShortArrayIntoLongArray() {
		$a = 1, 3, 5, 7, 8
		$b = 2, 4, 6

		$m = MergeObjects $a $b

		Test (1, 2, 3, 4, 5, 6, 7, 8) $m
	}

	[TestMethod()]
	[void] MergeObjects_LongArrayIntoShortArray() {
		$a = 1, 3, 5
		$b = 2, 4, 6, 7, 8

		$m = MergeObjects $a $b

		Test (1, 2, 3, 4, 5, 6, 7, 8) $m
	}

	[TestMethod()]
	[void] MergeObjects_Objects() {
		$a = @{ Name = "Anton" }
		$b = @{ Age = 27 }

		$m = MergeObjects $a $b

		Test (ExpectAnd (ExpectKeyCountEqual 2) @{Name = "Anton"; Age = 27}) $m
	}


	[TestMethod()]
	[void] MergeObjects_ObjectsWithSharedProperties() {
		$a = @{ Name = "Anton"; Age = 27 }
		$b = @{ Name = "Kurt" }

		$m = MergeObjects $a $b

		Test (ExpectAnd (ExpectKeyCountEqual 2) @{Name = <# second occurrence wins #> "Kurt"; Age = 27}) $m
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithObjects() {
		$a = @{ Name = "Washington"; Seattle = @{ Area = 142 } }
		$b = @{ Seattle = @{ Population = 608660 } }

		$m = MergeObjects $a $b

		Test (ExpectAnd (ExpectKeyCountEqual 2) @{Name = "Washington"; Seattle = (ExpectAnd (ExpectKeyCountEqual 2) @{Area = 142; Population = 608660})}) $m
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithArrays() {
		$a = @{ Name = "Seattle";       ZipCodes = @(98101, 98103) }
		$b = @{ Demonym = "Seattleite"; ZipCodes = @(98102, 98104, 98105) }

		$m = MergeObjects $a $b

		Test (ExpectAnd (ExpectKeyCountEqual 3) @{Name = "Seattle"; Demonym = "Seattleite"; ZipCodes = @(98101, 98102, 98103, 98104, 98105)}) $m
	}

	[TestMethod()]
	[void] MergeObjects_ArraysOfObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) },      @{ Name = "Seattle";       ZipCodes = (98101, 98103) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) },             @{ Demonym = "Seattleite"; ZipCodes = (98102, 98104, 98105) }

		$m = MergeObjects $a $b

		Test @(
			(ExpectAnd (ExpectKeyCountEqual 3) @{Name = "Portland"; Demonym="Portlander"; ZipCodes = @(97086, 97087, 97088, 97089, 97090)}),
			(ExpectAnd (ExpectKeyCountEqual 3) @{Name = "Seattle";  Demonym="Seattleite"; ZipCodes = @(98101, 98102, 98103, 98104, 98105)})) `
			$m
	}

	[TestMethod()]
	[void] MergeObjects_ThreeObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) }
		$c = @{ State = "Oregon" }

		$m = MergeObjects $a $b $c

		Test (ExpectAnd `
			(ExpectKeyCountEqual 4) `
			@{Name = "Portland"; Demonym = "Portlander"; State = "Oregon"; ZipCodes = @(97086, 97087, 97088, 97089, 97090)}) `
			$m
	}
}

[TestClass()]
class ZipTests {
	[TestMethod()]
	[void] ThreeItems() {
		$r = Zip ("a", "b", "c") (1, 2, 3)

		Test (ExpectAnd (ExpectKeyCountEqual 3) @{a = 1; b = 2; c = 3}) $r
	}
}

$standaloneLogFilePath = "$env:TEMP\$(PathFileBaseName $MyInvocation.MyCommand.Path).log"
RunTests $standaloneLogFilePath ([DeepCopyTests]) ([MergeObjectsTests]) ([ZipTests])
