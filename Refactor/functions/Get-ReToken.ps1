function Get-ReToken {
	<#
	.SYNOPSIS
		Scans a scriptfile for all tokens contained within.
	
	.DESCRIPTION
		Scans a scriptfile for all tokens contained within.
	
	.PARAMETER Path
		Path to the file to scan
	
	.PARAMETER ProviderName
		Names of the providers to use.
		Defaults to '*'
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\scripts | Get-ReToken

		Returns all tokens for all scripts under C:\scripts
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[PsfArgumentCompleter('Refactor.TokenProvider')]
		[string[]]
		$ProviderName = '*'
	)

	process {
		foreach ($file in $Path | Resolve-PSFPath) {
			Write-PSFMessage -Message 'Processing file: {0}' -StringValues $file
			$scriptfile = [Refactor.ScriptFile]::new($file)
			$scriptfile.GetTokens($ProviderName)
		}
	}
}