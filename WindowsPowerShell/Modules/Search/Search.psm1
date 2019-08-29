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
	.

.PARAMETER Text
	.
#>
function FindExecutableInPath([string] $ExecutableName) {
	if (!$ExecutableName.EndsWith(".exe")) { $ExecutableName += ".exe" }
	foreach($dir in ($env:path).Split(';'))	{
		if ([string]::IsNullOrEmpty($dir)) { continue }
		$tentative = Join-Path $dir $ExecutableName
		if (Test-Path $tentative) { echo "$tentative" }
	}
}

Export-ModuleMember -Function FindStringInCppSourceFiles, FindStringInJSSourceFiles, FindExecutableInPath
