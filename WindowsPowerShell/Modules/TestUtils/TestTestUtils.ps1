using module Log
using module TestUtils

#region Test infrastructure

function _TestAreEqual($actual, $expected, $message = "Test Value") {
	if ($actual -eq $expected) {
		Write-Host -ForegroundColor Green "value '$actual' matches expectation"
	} else {
		Write-Host -ForegroundColor Red "actual '$($actual)', expected '$($expected)'"
	}
}

$LogMessages = [Collections.ArrayList]::new()
$logObserver = [LogObserver]::new({
	param($mt, $m)
	Write-Host $m
	$LogMessages.Add(@{MessageType = $mt; Message = $m})
})

$testRunner = [TestRunner]::new()
$testRunner.TestMethodLogger = $logObserver

[Log]::Listeners.Add($logObserver) | Out-Null

#endregion

#region ClassWithThrowingConstructor

[TestClass()]
class ClassWithThrowingConstructor {
	ClassWithThrowingConstructor() {
		throw "test class constructor error"
	}

	[TestClassSetup()]
	[void] TestClassSetup() {
		throw "should not run"
	}

	[TestClassTeardown()]
	[void] TestClassTeardown() {
		throw "should not run"
	}

	[TestMethod()]
	[void] TestMethod() {
		throw "should not run"
	}
}

$testRunner.TestClasses.Add(([ClassWithThrowingConstructor])) | Out-Null
$testRunner.RunTests()

_TestAreEqual $LogMessages.Count 1
_TestAreEqual $LogMessages[0].MessageType ([LogMessageType]::Error)
_TestAreEqual $LogMessages[0].Message "failed to instantiate test class `"ClassWithThrowingConstructor`""

[Log]::Reset()
$LogMessages.Clear()
$testRunner.TestClasses.Clear()

#endregion

#region ClassWithFailingClassSetupMethod
[TestClass()]
class ClassWithFailingClassSetupMethod {
	[TestClassSetup()]
	[void] TestClassSetup1() {
		throw "class setup method error"
	}

	[TestClassSetup()]
	[void] TestClassSetup2() {
		[Log]::Error("TestClassSetup2")
	}

	[TestMethod()]
	[void] TestMethod() {
		[Log]::Error("TestMethod")
	}

	[TestClassTeardown()]
	[void] TestClassTeardown1() {
		[Log]::Success("TestClassTeardown1")
	}

	[TestClassTeardown()]
	[void] TestClassTeardown2() {
		[Log]::Success("TestClassTeardown2")
	}
}

$testRunner.TestClasses.Add([ClassWithFailingClassSetupMethod]) | Out-Null
$testRunner.RunTests()

_TestAreEqual $LogMessages.Count 3

_TestAreEqual $LogMessages[0].MessageType ([LogMessageType]::Error)
_TestAreEqual $LogMessages[0].Message "failed to execute `"TestClassSetup1`" class setup method of test class `"ClassWithFailingClassSetupMethod`""

_TestAreEqual $LogMessages[1].MessageType ([LogMessageType]::Success)
_TestAreEqual $LogMessages[1].Message "TestClassTeardown1"

_TestAreEqual $LogMessages[2].MessageType ([LogMessageType]::Success)
_TestAreEqual $LogMessages[2].Message "TestClassTeardown2"

[Log]::Reset()
$LogMessages.Clear()
$testRunner.TestClasses.Clear()

#endregion


#region ClassWithSucceedingTestMethod

[TestClass()]
class ClassWithSucceedingTestMethod {

	[TestMethod()]
	[void] TestMethod() {
		[Log]::Success("log call from within TestMethod")
	}
}

$testRunner.TestClasses.Add(([ClassWithSucceedingTestMethod])) | Out-Null
$testRunner.RunTests()

_TestAreEqual $LogMessages.Count 2

_TestAreEqual $LogMessages[0].MessageType ([LogMessageType]::Success)
_TestAreEqual $LogMessages[0].Message "log call from within TestMethod"

_TestAreEqual $LogMessages[1].MessageType ([LogMessageType]::Success)
_TestAreEqual $LogMessages[1].Message "TestMethod" # test runner logging the successful execution of the test method

# TestAreEqual $LogMessages[2].MessageType ([LogMessageType]::Success)
# TestAreEqual $LogMessages[2].Message "TestClassTeardown2"

[Log]::Reset()
$LogMessages.Clear()
$testRunner.TestClasses.Clear()

#endregion

#[Log]::Listeners.Remove($consoleLogListener)
[Log]::Listeners.Remove($logObserver)
