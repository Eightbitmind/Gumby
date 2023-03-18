using module Gumby.Path

<#
.SYNOPSIS
	Displays occurrences of a text pattern in text files.

.PARAMETER Pattern
	Regular expression pattern to search for.

.PARAMETER FilePath
	Directory to start search in.

.PARAMETER FileNamePattern
	Name patterns of files to search.

.PARAMETER OutputFormat
	Format string for each search hit. The following macroes get replaced with the respective value from the seach hit:
	$FileFullPath ... Full path of file in which the pattern was found.
	$LineNumber ..... Line number in file where the pattern was found.
	$MatchLine ...... Text of the line containing the match.
#>
function FindStringInFiles(
  [string] $Pattern,
  [string] $FilePath = ".",
  $FileNamePattern = "*",
  [string] $OutputFormat = '$FileFullPath($LineNumber): $MatchLine') {
	Get-ChildItem -File -Include $FileNamePattern -Recurse $FilePath | ForEach-Object { $patternMatches = Select-String -Path $_ $Pattern; foreach ($match in $patternMatches) {
		$FileFullPath = $_.FullName
		$LineNumber = $match.LineNumber
		$MatchLine = $match.Line

		Write-Output (Invoke-Expression ('"' + $OutputFormat + '"'))
	}}
}

<#
.SYNOPSIS
	Displays occurrences of a text pattern in source code files.

.PARAMETER Pattern
	Regular expression pattern to search for.

.PARAMETER FilePath
	Directory to start search in.

.PARAMETER Language
	Programming language of source files to search.
	Supported values are
	cpp ... Search C++ sources files  (.h, .cpp ...)
	js .... Search Javascript files (.js, .ts ...)
#>
function FindStringInSourceFiles(
	[string] $Pattern,
	[string] $FilePath = ".",
	[ValidateSet("cpp", "js")][string] $Language = "cpp"
	) {
	$filenamePattern =
		switch ($Language) {
			"cpp" { '*.h', '*.hpp', '*.c', '*.cpp' }
			"js" { '*.js', '*.ts', '*.tsx' }
			default { '*' }
		}
	FindStringInFiles $Pattern $FilePath $filenamePattern
}

<#
.SYNOPSIS
	Displays occurrences of a text pattern in C++ source files.

.PARAMETER Pattern
	Regular expression pattern to search for.

.PARAMETER FilePath
	Directory to start search in.
#>
function FindStringInCppSourceFiles([string] $Pattern, [string] $FilePath = ".") {
	# FindStringInFiles -FilePath $FilePath -FileNamePattern *.h, *.hpp, *.c, *.cpp -Pattern $Pattern
	FindStringInSourceFiles $Pattern $FilePath -Language 'cpp'
}

<#
.SYNOPSIS
	Displays occurrences of a text pattern in Javascript source files.

.PARAMETER Pattern
	Regular expression pattern to search for.

.PARAMETER FilePath
	Directory to start search in.
#>
function FindStringInJSSourceFiles([string] $Pattern, [string] $FilePath = ".") {
	# FindStringInFiles -FilePath $FilePath -FileNamePattern *.h, *.hpp, *.c, *.cpp -Pattern $Pattern
	FindStringInSourceFiles $Pattern $FilePath -Language 'js'
}

<#
.SYNOPSIS
	Looks for an executable in the directories listed in the PATH environment variable.

.PARAMETER ExecutableName
	Name of the executable to look for. If the name does not contain an extension, common executable
	extensions (.exe, .bat ...) are being tried.

.OUTPUTS
	Path names of existing executables.
#>
function FindExecutableInPath([string] $ExecutableName) {
	$extensions = $null

	if (![IO.Path]::HasExtension($ExecutableName)) {
		$extensions = '.exe', '.bat', '.cmd', '.ps1'
	}

	foreach ($dir in ($env:Path).Split(';')) {
		if ([string]::IsNullOrEmpty($dir)) { continue }

		if ($null -ne $extensions) {
			foreach ($extension in $extensions) {
				$tentative = PathJoin -Directories $dir -BaseName $ExecutableName -Extension $extension
				if (Test-Path $tentative) { Write-Output "$tentative" }
			}
		} else {
			$tentative = PathJoin -Directories $dir -BaseName $ExecutableName
			if (Test-Path $tentative) { Write-Output "$tentative" }
		}
	}
}
