using module Gumby.Log
using module Gumby.String

#region Expectations

# An expectation can be seen as a function with two parameters
#     function IsMatch($expected, $actual)
# which has been curried into a function with one parameter
#     function IsMatch($actual)
# by capturing the argument for the $expected parameter. Expectation trees - built, for instance,
# via the constructor arguments of the And and Or expectations - allow for the validation of
# complex test conditions. For instance, the expectation tree
#     (And (ListContains 'a') (Not (ListContains 'b')))
# checks that an actual list data structure contains an element 'a', but no element 'b'. The
# IsMatch function below treats native PowerShell values and objects as expectations. For instance,
# the integer 1 is treated as an expectation checking that an actual value equals 1; the array
# @(1, 2, 3) is treated as an expectation checking that an actual object yields the values 1, 2 and
# 3 when iterated; the object @{Name = "Joe"; Age = 33} checks that an actual object has a
# member "Name" with the value "Joe" and a member "Age" with the value 33.

class ExpectationBase {
	[bool] IsMatch($actual, $messagePrefix) {
		throw "derived classes must implement this method"
	}
}

class CustomExpectation : ExpectationBase {
	CustomExpectation($name, $predicate) {
		$this.name = $name
		$this.predicate = $predicate
	}

	[bool] IsMatch($actual, $messagePrefix) {
		if ($this.predicate.Invoke($actual)) {
			[Log]::Success("$($messagePrefix)`"$($this.name)`" expectation matches")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)`"$($this.name)`" expectation does not match")
			return $false
		}
	}

	hidden [string] $name
	hidden [scriptblock] $predicate
}

function Expect($name, $expected) { [CustomExpectation]::new($name, $expected) }

<#
This expectation could be encoded in many other ways, e.g.
	(ExpectNot $null)
It is nevertheless useful because it provides clearer logging.
#>
class NotNullExpectation : ExpectationBase {
	[bool] IsMatch($actual, $messagePrefix) {
		if ($actual -ne $null) {
			[Log]::Success("$($messagePrefix)object '$actual' is not null")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)object is null")
			return $false
		}
	}
}

function ExpectNotNull { [NotNullExpectation]::new() }

class RegexExpectation : ExpectationBase {
	RegexExpectation($expectedPattern) { $this.expectedPattern = $expectedPattern }

	[bool] IsMatch($actual, $messagePrefix) {
		if ($actual -match $this.expectedPattern) {
			[Log]::Success("$($messagePrefix)`"$actual`" matches pattern `"$($this.pattern)`"")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)`"$actual`" does not match pattern `"$($this.pattern)`"")
			return $false
		}
	}

	hidden [string] $expectedPattern
}

function ExpectRegex($pattern) { [RegexExpectation]::new($pattern) }

class TypeExpectation : ExpectationBase {
	TypeExpectation($expectedType) { $this.expectedType = $expectedType }

	[bool] IsMatch($actual, $messagePrefix) {
		if ($actual -is $this.expectedType) {
			[Log]::Success("$($messagePrefix)object is of expected type $($this.expectedType.Name)")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)object is of type $($actual.GetType()), expected $($this.expectedType.Name)")
			return $false
		}
	}

	hidden [System.Reflection.TypeInfo] $expectedType
}

function ExpectType($type) { [TypeExpectation]::new($type) }

class KeyCountEqualExpectation : ExpectationBase {

	KeyCountEqualExpectation($expectedKeyCount) { $this.expectedKeyCount = $expectedKeyCount }

	[bool] IsMatch($actual, $messagePrefix) {
		if ($actual.Keys.Count -eq $this.expectedKeyCount) {
			[Log]::Success("$($messagePrefix)object key count $($this.expectedKeyCount) as expected")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)actual object key count $($actual.Keys.Count), expected $($this.expectedKeyCount)")
			return $false
		}
	}

	hidden [uint32] $expectedKeyCount
}

function ExpectKeyCountEqual($count) { [KeyCountEqualExpectation]::new($count) }

#region List Expectations

class ContainsExpectation : ExpectationBase {
	ContainsExpectation($expectedItem) { $this.expectedItem = $expectedItem }

	[bool] IsMatch($actualItems, $messagePrefix) {

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
				if (IsMatch $this.expectedItem $actualItem "$($messagePrefix)item $(($actualItemIndex++)): ") {
					[Log]::Failure("$($messagePrefix)found expected item '$($this.expectedItem)'")
					return $true
				}
			}

		} finally {
			$logInterceptor.Dispose()
		}

		[Log]::Failure("$($messagePrefix)missing item '$($this.expectedItem)'")
		return $false
	}

	hidden $expectedItem
}

function ExpectContains($item) { [ContainsExpectation]::new($item) }

class CountGreaterOrEqualExpectation : ExpectationBase {
	CountGreaterOrEqualExpectation($expectedCount) {
		$this.expectedCount = $expectedCount
	}

	[bool] IsMatch($actual, $messagePrefix) {
		$actualCount = $actual.Count
		if ($actualCount -ge $this.expectedCount) {
			[Log]::Success("$($messagePrefix)item count $($this.expectedCount) is greater or equal to $actualCount")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)item count $($this.expectedCount) is less than $actualCount")
			return $false
		}
	}

	hidden $expectedCount
}

function ExpectCountGreaterOrEqual($count) { [CountGreaterOrEqualExpectation]::new($count) }

# Future: ExpectCountEquals, ExpectEachItem (iterates over the items in the actual data structure,
# passing each into child expectations)

#endregion

#region Boolean Expectations

class NotExpectation : ExpectationBase {
	NotExpectation($expected) { $this.expected = $expected }

	[bool] IsMatch($actual, $messagePrefix) {
		$logInterceptor = [LogInterceptor]::new({ param ($interceptor, $messageType, $message)
			switch ($messageType) {
				([LogMessageType]::Failure) { $messageType = ([LogMessageType]::Success)}
				([LogMessageType]::Success) { $messageType = ([LogMessageType]::Failure)}
			}
			$interceptor.DispatchMessage($messageType, $message)
		})
		try {
			return !(IsMatch $this.expected $actual "$($messagePrefix)NOT: ")
		} finally {
			$logInterceptor.Dispose()
		}
	}

	hidden $expected
}

function ExpectNot($operand) { [NotExpectation]::new($operand) }

class AndExpectation : ExpectationBase {
	AndExpectation($expected) { $this.expected  = $expected }

	[bool] IsMatch($actual, $messagePrefix) {
		foreach ($expectedTerm in $this.expected) {
			if (!(IsMatch $expectedTerm $actual "$($messagePrefix)AND: ")) {
				[Log]::Failure("$($messagePrefix)AND evaluates to false")
				return $false
			}
		}
		[Log]::Success("$($messagePrefix)AND evaluates to true")
		return $true
	}

	hidden $expected
}

function ExpectAnd { [AndExpectation]::new($args) }

class OrExpectation : ExpectationBase {
	OrExpectation($expected) { $this.expected  = $expected }

	[bool] IsMatch($actual, $messagePrefix) {
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
				if (IsMatch $expectedTerm $actual "$($messagePrefix)OR: ") {
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

function ExpectOr { [OrExpectation]::new($args) }

#endregion

#endregion

function IsMatch($expected, $actual, $messagePrefix) {

	function AreValuesEqual($expected, $actual, $messagePrefix) {
		if ($null -eq $expected) {

			if ($null -eq $actual) {
				[Log]::Success("$($messagePrefix)value is null")
				return $true
			} else {
				[Log]::Failure("$($messagePrefix)value is not null")
				return $false
			}
	
		} elseif ($actual -eq $expected) {
			[Log]::Success("$($messagePrefix)value '$actual' matches expectation")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)actual '$($actual)', expected '$($expected)'")
			return $false
		}
	}

	if ($expected -is [ExpectationBase]) {
		return $expected.IsMatch($actual, $messagePrefix)
	} elseif (
		($null -eq $expected) -or 
		($expected -is [bool]) -or 
		($expected -is [int]) -or 
		$expected.GetType().IsEnum -or
		($expected -is [string])) {
		return (AreValuesEqual $expected $actual $messagePrefix)
	} elseif ($expected -is [double]) {
		$delta = [Math]::Abs($expected - $actual)
		if ($delta -le 0.000000000001) {
			[Log]::Success("$($messagePrefix)value $actual is close to $expected")
			return $true
		} else {
			[Log]::Failure("$($messagePrefix)actual $actual differs by $delta from expected $expected")
			return $false
		}
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

			$result = $result -and (IsMatch $expectedEnum.Current $actualEnum.Current "$($messagePrefix)item $(($itemIndex++)): ")
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
			$result = $result -and (IsMatch $expectedValue $actualValue "$($messagePrefix)member '$key': ")
		}
		return $result
	}
	else {
		# Assuming that everything is an object (see last elseif condition), will this code ever be reached?
		throw "unexpected type $($expected.GetType())"
	}
}

# The way our test executor works, we do not need the return value suppression provided by this
# function. At this point, this function is merely syntactic sugar.
function Test($Expected, $Actual, $MessagePrefix) {
	[void](IsMatch $Expected $Actual $MessagePrefix)
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
	$testRunner = [TestRunner]::new($logFilePath)
	foreach ($arg in $args) { [void]($testRunner.TestClasses.Add($arg)) }
	$testRunner.RunTests()
}
