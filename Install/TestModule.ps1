using module Gumby.Log
using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Install.psm1"

[TestClass()]
class InstallModuleTests {
	hidden [string] $testRootDir = "$env:TEMP\InstallModuleTests"
	hidden [DateTime] $classStartTime = (Get-Date)

	[TestClassSetup()]
	[void] CreateTestDirectory() {
		if (Test-Path $this.testRootDir) { Remove-Item -Recurse -Force $this.testRootDir }
		[void](mkdir $this.testRootDir)
		[void](mkdir "$($this.testRootDir)\Target")
		Write-Output "# build output" > "$($this.testRootDir)\Target\Foo.ps1"
		Write-Output "# build output" > "$($this.testRootDir)\Target\Bar.ps1"
	}

	[TestClassTeardown()]
	[void] RemoveTestDirectory() {
		Remove-Item -Recurse -Force $this.testRootDir
	}

	[TestMethod()]
	[void] CreateDirectoryIfNotExisting_DirectoryExists() {
		$dir = "$($this.testRootDir)\Publish"

		try {
			if (!(Test-Path $dir)) { [void](mkdir $dir) }

			CreateDirectoryIfNotExisting $dir

			Test $true (Test-Path $dir)
			Test $true (IsDirectory $dir)
		} finally {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
		}
	}

	[TestMethod()]
	[void] CreateDirectoryIfNotExisting_DirectoryDoesNotExist() {
		$dir = "$($this.testRootDir)\Publish"

		try {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }

			CreateDirectoryIfNotExisting $dir

			Test $true (Test-Path $dir)
			Test $true (IsDirectory $dir)
		} finally {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
		}
	}

	[TestMethod()]
	[void] RemoveDirectoryIfExistingAndEmpty_DirectoryExistsAndIsEmpty() {
		$dir = "$($this.testRootDir)\Publish"

		try {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
			[void](mkdir $dir)

			RemoveDirectoryIfExistingAndEmpty $dir

			Test $false (Test-Path $dir)
		} finally {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
		}
	}

	[TestMethod()]
	[void] RemoveDirectoryIfExistingAndEmpty_DirectoryDoesNotExist() {
		$dir = "$($this.testRootDir)\Publish"

		try {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }

			RemoveDirectoryIfExistingAndEmpty $dir

			Test $false (Test-Path $dir)
		} finally {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
		}
	}

	[TestMethod()]
	[void] RemoveDirectoryIfExistingAndEmpty_DirectoryIsNotEmpty() {
		$dir = "$($this.testRootDir)\Publish"
		$file = "$dir\README.txt"

		try {
			if (!(Test-Path $dir)) { [void](mkdir $dir) }
			if (!(Test-Path $file)) { Write-Output "info" > $file }

			RemoveDirectoryIfExistingAndEmpty $dir

			Test $true (Test-Path $dir)
		} finally {
			if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }
		}
	}

	[TestMethod()]
	[void] CreateSymbolicLinkIfNotExisting_LinkDoesNotExist() {
		if (!(IsCurrentUserAdmin)) {
			Test 1 1 # ensure test method doesn't fail because it's lacking a test
			[Log]::Warning("This test method requires administrator privileges.")
			return
		}

		$link = "$($this.testRootDir)\Setup\Foo.ps1"
		$target = "$($this.testRootDir)\Target\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) {[void](mkdir "$($this.testRootDir)\Setup")}
			if (Test-Path $link) { Remove-Item -Force $link }

			CreateSymbolicLinkIfNotExisting -Target $target -Link $link

			Test $true (Test-Path $link)
			Test $true (IsSymbolicLink $link)
			Test $target (Get-Item $link).Target
		} finally {
			if (Test-Path $link) { Remove-Item -Force $link }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CreateSymbolicLinkIfNotExisting_LinkExists() {
		if (!(IsCurrentUserAdmin)) {
			Test 1 1 # ensure test method doesn't fail because it's lacking a test
			[Log]::Warning("This test method requires administrator privileges.")
			return
		}

		$link = "$($this.testRootDir)\Setup\Foo.ps1"
		$target = "$($this.testRootDir)\Target\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }
			if (Test-Path $link) { Remove-Item -Force $link }
			CreateSymbolicLink -Target $target -Link $link

			CreateSymbolicLinkIfNotExisting -Target $target -Link $link

			Test $true (Test-Path $link)
			Test $true (IsSymbolicLink $link)
			Test $target (Get-Item $link).Target
		} finally {
			if (Test-Path $link) { Remove-Item -Force $link }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CreateSymbolicLinkIfNotExisting_LinkIsAFile() {
		if (!(IsCurrentUserAdmin)) {
			Test 1 1 # ensure test method doesn't fail because it's lacking a test
			[Log]::Warning("This test method requires administrator privileges.")
			return
		}

		$link = "$($this.testRootDir)\Setup\Foo.ps1"
		$target = "$($this.testRootDir)\Target\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }
			if (Test-Path $link) { Remove-Item -Force $link }
			# create a file in the place of the link we want to establish
			Write-Output "# not an output of a current, local build" > $link

			CreateSymbolicLinkIfNotExisting -Target $target -Link $link

			Test $true (Test-Path $link)
			Test $true (IsSymbolicLink $link)
			Test $target (Get-Item $link).Target
		} finally {
			if (Test-Path $link) { Remove-Item -Force $link }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CreateSymbolicLinkIfNotExisting_LinkExistsWithDifferentTarget() {
		if (!(IsCurrentUserAdmin)) {
			Test 1 1 # ensure test method doesn't fail because it's lacking a test
			[Log]::Warning("This test method requires administrator privileges.")
			return
		}

		$link = "$($this.testRootDir)\Setup\Foo.ps1"
		$target = "$($this.testRootDir)\Target\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }
			if (Test-Path $link) { Remove-Item -Force $link }
			# create a link targeting a different file
			CreateSymbolicLink -Link $link -Target "$($this.testRootDir)\Target\Bar.ps1"

			CreateSymbolicLinkIfNotExisting -Target $target -Link $link

			Test $true (Test-Path $link)
			Test $true (IsSymbolicLink $link)
			Test $target (Get-Item $link).Target
		} finally {
			if (Test-Path $link) { Remove-Item -Force $link }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CopyFileIfTargetNotExistingOrIsOlder_TargetDoesNotExist() {

		$source = "$($this.testRootDir)\Target\Foo.ps1"
		$target = "$($this.testRootDir)\Setup\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (Test-Path $target) { Remove-Item -Force $target }
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }

			CopyFileIfTargetNotExistingOrIsOlder -Source $source -Target $target

			Test $true (Test-Path $target)

		} finally {
			if (Test-Path $target) { Remove-Item -Force $target }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CopyFileIfTargetNotExistingOrIsOlder_TargetExistsAndIsOlder() {

		$source = "$($this.testRootDir)\Target\Foo.ps1"
		$target = "$($this.testRootDir)\Setup\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }
			if (!(Test-Path $target)) { Write-Output "# build output" > $target }
			# back-date the file
			(Get-Item $target).LastWriteTime = $this.classStartTime - [TimeSpan]::new(<# hours#> 0, <# minutes#> 0, <# seconds #> 10)

			CopyFileIfTargetNotExistingOrIsOlder -Source $source -Target $target

			Test $true (Test-Path $target)

		} finally {
			if (Test-Path $target) { Remove-Item -Force $target }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] CopyFileIfTargetNotExistingOrIsOlder_TargetExistsAndIsUpToDate() {

		$source = "$($this.testRootDir)\Target\Foo.ps1"
		$target = "$($this.testRootDir)\Setup\Foo.ps1"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path "$($this.testRootDir)\Setup")) { [void](mkdir "$($this.testRootDir)\Setup") }
			if (Test-Path $target) {
				# ensure target is as new or newer than the file source (created by test setup method)
				(Get-Item $target).LastWriteTime = Get-Date
			} else {
				Write-Output "# build output" > $target
			}

			CopyFileIfTargetNotExistingOrIsOlder -Source $source -Target $target

			Test $true (Test-Path $target)

		} finally {
			if (Test-Path $target) { Remove-Item -Force $target }
			if (Test-Path "$($this.testRootDir)\Setup" ) { Remove-Item -Recurse -Force "$($this.testRootDir)\Setup" }
		}
	}

	[TestMethod()]
	[void] RemoveFileIfExisting_FileExists() {
		$file = "$($this.testRootDir)\README.txt"

		try {
			# in case a previous test got interrupted
			if (!(Test-Path $file)) { Write-Output "info" > $file }

			RemoveFileIfExisting $file

			Test $false (Test-Path $file)
		} finally {
			if (Test-Path $file) { Remove-Item -Force $file }
		}
	}

	[TestMethod()]
	[void] RemoveFileIfExisting_FileDoesNotExist() {
		$file = "$($this.testRootDir)\README.txt"

		if (Test-Path $file) { Remove-Item -Force $file }

		RemoveFileIfExisting $file

		Test $false (Test-Path $file)
	}
}

$tests = @([InstallModuleTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\InstallTests.log" @tests }
}
