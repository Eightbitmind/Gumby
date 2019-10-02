
function SelectFirstExisting($CandidateList) {
	foreach ($candidate in $CandidateList) {
		if (Test-Path $candidate) { return $candidate }
	}
	throw "none of the options in $CandidateList can be found"
}

<#
.SYNOPSIS
	Starts AccEvent.

.PARAMETER Text
	.
#>
function StartAccEvent(){
	& "${env:ProgramFiles(x86)}\Windows Kits\8.1\bin\x64\accevent.exe"
}

<#
.SYNOPSIS
	Starts the Fusion log viewer.

.PARAMETER Text
	.
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

.PARAMETER Text
	.
#>
function StartInspect(){
	& "${env:ProgramFiles(x86)}\Windows Kits\8.1\bin\x64\inspect.exe"
}

<#
.SYNOPSIS
	Starts MSTest.

.PARAMETER Text
	.
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

.PARAMETER Text
	.
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

<#
.SYNOPSIS
	Opens a file in the PowerShell ISE.

.PARAMETER fileName
	Name of the file to open.
#>
function OpenWithPSEdit([string] $fileName) {
	foreach ($command in
		"${env:SystemRoot}\system32\WindowsPowerShell\v1.0\PowerShell_ISE.exe",
		"INVALIDPATH") {
		if (Test-Path $command) { break }
	}

	&$command $fileName
}

<#
.SYNOPSIS
	Opens a file in Visual Studio.

.PARAMETER Text
	.
#>
function OpenWithVisualStudio([string] $fileName, [switch] $newVSInstance) {
	foreach ($command in
		"${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe",
		"${env:ProgramFiles(x86)}\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe",
		"INVALIDPATH")
	{
		if (Test-Path $command) { break }
	}

	if ($newVSInstance) { $edit = '' } else { $edit = "/edit" }
	Write-Host "DBG:$command $edit $filename"

	&$command $edit $fileName
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function OpenWithVisualStudioCode([switch] $NewInstance) {
	$app = SelectFirstExisting "$HOME\AppData\Local\Programs\Microsoft VS Code\bin\code.cmd", "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd"
	$reuse = if ($NewInstance) { '' } else { '-r' }
	&$app $reuse $args
}

<#
.SYNOPSIS
	.

.PARAMETER Text
	.
#>
function OpenWindowsExplorer() {
	explorer $args
}

Export-ModuleMember -Function StartAccEvent,
	StartFusionLogViewer,
	StartILSpy,
	StartInspect,
	StartMSTest,
	StartTlbImp,
	OpenWithPSEdit,
	OpenWithVisualStudio,
	OpenWithVisualStudioCode,
	OpenWindowsExplorer
