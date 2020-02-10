using module Gumby.Path

function GitGetRepoName($defaultRepoName = "<unknown-repo>")
{
	$repoName = $defaultRepoName

	try
	{
		$cmdOut = git remote -v
		# It seems the $Matches variable is not available in the 'prompt' context.
		# The 'Multiline' does not appear to cause '^' and '$' to match the start and end of a line, resp. Perhaps
		# the output of the 'git branch' uses unexpected line breaks.

		$match = [regex]::Match($cmdOut, '/([^/]+)\s+\(fetch\)', ([System.Text.RegularExpressions.RegexOptions]::Multiline))
		if ($match.Success)
		{
			$repoName = $match.Groups[1].Value
		}
	}
	catch
	{
	}

	return $repoName
}

function GitGetBranchName($defaultBranchName = "<unknown-branch>")
{
	$branchName = $defaultBranchName

	try
	{
		$cmdOut = git branch
		# It seems the $Matches variable is not available in the 'prompt' context.
		# The 'Multiline' does not appear to cause '^' and '$' to match the start and end of a line, resp. Perhaps
		# the output of the 'git branch' uses unexpected line breaks.

		$match = [regex]::Match($cmdOut, '\*\s+([\w_-]*)', ([System.Text.RegularExpressions.RegexOptions]::Multiline))
		if ($match.Success)
		{
			$branchName = $match.Groups[1].Value
		}
	}
	catch
	{
	}

	return $branchName
}

function GitGetRepoRootDir($folder)
{
	[System.IO.DirectoryInfo] $currentDir = Get-Item $folder
	while ($currentDir)
	{
		if (Test-Path (Join-Path $currentDir.FullName ".git")) { return $currentDir }
		$currentDir = $currentDir.Parent
	}
	return $null
}

function GitCreateCachedRepoNameGetter([string] $rootDir, $defaultRepoName = "<unknown-repo>")
{
	$repoName = GitGetRepoName
	return {
		if (!$rootDir -or !(Get-Location).Path.StartsWith($rootDir))
		{
			Set-Variable -Name rootDir -Value (GitGetRepoRootDir (Get-Location)) -Scope 1
			if ($rootDir)
			{
				Set-Variable -Name repoName -Value (GitGetRepoName) -Scope 1
			}
			else
			{
				Set-Variable -Name repoName -Value $defaultRepoName -Scope 1
			}
		}

		return $repoName
	}.GetNewClosure()
}
