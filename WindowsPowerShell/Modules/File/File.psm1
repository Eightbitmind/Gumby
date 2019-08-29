<#
.SYNOPSIS
	Creates a symbolic link.

.PARAMETER Text
	.
#>
function CreateSymbolicLink($Target, $Link) {
	New-Item -Path $Link -ItemType SymbolicLink -Value $Target
}

<#
.SYNOPSIS
	Sets the read-only property of an item.

.PARAMETER Text
	.
#>
function SetReadOnly([string] $Path, [bool] $Value = $false) {
	Set-ItemProperty -Name IsReadOnly -Value $Value -Path $Path
}

Export-ModuleMember -Function CreateSymbolicLink, SetReadOnly
