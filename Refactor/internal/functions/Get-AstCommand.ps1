function Get-AstCommand {
	<#
	.SYNOPSIS
		Parses out all commands contained in an AST.
	
	.DESCRIPTION
		Parses out all commands contained in an Abstract Syntax Tree.
		Will also resolve all parameters used as able and indicate, whether all could be identified.
	
	.PARAMETER Ast
		The Ast object to scan.
	
	.PARAMETER Splat
		Splat Data to use for parameter mapping
	
	.EXAMPLE
		PS C:\> Get-AstCommand -Ast $parsed.Ast -Splat $splats

		Returns all commands in the specified AST, mapping to the splats contained in $splats
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.Language.Ast]
		$Ast,

		[AllowNull()]
		$Splat
	)
	
	process {
		$splatHash = @{ }
		foreach ($splatItem in $Splat) { $splatHash[$splatItem.Ast] = $splatItem }

		$allCommands = Search-ReAst -Ast $Ast -Filter {
			$args[0] -is [System.Management.Automation.Language.CommandAst]
		}

		foreach ($command in $allCommands) {
			$result = [Refactor.CommandToken]::new($command.Data)

			# Splats
			foreach ($splatted in $command.Data.CommandElements | Where-Object Splatted) {
				$result.HasSplat = $true
				$splatItem = $splatHash[$splatted]
				if (-not $splatItem.ParametersKnown) {
					$result.ParametersKnown = $false
				}
				foreach ($parameterName in $splatItem.Parameters.Keys) {
					$result.parameters[$parameterName] = $parameterName
				}
				$result.Splats[$splatted] = $splatItem
			}

			$result
		}
	}
}