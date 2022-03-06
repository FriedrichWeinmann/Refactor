function New-ReToken {
	<#
	.SYNOPSIS
		Creates a new, generic token object.
	
	.DESCRIPTION
		Creates a new, generic token object.
		Use this in script-only Token Providers, trading the flexibility of a custom Token type
		for the simplicity of not having to deal with C# or classes.
	
	.PARAMETER Type
		The type of the token.
		Must match the name of the provider using it.
	
	.PARAMETER Name
		The name of the token.
		Used to match the token against transforms.
	
	.PARAMETER Ast
		An Ast object representing the location in the script the token deals with.
		Purely optional, so long as your provider knows how to deal with the token.
	
	.PARAMETER Data
		Any additional data to store with the token.
	
	.EXAMPLE
		PS C:\> New-ReToken -Type variable -Name ComputerName

		Creates a new token of type variable with name ComputerName.
		Assumes you have registered a Token Provider of name variable.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
	[OutputType([Refactor.GenericToken])]
	[CmdletBinding()]
	param (
		[parameter(Mandatory = $true)]
		[string]
		$Type,

		[parameter(Mandatory = $true)]
		[string]
		$Name,

		[System.Management.Automation.Language.Ast]
		$Ast,

		[object]
		$Data
	)

	process {
		$token = [Refactor.GenericToken]::new($Type, $Name)
		$token.Ast = $Ast
		$token.Data = $Data
		$token
	}
}