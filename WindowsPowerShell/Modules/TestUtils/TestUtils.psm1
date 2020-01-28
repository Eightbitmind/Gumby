using module Log
using module String

function TestIsTrue($condition, $message = "value is true") {
	if ($condition) {
		[Log]::Success($message)
	} else {
		[Log]::Failure($message)
	}
}

function TestIsFalse($condition, $message = "value is false") {
	if (!$condition) {
		[Log]::Success($message)
	} else {
		[Log]::Failure($message)
	}
}

function TestIsNull($actual, $message = "object is null") {
	if ($null -eq $actual) {
		[Log]::Success($message)
	} else {
		[Log]::Failure($message)
	}
}

# TODO: NotNullExpectedObject?
function TestIsNotNull($actual, $message = "object is not null") {
	if ($null -ne $actual) {
		[Log]::Success($message)
	} else {
		[Log]::Failure($message)
	}
}

# TODO: TypeExpectedObject?
function TestIsType($object, $type) {
	if ($object -is $type) {
		[Log]::Success("object is of type $($type.Name)")
	} else {
		[Log]::Failure("object is of type $($object.GetType()), expected $($type.Name)")
	}
}

function TestAreEqual($actual, $expected, $messagePrefix) {
	[void] (AreValuesEqual $actual $expected {param($m) [Log]::Success($m)} {param($m) [Log]::Failure($m)} $messagePrefix)
}

function TestIsGreaterOrEqual($actual, $expected, $message = "Test Value") {
	if ($actual -ge $expected) {
		[Log]::Success("'$actual' is greater or equal '$expected'")
	} else {
		[Log]::Failure("'$($actual)' is not greater or equal '$expected'")
	}
}

function AreValuesEqual($actual, $expected, $messagePrefix) {
	if ($actual -eq $expected) {
		[Log]::Success("$($messagePrefix)value '$actual' matches expectation")
		return $true
	} else {
		[Log]::Failure("$($messagePrefix)actual '$($actual)', expected '$($expected)'")
		return $false
	}
}

class ExpectedObjectBase {
	[bool] IsEqual($actual, $messagePrefix) {
		throw "derived classes must implement this method"
	}
}

class RegexExpectedObject : ExpectedObjectBase {
	RegexExpectedObject($pattern) {
		$this.pattern = $pattern
	}

	[bool] IsEqual($actual, $messagePrefix) {
		$result = $actual -match $this.pattern
		if ($result) {
			[Log]::Success("$($messagePrefix)`"$actual`" matches pattern `"$($this.pattern)`"")
		} else {
			[Log]::Failure("$($messagePrefix)`"$actual`" does not match pattern `"$($this.pattern)`"")
		}
		return $result
	}

	hidden [string] $pattern
}

class ContainsExpectedObject : ExpectedObjectBase {
	ContainsExpectedObject($expected) {
		$this.expected = $expected
	}

	[bool] IsEqual($actualItems, $messagePrefix) {

		# We're performing an opportunistic search below where a non-matching actual item does not
		# necessarily constitute a failure.
		$logInterceptor = [LogInterceptor]::new({param($interceptor, $messageType, $message)
			if ($messageType -eq ([LogMessageType]::Success)) {
				$interceptor.DispatchMessage($messageType, $message)
			}
		})

		try {
			$actualItemIndex = 0
			foreach ($actualItem in $actualItems) {
				if (AreObjectsEqual $actualItem $this.expected "$($messagePrefix)item $(($actualItemIndex++)): ") {
					[Log]::Failure("$($messagePrefix)found expected item '$($this.expected)'")
					return $true
				}
			}

		} finally {
			$logInterceptor.Dispose()
		}

		[Log]::Failure("$($messagePrefix)missing item '$($this.expected)'")
		return $false
	}

	hidden $expected
}

class NotExpectedObject : ExpectedObjectBase {
	NotExpectedObject($expected) {
		$this.expected = $expected
	}

	[bool] IsEqual($actual, $messagePrefix) {
		$logInterceptor = [LogInterceptor]::new({ param ($interceptor, $messageType, $message)
			switch ($messageType) {
				([LogMessageType]::Failure) { $messageType = ([LogMessageType]::Success)}
				([LogMessageType]::Success) { $messageType = ([LogMessageType]::Failure)}
			}
			$interceptor.DispatchMessage($messageType, $message)
		})
		try {
			return !(AreObjectsEqual $actual $this.expected "$($messagePrefix)negate: ")
		} finally {
			$logInterceptor.Dispose()
		}
	}

	hidden $expected
}

class AndExpectedObject : ExpectedObjectBase {
	AndExpectedObject($expected) {
		$this.expected  = $expected
	}

	[bool] IsEqual($actual, $messagePrefix) {
		foreach ($expectedTerm in $this.expected) {
			if (!(AreObjectsEqual $actual $expectedTerm "$($messagePrefix)AND: ")) {
				[Log]::Failure("$($messagePrefix)AND evaluates to false")
				return $false
			}
		}
		[Log]::Success("$($messagePrefix)AND evaluates to true")
		return $true
	}

	hidden $expected
}

class OrExpectedObject : ExpectedObjectBase {
	OrExpectedObject($expected) {
		$this.expected  = $expected
	}

	[bool] IsEqual($actual, $messagePrefix) {
		# A false OR term does not necessarily constitute a failure.
		$logInterceptor = [LogInterceptor]::new({param($interceptor, $messageType, $message)
			if ($messageType -eq ([LogMessageType]::Failure)) {
				$messageType = ([LogMessageType]::Comment)
			}
			$interceptor.DispatchMessage($messageType, $message)
		})

		$result = $false
		try {
			foreach ($expectedTerm in $this.expected) {
				if (AreObjectsEqual $actual $expectedTerm "$($messagePrefix)OR: ") {
					$result = $true
					break
				}
			}
		} finally {
			$logInterceptor.Dispose()
		}

		if ($result) {
			[Log]::Success("$($messagePrefix)OR evaluates to true")
		} else {
			[Log]::Failure("$($messagePrefix)OR evaluates to false")
		}
		return $result
	}

	hidden $expected
}

#region Comparand helper functions

function ExpectRegex($pattern) { [RegexExpectedObject]::new($pattern) }
function ExpectContains($item) { [ContainsExpectedObject]::new($item) }
function ExpectNot($operand) { [NotExpectedObject]::new($operand) }
function ExpectAnd { [AndExpectedObject]::new($args) }
function ExpectOr { [OrExpectedObject]::new($args) }

#endregion

function AreObjectsEqual($actual, $expected, $messagePrefix) {
	if ($expected -is [ExpectedObjectBase]) {
		return $expected.IsEqual($actual, $messagePrefix)
	} elseif (($expected -is [string]) -or ($expected -is [int])) {
		return (AreValuesEqual $actual $expected $messagePrefix)
	} elseif ($expected -is [array]) {
		# Implementation of System.Collections.IEnumerable cannot be used to differentiate between
		# objects and arrays as both implement this interface.

		$result = $true
		$actualEnum = $actual.GetEnumerator()
		$expectedEnum = $expected.GetEnumerator()
		$itemIndex = 0

		while ($actualEnum.MoveNext()) {
			if (!$expectedEnum.MoveNext()) {
				[Log]::Failure("$($messagePrefix)more items than expected")
				return $false
			}

			$result = $result -and (AreObjectsEqual $actualEnum.Current $expectedEnum.Current "$($messagePrefix)item $(($itemIndex++)): ")
		}

		if ($expectedEnum.MoveNext()) {
			[Log]::Failure("$($messagePrefix)fewer items than expected")
			return $false
		}

		return $result
	} elseif ($expected -is [object]) {

		$result = $true

		foreach ($key in $expected.Keys) {
			$expectedValue = $expected[$key]
			$actualValue = $actual.($key)
			$result = $result -and (AreObjectsEqual $actualValue $expectedValue "$($messagePrefix)member '$key': ")
		}

		return $result
	}
}

function TestObject($actual, $expected, $messagePrefix) {
	[void](AreObjectsEqual $actual $expected $messagePrefix)
}

class TestClass : Attribute {}

class TestClassSetup : Attribute {}

class TestClassTeardown : Attribute {}

class TestMethod : Attribute {}

class TestRunner {
	[Collections.ArrayList] $TestClasses = [Collections.ArrayList]::new()
	[FileLogListener] hidden $fileLogListener

	TestRunner([string] $logFilePath = "$env:TEMP\Test.log") {
		if (Test-Path $logFilePath) { Remove-Item $logFilePath }
		$this.fileLogListener = [FileLogListener]::new($logFilePath)
	}

	[void] RunTests() {
		[Log]::Listeners.Add($this.fileLogListener) | Out-Null
		foreach ($testClass in $this.TestClasses) { $this.RunTestClass($testClass) }
		[Log]::Listeners.Remove($this.fileLogListener)

		# Alternative displays:
		# 51 executed, 51 succeeded, 0 failed, 0 errors, 0 warnings
		# 51/51 succeeded

		$totalTestMethodCount = $this.successCount + $this.failureCount + $this.errorCount + $this.warningCount
		$totalResult = $true
		Write-Host "$totalTestMethodCount test method$(('', 's')[$totalTestMethodCount -gt 0]) got executed"

		if ($this.successCount -gt 0) {
			Write-Host -ForegroundColor Green "$($this.successCount) succeeded"
		} else {
			Write-Host -ForegroundColor Red "$($this.successCount) succeeded"
			$totalResult = $false
		}

		if ($this.failureCount -eq 0) {
			Write-Host -ForegroundColor Green "$($this.failureCount) failed"
		} else {
			Write-Host -ForegroundColor Red "$($this.failureCount) failed"
			$totalResult = $false
		}

		if ($this.errorCount -eq 0) {
			Write-Host -ForegroundColor Green "$($this.errorCount) resulted in an error"
		} else {
			Write-Host -ForegroundColor Red "$($this.errorCount) resulted in an error"
			$totalResult = $false
		}

		if ($this.warningCount -eq 0) {
			Write-Host -ForegroundColor Green "$($this.warningCount) resulted in a warning"
		} else {
			Write-Host -ForegroundColor Yellow "$($this.warningCount) resulted in a warning"
		}

		$this.successCount = 0
		$this.failureCount = 0
		$this.errorCount = 0
		$this.warningCount = 0
	}

	hidden [void] RunTestClass($testClass) {

		try {
			$testClassInstance = $testClass::new()
		} catch {
			[Log]::Error("failed to instantiate test class `"$($testClass.Name)`"")
			return
		}

		$this.HandleTestClassBegin($testClass.Name)
		[Log]::BeginSection("test class `"$($testClass.Name)`"")

		try {
			$testClassSetupMethodsSucceeded = $true
			foreach ($classSetupMethod in $this.FindMembers($testClass, ([TestClassSetup]))) {
				try {
					$classSetupMethod.Invoke($testClassInstance, @())
				} catch {
					[Log]::Error("failed to execute `"$($classSetupMethod.Name)`" class setup method of test class `"$($testClass.Name)`"")
		
					# don't execute any test methods
					$testClassSetupMethodsSucceeded = $false
		
					# stop executing other class setup methods
					break
				}
			}
		
			if ($testClassSetupMethodsSucceeded) {
				foreach ($testMethod in $this.FindMembers($testClass, ([TestMethod]))) {
		
					# helper object that allows us to capture the counts "by reference"
					$testMethodStats = @{
						WarningCount = 0
						ErrorCount = 0
						SuccessCount = 0
						FailureCount = 0
					}
		
					$lo = [LogObserver]::new({
						param($mt, $m)
						switch ($mt) {
							([LogMessageType]::Warning) { ++$testMethodStats.WarningCount }
							([LogMessageType]::Error) { ++$testMethodStats.ErrorCount }
							([LogMessageType]::Success) { ++$testMethodStats.SuccessCount }
							([LogMessageType]::Failure) { ++$testMethodStats.FailureCount }
						}
					})
		
					$testMethodException = $null

					[Log]::BeginSection("test method `"$($testMethod.Name)`"")
					
					[Log]::Listeners.Add($lo) | Out-Null
					try {
						$testMethod.Invoke($testClassInstance, @())
					} catch {
						$testMethodException = $_.Exception.InnerException
					}
					[Log]::Listeners.Remove($lo)
		
					if ($testMethodException -ne $null) {
						[Log]::Error("exception `"$($testMethodException.Message)`"")
						$this.HandleTestMethodError($testMethod.Name)
					} elseif($testMethodStats.ErrorCount -gt 0) {
						$this.HandleTestMethodError($testMethod.Name)
					} elseif (($testMethodStats.FailureCount -eq 0) -and ($testMethodStats.SuccessCount -gt 0)) {
						if ($testMethodStats.WarningCount -eq 0) {
							$this.HandleTestMethodSuccess($testMethod.Name)
						} else {
							$this.HandleTestMethodWarning($testMethod.Name)
						}
					} else {
						$this.HandleTestMethodFailure($testMethod.Name)
					}

					[Log]::EndSection("test method `"$($testMethod.Name)`"")
				}
			}
		
			foreach ($classTeardownMethod in $this.FindMembers($testClass, ([TestClassTeardown]))) {
				try {
					$classTeardownMethod.Invoke($testClassInstance, @())
				} catch {
					[Log]::Error("failed to execute `"$($classTeardownMethod.Name)`" class teardown method of test class `"$($testClass.Name)`"")
					# continue executing other class teardown methods
				}
			}

		} finally {
			[Log]::EndSection("test class `"$($testClass.Name)`"")
			$this.HandleTestClassEnd()
		}
	}

	hidden [Reflection.MemberInfo[]] FindMembers([Reflection.TypeInfo] $testClass, $attributeType) {
		return $testClass.FindMembers(
			([Reflection.MemberTypes]::Method),
			([Reflection.BindingFlags]::Public) -bor ([Reflection.BindingFlags]::Instance),
			{
				param([System.Reflection.MemberInfo] $memberInfo, $at)
				$attrs = $memberInfo.GetCustomAttributes($at, $false)
				return ($attrs.Count -gt 0)
			},
			$attributeType)
	}

	hidden [void] HandleTestClassBegin([string] $testClassName) {
		Write-Host $testClassName
		$this.indentation += 2
	}

	hidden [void] HandleTestClassEnd() {
		$this.indentation -= 2
	}

	hidden [void] HandleTestMethodWarning([string] $testMethodName) {
		Write-Host -ForegroundColor Yellow ((' ' * $this.indentation) + (SpaceWords ($testMethodName, "WARNING") ([console]::WindowWidth - $this.indentation - 1) '.'))
		++$this.warningCount
	}

	hidden [void] HandleTestMethodError([string] $testMethodName) {
		Write-Host -ForegroundColor Red ((' ' * $this.indentation) + (SpaceWords ($testMethodName, "ERROR") ([console]::WindowWidth - $this.indentation - 1) '.'))
		++$this.errorCount
	}

	hidden [void] HandleTestMethodSuccess([string] $testMethodName) {
		Write-Host -ForegroundColor Green ((' ' * $this.indentation) + (SpaceWords ($testMethodName, "SUCCESS") ([console]::WindowWidth - $this.indentation - 1) '.'))
		++$this.successCount
	}

	hidden [void] HandleTestMethodFailure([string] $testMethodName) {
		Write-Host -ForegroundColor Red ((' ' * $this.indentation) + (SpaceWords ($testMethodName, "FAILURE") ([console]::WindowWidth - $this.indentation - 1) '.'))
		++$this.failureCount
	}

	hidden [int] $indentation = 0

	hidden [uint32] $successCount = 0
	hidden [uint32] $failureCount = 0
	hidden [uint32] $errorCount = 0
	hidden [uint32] $warningCount = 0
}

function RunTests($logFilePath <#, TestClasses... #>) {
	$globalTestRunner = Get-Variable -Scope Global -Name 'TestRunner' -ErrorAction Ignore
	if ($globalTestRunner -ne $null) {
		foreach ($arg in $args) { $globalTestRunner.Value.TestClasses.Add($arg) | Out-Null }
	} else {
		$testRunner = [TestRunner]::new($logFilePath)
		foreach ($arg in $args) { $testRunner.TestClasses.Add($arg) | Out-Null }
		$testRunner.RunTests()
	}
}
