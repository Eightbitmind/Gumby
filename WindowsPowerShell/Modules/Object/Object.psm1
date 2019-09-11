function Dispose($Object) {
	if ($Object -ne $null -and $Object -is [System.IDisposable]) {
		$Object.Dispose()
	}
}

function DeepCopy($Original) {
	if ($Original -is [array]) {
		$copy = [Collections.ArrayList]::new() # @()
		foreach ($element in $Original) {
			$copy.Add((DeepCopy $element)) # $copy += (DeepCopy $element)
		}
		return $copy.ToArray() # $copy
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

function MergeObjects([ref] $target, $source) {

	function Mergeable($a, $b) { return ($a.GetType() -eq $b.GetType()) -and ($a -is [array] -or $a -is [hashtable]) }

	if (Mergeable $target.value $source) {
		if ($target.value -is [array]) {
			$temp = [Collections.ArrayList]::new()
			
			$i = 0
			for(; ($i -lt $target.value.Count) -and ($i -lt $source.Count); ++$i) {

				if (Mergeable $target.value[$i] $source[$i]) {
					$refable = $target.value[$i]
					MergeObjects ([ref]$refable) $source[$i]
					$temp.Add($refable)
				} else {
					$temp.Add($target.value[$i])
					$temp.Add($source[$i])
				}
			}

			# in case the target array is longer than the source array
			for (; $i -lt $target.value.Count; ++$i) {
				$temp.Add($target.value[$i])
			}

			# in case the source array is longer than the target array
			for (; $i -lt $source.Count; ++$i) {
				$temp.Add($source[$i])
			}

			$target.value = $temp.ToArray()

		} elseif ($target.value -is [hashtable]) {
			foreach ($key in $source.Keys) {
				if (!$target.value.ContainsKey($key)) {
					$target.value[$key] = $source[$key]
				} else {
					$refable = $target.value[$key]
					MergeObjects ([ref]$refable) $source[$key]
					$target.value[$key] = $refable
				}
			}
		}
	}
	else {
		$target.value = $source
	}
}