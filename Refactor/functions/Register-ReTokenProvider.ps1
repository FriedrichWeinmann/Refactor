function Register-ReTokenProvider {
	<#
	.SYNOPSIS
		Register a Token Provider, that implements scanning and refactor logic.
	
	.DESCRIPTION
		Register a Token Provider, that implements scanning and refactor logic.

		For example, the "Command" Token Provider supports:
		- Finding all commands called in a script, resolving all parameters used as possible.
		- Renaming commands and their parameters.
		
		For examples on how to implement this, see:
		Provider: https://github.com/FriedrichWeinmann/Refactor/blob/development/Refactor/internal/tokenProvider/command.token.ps1
		Token Class: https://github.com/FriedrichWeinmann/Refactor/blob/development/library/Refactor/Refactor/CommandToken.cs

		Note: Rather than implementing your on Token Class, you can use New-ReToken and the GenericToken class.
		This allows you to avoid the need for coding your own class, but offers no extra functionality.
	
	.PARAMETER Name
		Name of the token provider.

	.PARAMETER TransformIndex
		The property name used to map a transformation rule to a token.

	.PARAMETER ParametersMandatory
		The parameters a transformation rule MUST have to be valid.

	.PARAMETER Parameters
		The parameters a transformation rule accepts / supports.
	
	.PARAMETER Tokenizer
		Code that provides the required tokens when executed.
		Accepts one argument: An Ast object.

	.PARAMETER Converter
		Code that applies the registered transformation rule to a given token.
		Accepts two arguments: A Token and a boolean.
		The boolean argument representing, whether a preview object, representing the expected changes should be returned.
	
	.EXAMPLE
		PS C:\> Register-ReTokenProvider @param

		Registers a token provider.
		A useful example for what to provide is a bit more than can be fit in an example block,
		See an example provider here:
		Provider: https://github.com/FriedrichWeinmann/Refactor/blob/development/Refactor/internal/tokenProvider/command.token.ps1
		Token Class: https://github.com/FriedrichWeinmann/Refactor/blob/development/library/Refactor/Refactor/CommandToken.cs
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$TransformIndex,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$ParametersMandatory,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string[]]
		$Parameters,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ScriptBlock]
		$Tokenizer,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[ScriptBlock]
		$Converter
	)
	
	process {
		$script:tokenProviders[$Name] = [Refactor.TokenProvider]@{
			Name                         = $Name
			TransformIndex               = $TransformIndex
			TransformParametersMandatory = $ParametersMandatory
			TransformParameters          = $Parameters
			Tokenizer                    = $Tokenizer
			Converter                    = $Converter
		}
	}
}