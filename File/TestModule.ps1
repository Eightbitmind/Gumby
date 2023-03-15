using module Gumby.Debug
using module Gumby.Test

# test the code in the local module rather than the code in the installed (i.e. published) module 
using module ".\File.psm1"

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

[TestClass()]
class GetTextFileEncodingTests {

	[TestClassSetup()]
	[void] Setup() {
		$testFolderBaseName = "$env:TEMP\GetTextFileEncodingTests"
		$this.testFolder = $testFolderBaseName
		$success = $false
		for ($i = 2; $i -lt <# sanity cap #> 1000; ++$i) {
			if (!(Test-Path $this.testFolder)) {
				mkdir $this.testFolder
				$success = $true
				break
			}
			$this.testFolder = "$testFolderBaseName-{0:D3}" -f $i
		}
		Assert $success
	}

	[TestClassTeardown()]
	[void] Teardown() {
		Remmove-Item -Recurse -Force $this.testFolder
	}

	[TestMethod()]
	[void] GetTextFileEncodingASCII() {
		$testFile = "$($this.testFolder)\ascii.txt"
		[void](Out-File -Encoding ascii -Path $testFile -InputObject "The quick brown fox")

		# Write-Host (Get-TextFileEncoding $testFile)
		# Write-Host ([TextFileEncoding]::ASCII)
		Test ([TextFileEncoding]::ASCII) (Get-TextFileEncoding $testFile)
		# Test 1 1
	}

	[string] $testFolder
}

$tests = @([GetTextFileEncodingTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\StringTests.log" @tests }
}
