function Get-ReTokenTransformationSet {
	<#
	.SYNOPSIS
		List the registered transformation sets.
	
	.DESCRIPTION
		List the registered transformation sets.
	
	.PARAMETER Type
		The type of token to filter by.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-ReTokenTransformationSet
		
		Return all registerd transformation sets.
	#>
	[CmdletBinding()]
	param (
		[string]
		$Type = '*'
	)

	process {
		foreach ($pair in $script:tokenTransformations.GetEnumerator()) {
			if ($pair.Key -notlike $Type) { continue }
			$pair.Value.Values
		}
	}
}