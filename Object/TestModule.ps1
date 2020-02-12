using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Object.psm1"

[TestClass()]
class DeepCopyTests {
	[TestMethod()]
	[void] DeepCopy_Bool() {
		$original = $true
		$copy = DeepCopy $original

		Test (ExpectType ([bool])) $copy
		Test $true $copy
	}

	[TestMethod()]
	[void] DeepCopy_Int() {
		$original = 1
		$copy = DeepCopy $original

		Test (ExpectType ([int])) $copy
		Test 1 $copy
	}

	[TestMethod()]
	[void] DeepCopy_String() {
		$original = "abc"
		$copy = DeepCopy $original

		Test (ExpectType ([string])) $copy
		Test "abc" $copy
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
		Test (ExpectType ([array])) $copy
		Test (1, 2, 3) $copy
	}

	[TestMethod()]
	[void] DeepCopy_Object() {
		$original = @{Name = "Anton"; Age = 27}
		$copy = DeepCopy $original

		# modify original
		++$original.Age
		Test 28 $original.Age

		# modification of original should have no effect on copy
		Test `
			(ExpectAnd `
				(ExpectKeyCountEqual 2) `
				@{Name = 'Anton'; Age = 27}) `
			$copy
	}

	[TestMethod()]
	[void] DeepCopy_ArrayOfArrays() {
		$original = @( @(1, 2, 3), @(10, 20, 30), @(100, 200, 300) )
		$copy = DeepCopy $original

		# modify original
		++$original[1][0]
		Test 11 $original[1][0] 11

		# modification of original should have no effect on copy

		Test `
			(ExpectAnd `
				(ExpectType ([array])) `
				@(@(1,2,3), @(10,20,30), @(100, 200, 300))) `
			$copy
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

		Test `
			(ExpectAnd `
				(ExpectKeyCountEqual 3) `
				@{ `
					Portland = `
						(ExpectAnd `
							(ExpectKeyCountEqual 3) `
							@{ `
								Population = 583776; `
								Area = 145; `
								Demonym = (Expect "Demonym" { param($sb) $sb.Invoke() -eq "Portlander" }) `
							} `
						); `
					SanFrancisco = `
						(ExpectAnd `
							(ExpectKeyCountEqual 3) `
							@{ `
								Population = 883305; `
								Area = 232; `
								Demonym = (Expect "Demonym" { param($sb) $sb.Invoke() -eq "San Franciscan" }) `
							} `
						); `
					Seattle = `
						(ExpectAnd `
							(ExpectKeyCountEqual 3) `
							@{ `
								Population = 608660; `
								Area = 142; `
								Demonym = (Expect "Demonym" { param($sb) $sb.Invoke() -eq "Seattleite" }) `
							} `
						)
				} `
			) `
			$copy
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
		Test 28 $original[0].Age

		# modification of original should have no effect on copy

		Test `
			@( `
				(ExpectAnd (ExpectKeyCountEqual 2) @{Name = "Anton"; Age = 27}), `
				(ExpectAnd (ExpectKeyCountEqual 2) @{Name = "Jimi"; Age = 27}), `
				(ExpectAnd (ExpectKeyCountEqual 2) @{Name = "Kurt"; Age = 27}) `
			) `
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

		Test (ExpectAnd (ExpectKeyCountEqual 2) @{Name = 'Anton'; Age = 27}) $m
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithSharedProperties() {
		$a = @{ Name = "Anton"; Age = 27 }
		$b = @{ Name = "Kurt" }

		$m = MergeObjects $a $b

		Test (ExpectAnd (ExpectKeyCountEqual 2) @{Name = <# last one wins #> "Kurt"; Age = 27}) $m
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithObjects() {
		$a = @{ Name = "Washington"; Seattle = @{ Area = 142 } }
		$b = @{ Seattle = @{ Population = 608660 } }

		$m = MergeObjects $a $b

		Test `
			(ExpectAnd `
				(ExpectKeyCountEqual 2) `
				@{ `
					Name = "Washington"; `
					Seattle = `
						(ExpectAnd `
							(ExpectKeyCountEqual 2) `
							@{Area = 142; Population = 608660} `
						) `
				} `
			) `
			$m
	}

	[TestMethod()]
	[void] MergeObjects_ObjectsWithArrays() {
		$a = @{ Name = "Seattle";       ZipCodes = @(98101, 98103) }
		$b = @{ Demonym = "Seattleite"; ZipCodes = @(98102, 98104, 98105) }

		$m = MergeObjects $a $b

		Test `
			(ExpectAnd `
				(ExpectKeyCountEqual 3) `
				@{ `
					Name = "Seattle"; `
					Demonym = "Seattleite"; `
					ZipCodes = (98101, 98102, 98103, 98104, 98105) `
				} `
			) `
			$m
	}

	[TestMethod()]
	[void] MergeObjects_ArraysOfObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) },      @{ Name = "Seattle";       ZipCodes = (98101, 98103) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) },             @{ Demonym = "Seattleite"; ZipCodes = (98102, 98104, 98105) }

		$m = MergeObjects $a $b

		Test `
			@( `
				(ExpectAnd `
					(ExpectKeyCountEqual 3) `
					@{Name = "Portland"; Demonym = "Portlander"; ZipCodes = (97086, 97087, 97088, 97089, 97090)}), `
				(ExpectAnd `
					(ExpectKeyCountEqual 3) `
					@{Name = "Seattle"; Demonym = "Seattleite"; ZipCodes = (98101, 98102, 98103, 98104, 98105)}) `
			) `
			$m
	}

	[TestMethod()]
	[void] MergeObjects_ThreeObjects() {
		$a = @{ Name = "Portland";      ZipCodes = (97086, 97088, 97090) }
		$b = @{ Demonym = "Portlander"; ZipCodes = (97087, 97089) }
		$c = @{ State = "Oregon" }

		$m = MergeObjects $a $b $c

		Test `
			(ExpectAnd `
				(ExpectKeyCountEqual 4) `
				@{ `
					Name = "Portland"; `
					Demonym = "Portlander"; `
					State = "Oregon"; `
					ZipCodes=(97086, 97087, 97088, 97089, 97090) `
				} `
			) `
			$m
	}
}

$tests = ([DeepCopyTests]), ([MergeObjectsTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\ObjectTests.log" @tests }
}
