function Convert-ReScriptFile
{
	<#
	.SYNOPSIS
		Perform AST-based replacement / refactoring of scriptfiles
	
	.DESCRIPTION
		Perform AST-based replacement / refactoring of scriptfiles
		This process depends on two factors:
		+ Token Provider
		+ Token Transformation Sets

		The provider is a plugin that performs the actual AST analysis and replacement.
		For example, by default the "Command" provider allows renaming commands or their parameters.
		Use Register-ASTokenprovider to define your own plugin.

		Transformation Sets are rules that are applied to the tokens of a specific provider.
		For example, the "Command" provider could receive a rule that renames the command "Get-AzureADUser" to "Get-MgUser"
		Use Import-ASTokenTransformationSet to provide such rules.
	
	.PARAMETER Path
		Path to the scriptfile to modify.
	
	.PARAMETER Backup
		Whether to create a backup of the file before modifying it.

	.PARAMETER Force
		Whether to update files that end in ".backup.ps1"
		By default these are skipped, as they would be the backup-files of previous conversions ... or even the current one, when providing input via pipeline!
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\scripts -Recurse -Filter *.ps1 | Convert-ReScriptFile

		Converts all scripts under C:\scripts according to the provided transformation sets.
	#>
	[OutputType([Refactor.TransformationResult])]
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[switch]
		$Backup,

		[switch]
		$Force
	)
	
	process
	{
		foreach ($file in $Path | Resolve-PSFPath) {
			if (-not $Force -and $file -match '\.backup\.ps1$|\.backup\.psm1$') { continue }
			Write-PSFMessage -Message 'Processing file: {0}' -StringValues $file
			$scriptfile = [Refactor.ScriptFile]::new($file)
			
			try {
				$result = $scriptfile.Transform($scriptfile.GetTokens())
				$scriptfile.Save($Backup.ToBool())
				$result
				Write-PSFMessage -Message 'Finished processing file: {0} | Transform Count {1} | Success {2}' -StringValues $file, $result.Count, $result.Success
			}
			catch {
				Write-PSFMessage -Level Error -Message 'Failed to convert file: {0}' -StringValues $file -Target $scriptfile -ErrorRecord $_ -EnableException $true -PSCmdlet $PSCmdlet
			}
		}
	}
}