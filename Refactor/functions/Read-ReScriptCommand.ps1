function Read-ReScriptCommand
{
	<#
	.SYNOPSIS
		Reads a scriptfile and returns all commands contained within.
	
	.DESCRIPTION
		Reads a scriptfile and returns all commands contained within.
		Includes parameters used and whether all parameters could be resolved.
	
	.PARAMETER Path
		Path to the file to scan

	.PARAMETER Ast
		An already provided Abstract Syntax Tree object to process
	
	.EXAMPLE
		Get-ChildItem C:\scripts -Recurse -Filter *.ps1 | Read-ReScriptCommand

		Returns all commands in all files under C:\scripts
	#>
	[OutputType([Refactor.CommandToken])]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Path')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Ast')]
		[System.Management.Automation.Language.Ast]
		$Ast
	)
	
	process
	{
		if ($Path) {
			foreach ($file in $Path | Resolve-PSFPath) {
				$parsed = Read-ReAst -Path $file
	
				$splats = Get-ReSplat -Ast $parsed.Ast
				Get-AstCommand -Ast $parsed.Ast -Splat $splats
			}
		}

		foreach ($astObject in $Ast) {
			$splats = Get-ReSplat -Ast $astObject
			Get-AstCommand -Ast $astObject -Splat $splats
		}
	}
}