function Register-ReBreakingChange {
	<#
	.SYNOPSIS
		Register a breaking change.
	
	.DESCRIPTION
		Register a breaking change.
		A breaking change is a definition of a command or its parameters that were broken at a given version of the module.
		This can include tags to classify the breaking change.
	
	.PARAMETER Module
		The name of the module the breaking change occured in.
	
	.PARAMETER Version
		The version of the module in which the breaking change was applied.
	
	.PARAMETER Command
		The command that was changed in a breaking manner.
	
	.PARAMETER Description
		A description to show when reporting the command itself as being broken.
		This is the message shown in the report when finding this breaking change, so make sure it contains actionable information for the user.
	
	.PARAMETER Parameters
		A hashtable containing parameters that were broken, maping parametername to a description of what was changed.
		That description will be shown to the user, so make sure it contains actionable information.
		Defining parameters will cause the command to only generate scan results when the parameter is being used or the total parameters cannot be determined.
		It is possible to assign multiple breaking changes to the same command - one for the command and one for parameters.
	
	.PARAMETER Tags
		Any tags to assign to the breaking change.
		Breaking Change scans can be filtered by tags.
	
	.EXAMPLE
		PS C:\> Register-ReBreakingChange -Module MyModule -Version 2.0.0 -Command Get-Something -Description 'Redesigned command'

		Adds a breaking change for the Get-Something command in the module MyModule at version 2.0.0
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Module,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Version]
		$Version,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Command,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string]
		$Description,

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[Hashtable]
		$Parameters = @{ },

		[Parameter(ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Tags = @()
	)

	process {
		if (-not $script:breakingChanges[$Module]) {
			$script:breakingChanges[$Module] = @{ }
		}

		if (-not $script:breakingChanges[$Module][$Version]) {
			$script:breakingChanges[$Module][$Version] = [System.Collections.Generic.List[object]]::new()
		}

		$object = [PSCustomObject]@{
			Module      = $Module
			Version     = $Version
			Command     = $Command
			Description = $Description
			Parameters  = $Parameters
			Tags        = $Tags
		}

		$script:breakingChanges[$Module][$Version].Add($object)
	}
}