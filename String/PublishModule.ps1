using module File
using module Gumby.Path

function ExpandMacros($Text, $Macros) {
	[regex] $macroPattern = '(?<!`)\$(?<MacroName>[a-zA-Z_]\w*)'
	return $macroPattern.Replace($Text, {
		param ($match)
		$macroName = $match.Groups['MacroName'].Value
		if ($Macros.ContainsKey($macroName)) {
			return $Macros[$macroName]
		} else {
			return $match.Value
		}
	})
}

function ExpandFile($OriginalFile, $Macros, $ExpandedFile) {
	[string] $originalEncoding = Get-TextFileEncoding $OriginalFile
	$expandedContent = ExpandMacros (Get-Content -Raw $OriginalFile) $Macros
	Write-Output $expandedContent | Out-File -Encoding $originalEncoding -FilePath $ExpandedFile
}

$PublishName = "Gumby.String"

$StagingDir = "$($env:TEMP)\$(PathFileBaseName $PSCommandPath)\$PublishName"
if (Test-Path $StagingDir) {
	Remove-Item -Recurse -Force "$StagingDir\*"
} else {
	[void](mkdir $StagingDir)
}

$macros = @{
	RootModule = "$($PublishName).psm1"
}

ExpandFile "$PSScriptRoot\String.psd1t" $macros "$StagingDir\$PublishName.psd1"
Copy-Item "$PSScriptRoot\String.psm1" "$StagingDir\$PublishName.psm1"

# Import-PowerShellDataFile
# ConvertFrom-StringData
# Import-LocalizedData