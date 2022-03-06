function Register-ReTokenTransformation {
	<#
	.SYNOPSIS
		Register a transformation rule used when refactoring scripts.
	
	.DESCRIPTION
		Register a transformation rule used when refactoring scripts.
		Rules are specific to their token type.
		Different types require different parameters, which are added via dynamic parameters.
		For more details, look up the documentation for the specific token type you want to register a transformation for.
	
	.PARAMETER Type
		The type of token to register a transformation over.
	
	.EXAMPLE
		PS C:\> Register-ReTokenTransformation -Type Command -Name Get-AzureADUser -NewName Get-MGUser -Comment "The filter parameter requires manual adjustments if used"

		Registers a transformation rule, that will convert the Get-AzureADUser command to Get-MGUser
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Type
	)

	DynamicParam {
		$parameters = (Get-ReTokenProvider -Name $Type).TransformParameters
		if (-not $parameters) { return }

		$results = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary
		foreach ($parameter in $parameters) {
			$parameterAttribute = New-Object System.Management.Automation.ParameterAttribute
			$parameterAttribute.ParameterSetName = '__AllParameterSets'
			$attributesCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
			$attributesCollection.Add($parameterAttribute)
			$RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter($parameter, [object], $attributesCollection)

			$results.Add($parameter, $RuntimeParam)
		}

		$results
	}
	
	begin {
		$commonParam = 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable'
	}
	process {
		$provider = Get-ReTokenProvider -Name $Type
		if (-not $provider) {
			Stop-PSFFunction -Message "No provider found for type $Type" -Target $PSBoundParameters -EnableException $true -Cmdlet $PSCmdlet
		}

		$hash = $PSBoundParameters | ConvertTo-PSFHashtable -Exclude $commonParam
		$missingMandatory = $provider.TransformParametersMandatory | Where-Object { $_ -notin $hash.Keys }
		if ($missingMandatory) {
			Stop-PSFFunction -Message "Error defining a $($Type) transformation: $($provider.TransformParametersMandatory -join ",") must be specified! Missing: $($missingMandatory -join ",")" -Target $PSBoundParameters -EnableException $true -Cmdlet $PSCmdlet
		}
		if (-not $script:tokenTransformations[$Type]) {
			$script:tokenTransformations[$Type] = @{ }
		}

		$script:tokenTransformations[$Type][$hash.$($provider.TransformIndex)] = [PSCustomObject]$hash
	}
}