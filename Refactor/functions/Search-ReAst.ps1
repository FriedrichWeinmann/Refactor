function Search-ReAst {
	<#
	.SYNOPSIS
		Tool to search the Abstract Syntax Tree
	
	.DESCRIPTION
		Tool to search the Abstract Syntax Tree
	
	.PARAMETER Ast
		The Ast to search
	
	.PARAMETER Filter
		The filter condition to apply
	
	.EXAMPLE
		PS C:\> Search-ReAst -Ast $ast -Filter { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }

		Searches for all function definitions
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.Language.Ast]
		$Ast,

		[Parameter(Mandatory = $true)]
		[ScriptBlock]
		$Filter
	)

	process {
		$results = $Ast.FindAll($Filter, $true)
	
		foreach ($result in $results) {
			[PSCustomObject]@{
				PSTypeName = 'Ast.SearchResult'
				Start = $result.Extent.StartLineNumber
				End   = $result.Extent.EndLineNumber
				File  = $Ast.Extent.File
				Data  = $result
				Type = $result.GetType().Name
			}
		}
	}
}