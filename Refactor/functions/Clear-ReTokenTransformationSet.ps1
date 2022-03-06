function Clear-ReTokenTransformationSet {
	<#
	.SYNOPSIS
		Remove all registered transformation sets.
	
	.DESCRIPTION
		Remove all registered transformation sets.
	
	.EXAMPLE
		PS C:\> Clear-ReTokenTransformationSet

		Removes all registered transformation sets.
	#>
	[CmdletBinding()]
	Param (
	
	)
	
	process {
		$script:tokenTransformations = @{ }
	}
}