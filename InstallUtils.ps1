function EnsureEmptyDir($Path) {
	if (Test-Path $Path) {
		Remove-Item -Recurse -Force "$Path\*"
	} else {
		[void](mkdir $Path)
	}
}

# I considered 
# - Import-PowerShellDataFile
# - ConvertFrom-StringData
# - Import-LocalizedData
# for expansion of psd1 "templates". I'm going with plain text I/O to preserve comments.
function ExpandFile($OriginalFile, $MacroFile, $ExpandedFile) {
	if (!(Test-Path $OriginalFile)) {
		throw "expansion source `"$OriginalFile`" does not exist"
	}

	if (!(Test-Path $MacroFile)) {
		throw "macro file `"$MacroFile`" does not exist"
	}

	function _ExpandFile {
		[string] $originalEncoding = Get-TextFileEncoding $OriginalFile
		$Macros = Import-PowerShellDataFile $MacroFile
		$expandedContent = ExpandMacros (Get-Content -Raw $OriginalFile) $Macros
		Write-Output $expandedContent | Out-File -Encoding $originalEncoding -FilePath $ExpandedFile
	}

	if (Test-Path $ExpandedFile) {
		$originalFileTime = (Get-Item $OriginalFile).LastWriteTime
		$macroFileTime = (Get-Item $MacroFile).LastWriteTime
		$expandedFileTime = (Get-Item $ExpandedFile).LastWriteTime

		if (($originalFileTime -gt $expandedFileTime) -or ($macroFileTime -gt $expandedFileTime)) {
			_ExpandFile
			Write-Host "expanded `"$OriginalFile`" to `"$ExpandedFile`" because the target was out of date"
		} else {
			Write-Host "skipped expanding `"$OriginalFile`" to `"$ExpandedFile`" because the target is up to date"
		}

	} else {
		_ExpandFile
		Write-Host "expanded `"$OriginalFile`" to `"$ExpandedFile`" because the target did not exist"
	}
}

function MakeDirIfNotExisting($Path) {
	if (!(Test-Path $Path)) {
		[void](mkdir $Path)
		Write-Host "created directory `"$Path`""
	} else {
		Write-Host "skipped creating directory `"$Path`" because it exists"
	}
}

function RemoveDirIfExistingAndNotEmpty($Path) {
	if (Test-Path $Path) {
		$dirInfo = Get-Item $Path
		if (($dirInfo.GetDirectories().Count -eq 0) -and ($dirInfo.GetFiles().Count -eq 0)) {
			rmdir -Force $Path
			Write-Host "removed directory `"$Path`""
		} else {
			Write-Host "skipped removing directory `"$Path`" because it isn't empty"
		}
	} else {
		Write-Host "skipped removing directory `"$Path`" because it doesn't exist"
	}
}

function CopyFileIfTargetNotExistingOrIsOlder($Source, $Target) {
	if (!(Test-Path $Source)) {
		throw "copy source `"$Source`" does not exist"
	}

	if (Test-Path $Target) {
		$sourceTime = (Get-Item $Source).LastWriteTime
		$targetTime = (Get-Item $Target).LastWriteTime
		if ($sourceTime -gt $targetTime) {
			Copy-Item $Source $Target
			Write-Host "copied `"$Source`" to `"$Target`""
		} else {
			Write-Host "skipped copying `"$Source`" to `"$Target`" because the target is up to date"
		}
	} else {
		Copy-Item $Source $Target
		Write-Host "copied `"$Source`" to `"$Target`""
	}
}

function RemoveFileIfExisting($Path) {
	if (Test-Path $Path) {
		Remove-Item $Path
		Write-Host "removed file `"$Path`""
	} else {
		Write-Host "skipped removing file `"$Path`" because it doesn't exist"
	}
}
