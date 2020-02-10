function MakeDirIfNotExisting($Path) {
	if (!(Test-Path $Path)) {
		[void](mkdir $Path)
		Write-Host "created directory `"$Path`""
	}
}

function RemoveDirIfExistingAndNotEmpty($Path) {
	if (Test-Path $Path) {
		$dirInfo = Get-Item $Path
		if (($dirInfo.GetDirectories().Count -eq 0) -and ($dirInfo.GetFiles().Count -eq 0)) {
			rmdir -Force $Path
			Write-Host "removed directory `"$Path`""
		}
	}
}

function CopyIfTargetNotExistingOrIsOlder($Source, $Target) {
	if (!(Test-Path $Source)) {
		throw "source of copy operation `"$Source`" does not exist, did the build succeed?"
	}

	if (!(Test-Path $Target)) {
		Copy-Item $Source $TargetDir
		Write-Host "copied `"$Source`" to `"$Target`""
	} else {
		$sourceTime = (Get-Item $Source).LastWriteTime
		$targetTime = (Get-Item $Target).LastWriteTime
		if ($sourceTime -gt $targetTime) {
			Copy-Item $Source $TargetDir
			Write-Host "copied `"$Source`" to `"$Target`""
		}
	}
}

function RemoveIfExisting($Path) {
	if(Test-Path $Path) {
		Remove-Item $Path
		Write-Host "removed file `"$Path`""
	}
}
