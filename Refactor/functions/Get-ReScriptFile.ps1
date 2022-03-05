function Get-ReScriptFile {
	<#
	.SYNOPSIS
		Reads a scriptfile and returns an object representing it.
	
	.DESCRIPTION
		Reads a scriptfile and returns an object representing it.
		Use this for custom transformation needs - for example to only process some select token kinds.
	
	.PARAMETER Path
		Path to the scriptfile to read.
	
	.EXAMPLE
		PS C:\> Get-ReScriptFile -Path C:\scripts\script.ps1

		Reads in the specified scriptfile
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	process {
		foreach ($file in $Path | Resolve-PSFPath) {
			[Refactor.ScriptFile]::new($file)
		}
	}
}