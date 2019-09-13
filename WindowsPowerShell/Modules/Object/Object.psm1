function Dispose($Object) {
	if ($Object -ne $null -and $Object -is [System.IDisposable]) {
		$Object.Dispose()
	}
}

function DeepCopy($Original) {
	if ($Original -is [array]) {
		$copy = [Collections.ArrayList]::new()
		foreach ($element in $Original) {
			$copy.Add((DeepCopy $element)) | Out-Null
		}
		return $copy.ToArray()
	} elseif ($Original -is [hashtable]) {
		$copy = @{}
		foreach ($key in $Original.Keys) {
			$copy[$key] = DeepCopy $Original[$key]
		}
		return $copy
	} else {
		return $Original
	}
}

<#
.SYNOPSIS
Merges two objects.

.PARAMETER Target
The first of the two objects to merge. Becomes the result of the merge.

.PARAMETER Source
The second of the two objects to merge.

.DESCRIPTION
In the context of the this function, "merging" is a process that applies to arrays and hash tables.
Merging two arrays results in an array that contains the elements from both input arrays, e.g.

	$a = 1, 3, 5
	MergeObjects ([ref] $a) (2, 4, 6)

results in $a being (1, 2, 3, 4, 5, 6). Merging two hash tables results in a hash table that
contains the keys from both input hash tables, e.g.

	$a = @{ Name = "Anton" }
	MergeObjects ([ref] $a) @{ Age = 27 }

results in $a being @{ Name = "Anton"; Age = 27 }. This function merges arrays and hash tables
recursively, e.g.

	$a = @{ Name = "Seattle"; ZipCodes = 98101, 98103 }
	MergeObject ([ref] $a) @{ Population = 608660; ZipCodes = 98102, 98104 }

results in $a being @{ Name = "Seattle"; Population = 608660; ZipCodes = 98101, 98102, 98103, 98104 }.
Refer to the unit tests for more examples of this process.

The merge alters the Target object and, by incorporating object references from the Source object
into the Target object, enables potentially unexpected changes to the Source object through the
resulting Target object. To prevent either, make a deep copy of the argument you wish to preserve.

Currently, a key in a source hash table overwrites the same key in a target hash table. Target array
elements at a given index precede source array elements at a given index. In the future, additional
parameters to this function could govern different behaviors (e.g. a 'CollisionHandling' parameter
with values 'TargetOverSource', 'SourceOverTarget' and 'ThrowOnCollision'; and an 'ArrayComposition'
parameter with values 'TargetThenSource', 'SourceThenTarget', 'InterleaveTargetFirst',
'InterleaveSourceFirst' ...).
#>
function MergeObjects([ref] $Target, $Source) {

	function Mergeable($a, $b) { return ($a.GetType() -eq $b.GetType()) -and ($a -is [array] -or $a -is [hashtable]) }

	if (Mergeable $Target.value $Source) {
		if ($Target.value -is [array]) {
			$temp = [Collections.ArrayList]::new()
			
			$i = 0
			for(; ($i -lt $Target.value.Count) -and ($i -lt $Source.Count); ++$i) {

				if (Mergeable $Target.value[$i] $Source[$i]) {
					$refable = $Target.value[$i]
					MergeObjects ([ref]$refable) $Source[$i]
					$temp.Add($refable) | Out-Null
				} else {
					$temp.Add($Target.value[$i]) | Out-Null
					$temp.Add($Source[$i]) | Out-Null
				}
			}

			# in case the target array is longer than the source array
			for (; $i -lt $Target.value.Count; ++$i) {
				$temp.Add($Target.value[$i]) | Out-Null
			}

			# in case the source array is longer than the target array
			for (; $i -lt $Source.Count; ++$i) {
				$temp.Add($Source[$i]) | Out-Null
			}

			$Target.value = $temp.ToArray()

		} elseif ($Target.value -is [hashtable]) {
			foreach ($key in $Source.Keys) {
				if (!$Target.value.ContainsKey($key)) {
					$Target.value[$key] = $Source[$key]
				} else {
					$refable = $Target.value[$key]
					MergeObjects ([ref]$refable) $Source[$key]
					$Target.value[$key] = $refable
				}
			}
		}
	}
	else {
		$Target.value = $Source
	}
}
