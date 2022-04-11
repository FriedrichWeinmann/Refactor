function Clear-ReBreakingChange {
	<#
	.SYNOPSIS
		Removes entire datasets of entries from the list of registered breaking changes.
	
	.DESCRIPTION
		Removes entire datasets of entries from the list of registered breaking changes.
	
	.PARAMETER Module
		The module to unregister.
	
	.PARAMETER Version
		The version of the module to unregister.
		If not specified, ALL versions are unregistered.
	
	.EXAMPLE
		PS C:\> Clear-ReBreakingChange -Module MyModule
		
		Removes all breaking changes of all versions of "MyModule" from the in-memory configuration set.
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Module,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Version]
		$Version
	)

	process {
		if (-not $script:breakingChanges[$Module]) { return }
		if (-not $Version) {
			$script:breakingChanges.Remove($Module)
			return
		}
		$script:breakingChanges[$Module].Remove($Version)
		if ($script:breakingChanges[$Module].Count -lt 1) {
			$script:breakingChanges.Remove($Module)
		}
	}
}