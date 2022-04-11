function Get-ReBreakingChange {
	<#
	.SYNOPSIS
		Searches for a breaking change configuration entry that has previously registered.
	
	.DESCRIPTION
		Searches for a breaking change configuration entry that has previously registered.
	
	.PARAMETER Module
		The module to search by.
		Defaults to '*'
	
	.PARAMETER Version
		The version of the module to search for.
		By default, changes for all versions are returned.
	
	.PARAMETER Command
		The affected command to search for.
		Defaults to '*'
	
	.PARAMETER Tags
		Only include changes that contain at least one of the listed tags.
	
	.EXAMPLE
		PS C:\> Get-ReBreakingChange

		Returns all registered breaking change configuration entries.
	#>
	[CmdletBinding()]
	param (
		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$Module = '*',

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Version]
		$Version,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$Command = '*',

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[AllowEmptyCollection()]
		[string[]]
		$Tags
	)

	process {
		$script:breakingChanges.Values.Values | Write-Output | Where-Object {
			if ($_.Module -notlike $Module) { return }
			if ($_.Command -notlike $Command) { return }
			if ($Version -and $_.Version -ne $Version) { return }
			if ($Tags -and -not ($_.Tags | Where-Object { $_ -in $Tags })) { return }
			$true
		}
	}
}