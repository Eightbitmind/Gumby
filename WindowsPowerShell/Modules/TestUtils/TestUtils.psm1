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

function TestIsNotNull($actual, $message = "object is not null") {
	if ($null -ne $actual) {
		[Log]::Success($message)
	} else {
		[Log]::Failure($message)
	}
}

function TestIsType($object, $type) {
	if ($object -is $type) {
		[Log]::Success("object is of type $($type.Name)")
	} else {
		[Log]::Failure("object is of type $($object.GetType()), expected $($type.Name)")
	}
}

function TestAreEqual($actual, $expected, $message = "Test Value") {
	if ($actual -eq $expected) {
		[Log]::Success("value '$actual' matches expectation")
	} else {
		[Log]::Failure("actual '$($actual)', expected '$($expected)'")
	}
}

function TestTuplesAreEqual($actual, $expected, $message = "Test Tuples") {
	$actualEnum = $actual.GetEnumerator()
	$expectedEnum = $expected.GetEnumerator()

	while ($actualEnum.MoveNext()) {
		if (!$expectedEnum.MoveNext()) {
			[Log]::Failure("$($message): more items than expected")
		}

		if ($actualEnum.Current -eq $expectedEnum.Current) {
			[Log]::Success("$($message): found expected item '$($expectedEnum.Current)'")
		} else {
			[Log]::Failure("$($message): actual '$($actualEnum.Current)', expected '$($expectedEnum.Current)'")
		}
	}

	if ($expectedEnum.MoveNext()) {
		[Log]::Failure("$($message): fewer items than expected")
	}

	[Log]::Success("$($message): found expected items")
}

function TestTuplesMatch($actual, $expected, $message = "Test Tuples") {
	$actualEnum = $actual.GetEnumerator()
	$expectedEnum = $expected.GetEnumerator()

	while ($actualEnum.MoveNext()) {
		if (!$expectedEnum.MoveNext()) {
			# Write-Host -ForegroundColor Red "$($message): more items than expected"
			[Log]::Failure("$($message): more items than expected")
		}

		if ($actualEnum.Current -notmatch $expectedEnum.Current) {
			# Write-Host -ForegroundColor Red "$($message): actual '$($actualEnum.Current)', expected '$($expectedEnum.Current)'"
			[Log]::Failure("$($message): actual '$($actualEnum.Current)', expected '$($expectedEnum.Current)'")
		}
	}

	if ($expectedEnum.MoveNext()) {
		# Write-Host -ForegroundColor Red "$($message): fewer items than expected"
		[Log]::Failure("$($message): fewer items than expected")
	}

	# Write-Host -ForegroundColor Green "$($message): found expected items"
	[Log]::Success("$($message): found expected items")
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
