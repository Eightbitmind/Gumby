<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function NetFxDirs
{
	$netFxBaseDir = (Get-ItemProperty HKLM:\SOFTWARE\Microsoft\.NETFramework "InstallRoot").InstallRoot
	$dirs = ls $netFxBaseDir | where {$_ -like "v*"} | sort -descending

	if (Test-Path "env:OTOOLS")
	{
		$dirs += Get-ChildItem "$env:OTOOLS\bin\urt" | where {$_ -like "v*"} | sort -descending
	}
	$dirs
}

$ProgramCache = @{}

<#
.SYNOPSIS
	.

.PARAMETER name
	.
#>
function Find-NetFxProgram([string]$name)
{
	if (!$ProgramCache.ContainsKey($name))
	{
		Write-Host "searching $name..."
		$cands = @()
		foreach ($dir in NetFxDirs)
		{
			$cands += (Get-ChildItem -r -i $name $dir.FullName)
		}

		# TODO: select "best" based on platform?
		$newPrg = $cands | Select-Object -first 1

		$ProgramCache.Add($name, $newPrg)
	}
	$prg = $ProgramCache[$name]
	Write-Host -background DarkGray -foreground black "$prg"
	$prg
}

<#
.SYNOPSIS
	Starts al.exe.
#>
function Start-AssemblerLinker
{
	&(Find-NetFxProgram "al.exe") $args
}

<#
.SYNOPSIS
	Starts gacutil.

.PARAMETER Text
	.
#>
function Start-GacUtil
{
	&(Find-NetFxProgram "gacutil.exe") $args
}


<#
.SYNOPSIS
	Starts ildasm.
#>
function Start-Ildasm
{
	&(Find-NetFxProgram "ildasm.exe") $args
}

<#
.SYNOPSIS
	Starts installutil.

.PARAMETER Text
	.
#>
function Start-InstallUtil
{
	&(Find-NetFxProgram "installutil.exe") $args
}

<#
.SYNOPSIS
	Starts sn.exe (Strong Name tool).

.PARAMETER Text
	.
#>
function Start-StrongNameUtility
{
	&(Find-NetFxProgram "sn.exe") $args
}
