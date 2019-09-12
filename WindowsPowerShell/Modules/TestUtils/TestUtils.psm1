using module Log

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

class TestMethodLogger : LogListenerBase {
	[void] ProcessMessage([LogMessageType] $messageType, [string] $message) {
		switch($messageType) {
			([LogMessageType]::BeginSection) {
				Write-Host $message
				$this.indentation += 2
			}
			([LogMessageType]::EndSection) {
				$this.indentation -= 2
			}
			([LogMessageType]::Warning) {
				Write-Host -ForegroundColor Yellow ((' ' * $this.indentation) + $this.SpaceWords(($message, "WARNING"), [console]::WindowWidth - $this.indentation - 1, '.'))
			}
			([LogMessageType]::Error) {
				Write-Host -ForegroundColor Red ((' ' * $this.indentation) + $this.SpaceWords(($message, "ERROR"), [console]::WindowWidth - $this.indentation - 1, '.'))
			}
			([LogMessageType]::Success) {
				Write-Host -ForegroundColor Green ((' ' * $this.indentation) + $this.SpaceWords(($message, "SUCCESS"), [console]::WindowWidth - $this.indentation - 1, '.'))
			}
			([LogMessageType]::Failure) {
				Write-Host -ForegroundColor Red ((' ' * $this.indentation) + $this.SpaceWords(($message, "FAILURE"), [console]::WindowWidth - $this.indentation - 1, '.'))
			}
		}
	}

	hidden [string] SpaceWords([string[]] $Words, [int] $Width, [string] $SpacingChar = ' ') {
		# The code below is a sketch that only works correctly for 2 words. A proper version needs
		# to provide heterogenous spacing lengths according to the integer divisibility of the
		# total spacing length.

		assert ($Words.Count -ge 2)
		assert ($SpacingChar.Length -eq 1)

		$totalSpacingLength = $Width
		foreach ($word in $Words) { $totalSpacingLength -= $word.Length }

		assert ($totalSpacingLength -ge 0)

		$spacingLength = $totalSpacingLength / ($Words.Count - 1)

		$sb = [Text.StringBuilder]::new($Width)
		for ($i = 0; $i -lt $Words.Count; ++$i) {
			$sb.Append($Words[$i])
			if ($i -lt $Words.Count - 1) { $sb.Append($SpacingChar * $spacingLength) }
		}

		return $sb.ToString()
	}

	hidden [int] $indentation = 0
}

class TestRunner {

	[Collections.ArrayList] $TestClasses = [Collections.ArrayList]::new()
	[LogListenerBase] $TestMethodLogger = [TestMethodLogger]::new()
	[FileLogListener] hidden $fileLogListener

	TestRunner([string] $logFilePath = "$env:TEMP\Test.log") {
		if (Test-Path $logFilePath) { Remove-Item $logFilePath }
		$this.fileLogListener = [FileLogListener]::new($logFilePath)
	}

	[void] RunTests() {
		[Log]::Listeners.Add($this.fileLogListener) | Out-Null
		foreach ($testClass in $this.TestClasses) { $this.RunTestClass($testClass) }
		[Log]::Listeners.Remove($this.fileLogListener)
	}

	hidden [void] RunTestClass($testClass) {

		try {
			$testClassInstance = $testClass::new()
		} catch {
			[Log]::Error("failed to instantiate test class `"$($testClass.Name)`"")
			return
		}

		$this.TestMethodLogger.ProcessMessage(([LogMessageType]::BeginSection), $testClass.Name)
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
						$this.TestMethodLogger.ProcessMessage(([LogMessageType]::Error), $testMethod.Name)
					} elseif($testMethodStats.ErrorCount -gt 0) {
						$this.TestMethodLogger.ProcessMessage(([LogMessageType]::Error), $testMethod.Name)
					} elseif (($testMethodStats.FailureCount -eq 0) -and ($testMethodStats.SuccessCount -gt 0)) {
						if ($testMethodStats.WarningCount -eq 0) {
							$this.TestMethodLogger.ProcessMessage(([LogMessageType]::Success), $testMethod.Name)
						} else {
							$this.TestMethodLogger.ProcessMessage(([LogMessageType]::Warning), $testMethod.Name)
						}
					} else {
						$this.TestMethodLogger.ProcessMessage(([LogMessageType]::Failure), $testMethod.Name)
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
			$this.TestMethodLogger.ProcessMessage(([LogMessageType]::EndSection), $testClass.Name)
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
