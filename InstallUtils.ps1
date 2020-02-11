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
