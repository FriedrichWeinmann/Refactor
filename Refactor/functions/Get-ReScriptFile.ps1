function Get-ReScriptFile {
	<#
	.SYNOPSIS
		Reads a scriptfile and returns an object representing it.
	
	.DESCRIPTION
		Reads a scriptfile and returns an object representing it.
		Use this for custom transformation needs - for example to only process some select token kinds.
	
	.PARAMETER Path
		Path to the scriptfile to read.

	.PARAMETER Name
		The name of the script.
		Used for identifying scriptcode that is not backed by an actual file.

	.PARAMETER Content
		The code of the script.
		Used to provide scriptcode without requiring the backing of a file.
	
	.EXAMPLE
		PS C:\> Get-ReScriptFile -Path C:\scripts\script.ps1

		Reads in the specified scriptfile
	#>
	[OutputType([Refactor.ScriptFile])]
	[CmdletBinding(DefaultParameterSetName = 'Path')]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Content')]
		[string]
		$Name,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Content')]
		[string]
		$Content
	)
	process {
		if ($Path) {
			foreach ($file in $Path | Resolve-PSFPath) {
				[Refactor.ScriptFile]::new($file)
			}
		}

		if ($Name -and $Content) {
			[Refactor.ScriptFile]::new($Name, $Content)
		}
	}
}