using module SysConfig

function AEulitzEverywhereShortcuts() {
	return @{
		"Directories" = @{
			"ToolsGitHub"              = { Set-Location "$HOME/ToolsGitHub" }
			"ToolsGitHub - PS Modules" = { Set-Location "$HOME/ToolsGitHub/WindowsPowerShell/Modules" }
			"Start Menu"               = { start "C:\ProgramData\Microsoft\Windows\Start Menu"}
		}
		"Websites" = @{
			"ToolsGitHub"     = { start 'https://github.com/Eightbitmind/tools'}
		}
		"Commands" = @{
			"Swap Mouse Buttons" = { SCSwapMouseButtons }
		}
	}
}