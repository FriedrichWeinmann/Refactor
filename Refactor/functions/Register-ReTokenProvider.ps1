function Register-ReTokenProvider {
	<#
	.SYNOPSIS
		Register a codeblock that when executed will return tokens from an Ast.
	
	.DESCRIPTION
		Register a codeblock that when executed will return tokens from an Ast.
		The scriptblock should assume one input argument: The Ast to search.
		It should then return [AzureScriptTools.ScriptToken] objects, representing relevant items in the Ast.
	
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