function Convert-ReScriptToken {
	<#
	.SYNOPSIS
		Converts a token using the conversion logic defined per token type.
	
	.DESCRIPTION
		Converts a token using the conversion logic defined per token type.
		This could mean renaming a command, changing a parameter, etc.

		The actual logic happens in the converter scriptblock provided by the Token Provider.
		This should update the changes in the Token object, as well as returning a summary object as output.
	
	.PARAMETER Token
		The token to transform.
	
	.PARAMETER Preview
		Instead of returning the new text for the token, return a metadata object providing additional information.
	
	.EXAMPLE
		PS C:\> Convert-ReScriptToken -Token $token

		Returns an object, showing what would have been done, had this been applied.
	#>
	[OutputType([Refactor.Change])]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Refactor.ScriptToken[]]
		$Token
	)
	
	process {
		foreach ($tokenObject in $Token) {
			$provider = Get-ReTokenProvider -Name $tokenObject.Type
			if (-not $provider) {
				Stop-PSFFunction -Message "No provider found for type $($tokenObject.Type)" -Target $tokenObject -EnableException $true -Cmdlet $PSCmdlet
			}
			& $provider.Converter $tokenObject
		}
	}
}