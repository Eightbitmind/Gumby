using module Gumby.Test

param([ValidateSet("ExportTests", "RunTests")] $Mode = "RunTests")

Import-Module "$PSScriptRoot/Conversion.psm1"

[TestClass()]
class MathModuleTests {

	#region Length

	[TestMethod()]
	[void] ConvertFeetToMeters_0() {
		Test 0.0 (Convert-FeetToMeters 0)
	}
	[TestMethod()]
	[void] ConvertFeetToMeters_1() {
		Test 0.3048 (Convert-FeetToMeters 1)
	}
	[TestMethod()]
	[void] ConvertFeetToMeters_m1() {
		Test (-0.3048) (Convert-FeetToMeters -1)
	}

	[TestMethod()]
	[void] ConvertInchesToMeters_0() {
		Test 0.0 (Convert-InchesToMeters 0)
	}

	[TestMethod()]
	[void] ConvertInchesToMeters_1() {
		Test 0.0254 (Convert-InchesToMeters 1)
	}

	[TestMethod()]
	[void] ConvertInchesToMeters_m1() {
		Test (-0.0254) (Convert-InchesToMeters -1)
	}

	[TestMethod()]
	[void] ConvertMetersToFeet_0() {
		Test 0.0 (Convert-MetersToFeet 0)
	}

	[TestMethod()]
	[void] ConvertMetersToFeet_1() {
		Test 3.28083989501312 (Convert-MetersToFeet 1)
	}

	[TestMethod()]
	[void] ConvertMetersToFeet_m1() {
		Test (-3.28083989501312) (Convert-MetersToFeet -1)
	}
	[TestMethod()]
	[void] ConvertMetersToFeetInchesFrac_0p37465() {
		Test "1' 2 12/16`"" (Convert-MetersToFeetInchesFrac 0.37465)
	}
	#endregion

	#region Temperature

	[TestMethod()]
	[void] ConvertCelsiusToFahrenheit_0() {
		Test 32.0 (Convert-CelsiusToFahrenheit 0)
	}

	[TestMethod()]
	[void] ConvertCelsiusToFahrenheit_100() {
		Test 212.0 (Convert-CelsiusToFahrenheit 100)
	}

	[TestMethod()]
	[void] ConvertCelsiusToFahrenheit_m100() {
		Test (-148.0) (Convert-CelsiusToFahrenheit -100)
	}

	[TestMethod()]
	[void] ConvertFahrenheitToCelsius_0() {
		Test (-17.7777777777778) (Convert-FahrenheitToCelsius 0)
	}

	[TestMethod()]
	[void] ConvertFahrenheitToCelsius_100() {
		Test 37.7777777777778 (Convert-FahrenheitToCelsius 100)
	}

	[TestMethod()]
	[void] ConvertFahrenheitToCelsius_m100() {
		Test (-73.3333333333333) (Convert-FahrenheitToCelsius -100)
	}
	#endregion
}

$tests = ([MathModuleTests])
switch ($Mode) {
	"ExportTests" { $tests }
	"RunTests" { RunTests "$env:TEMP\ConversionTests.log" @tests }
}
