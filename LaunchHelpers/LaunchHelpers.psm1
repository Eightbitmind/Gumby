<#
.SYNOPSIS
	Starts AccEvent.
#>
function StartAccEvent(){
	& "${env:ProgramFiles(x86)}\Windows Kits\8.1\bin\x64\accevent.exe"
}

<#
.SYNOPSIS
	Starts the Fusion log viewer.
#>
function StartFusionLogViewer() {
	foreach ($command in
		"$env:ProgramFiles\Microsoft SDKs\Windows\v6.0A\Bin\x64\FUSLOGVW.exe",
		"$env:ProgramFiles\Microsoft SDKs\Windows\v6.0A\Bin\FUSLOGVW.exe",
		"INVALIDPATH") {
		if (Test-Path $command) { break }
	}

	&$command $args
}

<#
.SYNOPSIS
	Starts ILSpy.
#>
function StartILSpy() {
	& "$MyCommandsFolder\ILSpy-2.1.0.1603\ILSpy.exe" $args
}

<#
.SYNOPSIS
	Starts Inspect.
#>
function StartInspect(){
	& "${env:ProgramFiles(x86)}\Windows Kits\8.1\bin\x64\inspect.exe"
}

<#
.SYNOPSIS
	Starts MSTest.
#>
function StartMSTest() {
	foreach ($command in
		"${env:ProgramFiles(x86)}\Microsoft Visual Studio 11.0\Common7\IDE\mstest.exe",
		"${env:ProgramFiles(x86)}\Microsoft Visual Studio 10.0\Common7\IDE\mstest.exe",
		"INVALIDPATH") {
		if (Test-Path $command) { break }
	}

	&$command $args
}

<#
.SYNOPSIS
	Starts tlbimp.
#>
function StartTlbImp() {
	foreach ($command in
		"$env:OTOOLS\Microsoft SDKs\Windows\v6.0A\Bin\x64\TlbImp.exe",
		"$env:ProgramFiles\Microsoft SDKs\Windows\v6.0A\Bin\TlbImp.exe",
		"INVALIDPATH") {

		if (Test-Path $command) { break }

	}

	&$command $args
}

$StartVisualStudioCache = $null

<#
.SYNOPSIS
	Starts Visual Studio, or opens a file in it.

.PARAMETER File
	File to open in Visual Studio.

.PARAMETER NewInstance
	Launches new instance of Visual Studio, or, if specified, opens a file in a new instance of
	Visual Studio.

.PARAMETER VSVersion
	Verrsio of Visual Studio to launch or open file in.
#>
function StartVisualStudio([string] $File, [switch] $NewInstance, [string] $VSVersion = "latest"){

	if ($null -eq $StartVisualStudioCache) {
		$vsWherePath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
		
		if (!(Test-Path $vsWherePath)) {
			throw "requires `"$vsWherePath`", i.e. VS 2017 or greater"
		}

		$Script:StartVisualStudioCache = &$vsWherePath -sort -format json | ConvertFrom-Json
	}

	if ($StartVisualStudioCache -is [array]) {
		throw "implement version search in vswhere data"
	} else {
		$vsPath = $StartVisualStudioCache.productPath
	}

	if ($File -and !$NewInstance) {
		$edit = "/edit"
	} else {
		$edit = ""
	}

	&$vsPath $edit $File
}
