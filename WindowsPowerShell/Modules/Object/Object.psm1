function Dispose($Object) {
	if ($Object -ne $null -and $Object -is [System.IDisposable]) {
		$Object.Dispose()
	}
}

function DeepCopy($Original) {
	# As everything is an object, these tests need to precede the '-is [object]' test
	if (
		$Original -is [bool] -or
		$Original -is [int16] -or
		$Original -is [int] -or
		$Original -is [uint16] -or
		$Original -is [uint32] -or
		$Original -is [uint64] -or
		$Original -is [string] -or
		$Original -is [scriptblock]
	) {
		return $Original
	} elseif ($Original -is [array]) {
		$copy = @()
		foreach ($element in $Original) {
			$copy += (DeepCopy $element) 
		}
		return $copy
	} elseif ($Original -is [object]) {
		$copy = @{}
		foreach ($key in $Original.Keys) {
			$copy[$key] = DeepCopy $Original[$key]
		}
		return $copy
	} else {
		throw "unexpected type"
	}
}

function MergeObjects($a, $b) {
	function MergeInto($target, $source) {
		foreach ($k in $source.Keys) {
			if (!$target.ContainsKey($k)) {
				$target[$k] = $source[$k]
			} else {
				if (($target[$k] -is [array]) -and ($source[$k] -is [array])) {
					foreach ($e in $source[$k]) { $target[$k] += $e }
				} elseif (($target[$k] -is [object]) -and ($source[$k] -is [object])) {
					MergeInto $target[$k] $source[$k]
				}
			}
		}
	}

	$p = DeepCopy $a;
	$q = DeepCopy $b;
	MergeInto $p $q
	return $p
}


# function deepCopy(obj) {
#     if (Array.isArray(obj)) {
#       const result = [];
#       for (const element of obj) result.push(deepCopy(element));
#       return result;
#     } else if (typeof obj === 'object') {
#       const result = {};
#       for (const key in obj) result[key] = deepCopy(obj[key]);
#       return result;
#     } else if (typeof obj === 'boolean' || typeof obj === 'number' || typeof obj === 'string') {
#       return obj;
#     } else {
#       throw new Error('unexpected object type');
#     }
#   }

#   function merge(a, b) {
#     function mergeInto(target, source) {
#       for (const k in source) {
#         if (!target.hasOwnProperty(k)) {
#           target[k] = source[k];
#         } else {
#           if (Array.isArray(target[k]) && Array.isArray(source[k])) {
#             for (const i of source[k]) target[k].push(i);
#           } else if (typeof target[k] === 'object' && typeof source[k] === 'object') {
#             mergeInto(target[k], source[k]);
#           }
#         }
#       }
#     }

#     const p = deepCopy(a);
#     const q = deepCopy(b);
#     mergeInto(p, q);
#     return p;
#   }