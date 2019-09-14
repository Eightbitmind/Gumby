using module SysConfig

function AEulitzPrivateShortcuts() {
	return @{
		"Directories" = @{
			"ToolsGitHub"              = { Set-Location "$HOME/ToolsGitHub" }
			"ToolsGitHub - PS Modules" = { Set-Location "$HOME/ToolsGitHub/WindowsPowerShell/Modules" }
		}
		"Websites" = @{
			"ToolsGitHub"     = { start 'https://github.com/Eightbitmind/tools'}
		}
		"Commands" = @{
			"Swap Mouse Buttons" = { SCSwapMouseButtons }
		}
	}
}