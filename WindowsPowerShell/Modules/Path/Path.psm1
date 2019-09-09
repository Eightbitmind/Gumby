using module Assert

function PathNormalize([string] $Path) {
	$path.Replace('/', '\')
}

function PathSeparator() { return '\' }

function PathFileBaseName([string] $Path) {
	[int] $a = $Path.LastIndexOf((PathSeparator))

	if ($a -lt 0) { $a = 0 } else { ++$a }

	if ($a -ge $Path.Length) { return "" }

	[int] $b = $Path.IndexOf('.', $a)

	if ($b -lt 0) {
		# "a\b" -> "b"
		return $Path.Substring($a)
	} else {
		# "a\b.c" -> "b"
		return $Path.Substring($a, $b - $a)
	}
}
