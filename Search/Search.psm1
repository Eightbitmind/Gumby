using module Path

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FindStringInFiles(
  [string] $Pattern,
  [string] $FilePath = ".",
  $FileNamePattern = "*",
  [string] $OutputFormat = '$FileFullPath($LineNumber): $MatchLine') {
	ls -File -i $FileNamePattern -r $FilePath | foreach { $matches = select-string -path $_ $Pattern; foreach ($match in $matches) {
		$FileFullPath = $_.FullName
		$LineNumber = $match.LineNumber
		$MatchLine = $match.Line

		echo (Invoke-Expression ('"' + $OutputFormat + '"'))
	}}
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FindStringInSourceFiles([string] $Pattern, [string] $FilePath = ".", [string] $Language = "cpp") {
	$filenamePattern =
		switch ($Language) {
			"cpp" { '*.h', '*.hpp', '*.c', '*.cpp' }
			"js" { '*.js', '*.ts', '*.tsx' }
			default { '*' }
		}
	Write-Host "FilenamePattern '$fileNamePattern'"
	FindStringInFiles $Pattern $FilePath $filenamePattern
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function FindStringInCppSourceFiles([string] $Pattern, [string] $FilePath = ".") {
	# FindStringInFiles -FilePath $FilePath -FileNamePattern *.h, *.hpp, *.c, *.cpp -Pattern $Pattern
	FindStringInSourceFiles $Pattern $FilePath -Language 'cpp'
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
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

	foreach ($dir in ($env:path).Split(';')) {
		if ([string]::IsNullOrEmpty($dir)) { continue }

		if ($extensions -ne $null) {
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
