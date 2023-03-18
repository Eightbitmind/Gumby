using module Gumby.Debug
using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Search.psm1"

[TestClass()]
class FindStringInFilesTests {
	[TestClassSetup()]
	[void] Setup() {
		$testFolderBaseName = "$env:TEMP\FindStringInFilesTests"
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


	mkdir "$($this.testFolder)\Farm\Barn"
	Write-Output @"
class Needle
{
	void Thread(int);
	void Sew(int, bool);
};
"@ > "$($this.testFolder)\Farm\Barn\Haystack.h"

	Write-Output @"
#include "Haystack.h"
#include <iostream>

void Needle::Thread(int n)
{
	std::cout << "thread n: " << n << std::endl;
}

void Needle::Sew(double f)
{
	std::cout << "sew n: " << n << std::endl;
}

};
"@ > "$($this.testFolder)\Farm\Barn\Haystack.cpp"


	mkdir "$($this.testFolder)\FarOff\Lands"
	Write-Output @"
const Waldo = () {
	console.log("Woof");
};
"@ > "$($this.testFolder)\FarOff\Lands\GobblingGluttons.js"
	}

	[TestClassTeardown()]
	[void] Teardown() {
		if (Test-Path $this.testFolder) {
			Remove-Item -Recurse -Force $this.testFolder
		}
	}

	[TestMethod()]
	[void] FindStringInCppSourceFiles_FindsNeedleDecl() {

		$result = FindStringInCppSourceFiles -Pattern "(class|struct)\s+Needle\b" -FilePath $this.testFolder
		Test (ExpectRegex "Farm\\Barn\\Haystack.h\(1\): class Needle") $result

	}

	[TestMethod()]
	[void] FindStringInCppSourceFiles_FindsNeedleMethodImpls() {

		$result = FindStringInCppSourceFiles -Pattern "Needle::\w+\s*\(" -FilePath $this.testFolder
		Test 2 $result.Count
		Test (ExpectRegex "Farm\\Barn\\Haystack.cpp\(4\): void Needle::Thread\(int n\)") $result[0]
		Test (ExpectRegex "Farm\\Barn\\Haystack.cpp\(9\): void Needle::Sew\(double f\)") $result[1]
	}

	[TestMethod()]
	[void] FindStringInCppSourceFiles_DoesNotFindsObstacle() {

		$result = FindStringInCppSourceFiles -Pattern "Obstacle" -FilePath $this.testFolder
		Test 0 $result.Count
	}

	[TestMethod()]
	[void] FindStringInJSSourceFiles_FindsWaldo() {

		$result = FindStringInJSSourceFiles -Pattern "Waldo" -FilePath $this.testFolder
		Test (ExpectRegex "FarOff\\Lands\\GobblingGluttons.js\(1\): const Waldo = \(\) {") $result
	}

	[TestMethod()]
	[void] FindStringInJSSourceFiles_DoesNotFindsOdlaw() {

		$result = FindStringInJSSourceFiles -Pattern "Odlaw" -FilePath $this.testFolder
		Test 0 $result.Count
	}

	[string] $testFolder
}

[TestClass()]
class FindExecutableInPathTests {
	[TestMethod()]
	[void] FindExecutableInPath_FindsNotepadWithoutExtension() {

		$result = FindExecutableInPath -ExecutableName "notepad" 
		# Write-Host $result
		# as of Win11:
		# C:\Windows\system32\notepad.exe
		# C:\Windows\notepad.exe
		# $HOME\AppData\Local\Microsoft\WindowsApps\notepad.exe
		Test (ExpectCountGreaterOrEqual 1) $result
	}

	[TestMethod()]
	[void] FindExecutableInPath_FindsNotepadWithExtension() {

		$result = FindExecutableInPath -ExecutableName "notepad.exe" 
		# Write-Host $result
		# as of Win11:
		# C:\Windows\system32\notepad.exe
		# C:\Windows\notepad.exe
		# $HOME\AppData\Local\Microsoft\WindowsApps\notepad.exe
		Test (ExpectCountGreaterOrEqual 1) $result
	}

	[TestMethod()]
	[void] FindExecutableInPath_DoesNotFindVirus() {

		$result = FindExecutableInPath -ExecutableName "virus" 
		Test 0 $result.Count
	}
}

$tests = [FindStringInFilesTests], [FindExecutableInPathTests]

switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\SearchTests.log" @tests }
}
