function Find-BreakingChange {
	<#
	.SYNOPSIS
		Search a given AST for any breaking change contained.
	
	.DESCRIPTION
		Search a given AST for any breaking change contained.

		Use Import-ReBreakingChange to load definitions of breaking changes to look for.
	
	.PARAMETER Ast
		The AST to search
	
	.PARAMETER Name
		The name of the file being searched.
		Use this to identify non-filesystem code.
	
	.PARAMETER Changes
		The breaking changes to look out for.
	
	.EXAMPLE
		PS C:\> Find-BreakingChange -Ast $ast -Changes $changes

		Find all instances of breaking changes found within $ast.
	#>
	[OutputType([Refactor.BreakingChange])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.Language.Ast]
		$Ast,

		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[hashtable]
		$Changes
	)

	if (-not $Name) { $Name = $Ast.Extent.File }
	$filePath = $Name
	$fileName = ($Name -split "\\|/")[-1]

	$commands = Read-ReScriptCommand -Ast $Ast
	foreach ($commandToken in $commands) {
		foreach ($change in $Changes[$commandToken.Name]) {
			if ($change.Parameters.Count -lt 1) {
				[Refactor.BreakingChange]@{
					Path        = $filePath
					Name        = $fileName
					Line        = $commandToken.Line
					Command     = $commandToken.Name
					Type        = 'Error'
					Description = $change.Description
					Module      = $change.Module
					Version     = $change.Version
					Tags        = $change.Tags
				}
				continue
			}

			foreach ($parameter in $change.Parameters.Keys) {
				if ($commandToken.Parameters.Keys -contains $parameter) {
					[Refactor.BreakingChange]@{
						Path        = $filePath
						Name        = $fileName
						Line        = $commandToken.Line
						Command     = $commandToken.Name
						Parameter   = $parameter
						Type        = 'Error'
						Description = $change.Parameters.$parameter
						Module      = $change.Module
						Version     = $change.Version
						Tags        = $change.Tags
					}
					continue
				}

				if ($commandToken.ParametersKnown) { continue }

				[Refactor.BreakingChange]@{
					Path        = $filePath
					Name        = $fileName
					Line        = $commandToken.Line
					Command     = $commandToken.Name
					Parameter   = $parameter
					Type        = 'Warning'
					Description = "Not all parameters on command resolveable - might be in use. $($change.Parameters.$parameter)"
					Module      = $change.Module
					Version     = $change.Version
					Tags        = $change.Tags
				}
			}
		}
	}
}