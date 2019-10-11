using module Log
using module Path
using module TreeView
using module Window

[bool] $debug = $true

$tree =
@{
	Name = "A1"
	Children =
		@{
			Name = "B1"
			Children =
				@{
					Name = "C1"
					Children =
					@{
						Name = "D1"
						Children =
							@{
								Name = "E1"
							},
							@{
								Name = "E2"
							}
					},
					@{
						Name = "D2"
						Children =
							@{
								Name = "E3"
							},
							@{
								Name = "E4"
							}
					}
				},
				@{
					Name = "C2"
					Children =
					@{
						Name = "D3"
						Children =
							@{
								Name = "E5"
							},
							@{
								Name = "E6"
							}
					},
					@{
						Name = "D4"
						Children =
							@{
								Name = "E7"
							},
							@{
								Name = "E8"
							}
					}
				}
		},
		@{
			Name = "B2"
			Children =
				@{
					Name = "C3"
					Children =
					@{
						Name = "D5"
						Children =
							@{
								Name = "E9"
							},
							@{
								Name = "E10"
							}
					},
					@{
						Name = "D6"
						Children =
							@{
								Name = "E11"
							},
							@{
								Name = "E12"
							}
					}
				},
				@{
					Name = "C4"
					Children =
					@{
						Name = "D7"
						Children =
							@{
								Name = "E13"
							},
							@{
								Name = "E14"
							}
					},
					@{
						Name = "D8"
						Children =
							@{
								Name = "E15"
							},
							@{
								Name = "E16"
							}
					}
				}
		},
		@{
			Name = "B3"
			Children =
				@{
					Name = "C5"
					Children =
					@{
						Name = "D9"
						Children =
							@{
								Name = "E17"
							},
							@{
								Name = "E18"
							}
					},
					@{
						Name = "D10"
						Children =
							@{
								Name = "E19"
							},
							@{
								Name = "E20"
							}
					}
				},
				@{
					Name = "C6"
					Children =
					@{
						Name = "D11"
						Children =
							@{
								Name = "E21"
							},
							@{
								Name = "E22"
							}
					},
					@{
						Name = "D12"
						Children =
							@{
								Name = "E23"
							},
							@{
								Name = "E24"
							}
					}
				}
		}
}

function SelectSimpleData($data) {
	$fll = $null
	if ($debug) {
		$logFileName = "$env:TEMP\$(PathFileBaseName $PSCommandPath).log"
		if (Test-Path $logFileName) { Remove-Item $logFileName }
		$fll = [FileLogListener]::new($logFileName)
		[Log]::Listeners.Add($fll) | Out-Null
	}

	$horizontalPercent = 0.8
	$verticalPercent = 0.5

	$width = [console]::WindowWidth * $horizontalPercent
	$left = [int](([console]::WindowWidth - $width) / 2)

	$height = [console]::WindowHeight * $verticalPercent
	$top = [int](([console]::WindowHeight - $height) / 2)

	$tv = [SVTreeView]::new($data, ([SimpleObjectTVItem]), $left, $top, $width, $height, ([console]::BackgroundColor), ([console]::ForegroundColor))
	$tv.Title = 'Select Data'

	if ($tv.Run() -eq [WindowResult]::OK -and ($tv.SelectedIndex() -lt $tv.ItemCount())) {
		Write-Host $tv.SelectedItem().Name()
	}

	if ($fll -ne $null) { [Log]::Listeners.Remove($fll) }
}

SelectSimpleData $tree