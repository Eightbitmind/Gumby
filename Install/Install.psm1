using module Gumby.File
using module Gumby.Log

# Future:
# - change functions to push inverse operation onto stack, thereby enabling roll-back and automatic
#   generation of uninstall scripts

function IsCurrentUserAdmin() {
	return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
		[Security.Principal.WindowsBuiltInRole]::Administrator)
}

# alternative names:
# EnsureDirectory
function CreateDirectoryIfNotExisting($Path) {
	if (!(Test-Path $Path)) {
		[Log]::Comment("creating directory `"$Path`"")
		[void](mkdir $Path)
	} else {
		[Log]::Comment("skipping creation of directory `"$Path`" because it exists")
	}
}

function RemoveDirectoryIfExistingAndEmpty($Path) {
	if (Test-Path -PathType Container $Path) {
		$dirInfo = Get-Item $Path
		if (($dirInfo.GetDirectories().Count + $dirInfo.GetFiles().Count) -eq 0) {
			[Log]::Comment("removing directory `"$Path`"")
			rmdir $Path
		} else {
			[Log]::Comment("skipping removal of directory `"$Path`" because it is not empty")
		}
	} else {
		[Log]::Comment("skipping removal of directory `"$Path`" because it does not exist")
	}
}

# alternative names:
# EnsureSymbolicLink
function CreateSymbolicLinkIfNotExisting($Link, $Target) {
	if (!(Test-Path $Target)) {
		$errorMessage = "link target `"$Target`" does not exist"
		[Log]::Error($errorMessage)
		throw $errorMessage
	}

	if ($Target -is [string]) { $Target = Get-Item $Target }

	if (Test-Path $Link) {
		if ($Link -is [string]) { $Link = Get-Item $Link }

		if (IsSymbolicLink $Link) {
			if ($Link.Target[0] -eq $Target.FullName) {
				[Log]::Comment("skipping creation of symbolic link from `"$Link`" to `"$Target`" because it exists")
			} else {
				[Log]::Comment("re-targeting symbolic link `"$Link`" to `"$Target`"")
				Remove-Item -Force $Link
				# requires admin privileges
				CreateSymbolicLink -Target $Target -Link $Link
			}
		} else {
			[Log]::Comment("overwriting file at `"$Link`" with link to `"$Target`"")
			Remove-Item -Force $Link
			# requires admin privileges
			CreateSymbolicLink -Target $Target -Link $Link
		}
	} else {
		[Log]::Comment("creating symbolic link `"$Link`" targeting `"$Target`"")
		# requires admin privileges
		CreateSymbolicLink -Target $Target -Link $Link
	}
}

function CopyFileIfTargetNotExistingOrIsOlder($Source, $Target) {
	if (!(Test-Path $Source)) {
		$errorMessage = "source of copy operation `"$Source`" does not exist"
		[Log]::Error($errorMessage)
		throw $errorMessage
	}

	if (!(Test-Path $Target)) {
		[Log]::Comment("copying `"$Source`" to `"$Target`" because target does not exist")
		Copy-Item $Source $Target
	} else {
		$sourceTime = (Get-Item $Source).LastWriteTime
		$targetTime = (Get-Item $Target).LastWriteTime
		if ($sourceTime -gt $targetTime) {
			[Log]::Comment("copying `"$Source`" to `"$Target`" because target is outdated")
			Copy-Item $Source $Target
		} else {
			[Log]::Comment("skipping copying of `"$Source`" to `"$Target`" because target is up to date")
		}
	}
}

# alternative names:
# EnsureFileRemoved
function RemoveFileIfExisting($Path) {
	if (Test-Path $Path) {
		[Log]::Comment("removing file `"$Path`"")
		Remove-Item $Path
	} else {
		[Log]::Comment("skipping removal of file `"$Path`" because it does not exist")
	}
}
