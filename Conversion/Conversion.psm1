function Convert-ToNearestFrac([double] $Number, [int] $Denominator) {
	# (8.25, 16) => 8 4/16
	# TODO: shorten the fraction
	[int] $whole = [Math]::Floor($Number)
	[int] $nominator = [Math]::Round(($Number - $whole) * $Denominator)
	Write-Output "$whole $nominator/$Denominator"
}

#region Length

function Convert-InchesToMeters([double] $Inches, [int] $Precision = -1, [switch] $IncludeUnit) {

	[double] $meters = $Inches * 0.0254

	if ($Precision -ge 0) {
		$meters = [Math]::Round($meters, $Precision)
	}

	if ($IncludeUnit) {
		return "$meters m" # return value is a string
	} else {
		return $meters # return value is a double
	}

}

function Convert-MetersToInches([double] $Meters, [int] $Precision = -1, [switch] $IncludeUnit) {

	[double] $inches = $Meters / 0.0254

	if ($Precision -ge 0) {
		$inches = [Math]::Round($inches, $Precision)
	}

	if ($IncludeUnit) {
		return "$inches `"" # return value is a string
	} else {
		return $inches # return value is a double
	}
}

function Convert-FeetToMeters([double] $Feet, [int] $Precision = -1, [switch] $IncludeUnit) {

	[double] $meters = $Feet * 0.3048

	if ($Precision -ge 0) {
		$meters = [Math]::Round($meters, $Precision)
	}

	if ($IncludeUnit) {
		return "$meters m" # return value is a string
	} else {
		return $meters # return value is a double
	}

}

function Convert-MetersToFeet([double] $Meters, [int] $Precision = -1, [switch] $IncludeUnit) {

	[double] $feet = $Meters / 0.3048

	if ($Precision -ge 0) {
		$feet = [Math]::Round($feet, $Precision)
	}

	if ($IncludeUnit) {
		return "$feet '" # return value is a string
	} else {
		return $feet # return value is a double
	}
}

function Convert-MetersToFeetInchesFrac([double] $Meters, [int] $Denominator = 16) {
	[int] $feet = [Math]::Floor((Convert-MetersToFeet $Meters))
	[double] $remainder = $Meters - (Convert-FeetToMeters $feet)

	$inches = Convert-ToNearestFrac (Convert-MetersToInches $remainder) $Denominator
	Write-Output "$feet' $inches`""
}

#endregion

#region Temperature
function Convert-CelsiusToFahrenheit([double] $Celsius, [int] $Precision = -1, [switch] $IncludeUnit) {
	[double] $fahrenheit = $Celsius * 9/5 + 32

	if ($Precision -ge 0) {
		$fahrenheit = [Math]::Round($fahrenheit, $Precision)
	}

	if ($IncludeUnit) {
		return "$fahrenheit $([char]0x00B0)F" # return value is a string
	} else {
		return $fahrenheit # return value is a double
	}
}

function Convert-FahrenheitToCelsius ([double] $Fahrenheit, [int] $Precision = -1, [switch] $IncludeUnit) {
	[double] $celsius = ($Fahrenheit - 32) * 5/9

	if ($Precision -ge 0) {
		$celsius = [Math]::Round($celsius, $Precision)
	}

	if ($IncludeUnit) {
		return "$celsius $([char]0x00B0)C" # return value is a string
	} else {
		return $celsius # return value is a double
	}
}

#endregion
