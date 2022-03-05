function Get-ReTokenProvider {
	<#
	.SYNOPSIS
		List registered token providers.
	
	.DESCRIPTION
		List registered token providers.

		Token providers are scriptblocks that will parse an Abstract Syntax Tree, searching for specific types of code content.
		These can then be used for code analysis or refactoring.
	
	.PARAMETER Name
		Name of the provider to filter by.
		Defaults to "*"
	
	.PARAMETER Component
		Return only the specified component:
		+ All: Return the entire provider
		+ Tokenizer: Return only the scriptblock, that parses out the Ast
		+ Converter: Return only the scriptblock, that applies transforms to tokens
		Default: All
	
	.EXAMPLE
		PS C:\> Get-ReTokenProvider

		List all token providers
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = '*',

		[ValidateSet('All','Tokenizer','Converter')]
		[string]
		$Component = 'All'
	)
	
	process {
		foreach ($provider in $script:tokenProviders.GetEnumerator()) {
			if ($provider.Key -notlike $Name) { continue }
			if ($Component -eq 'Tokenizer') {
				$provider.Value.Tokenizer
				continue
			}
			if ($Component -eq 'Converter') {
				$provider.Value.Converter
				continue
			}

			$provider.Value
		}
	}
}