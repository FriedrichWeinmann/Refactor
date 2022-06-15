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
		Use Register-ReTokenprovider to define your own plugin.

		Transformation Sets are rules that are applied to the tokens of a specific provider.
		For example, the "Command" provider could receive a rule that renames the command "Get-AzureADUser" to "Get-MgUser"
		Use Import-ReTokenTransformationSet to provide such rules.
	
	.PARAMETER Path
		Path to the scriptfile to modify.

	.PARAMETER ProviderName
		Name of the Token Provider to apply.
		Defaults to: '*'
	
	.PARAMETER Backup
		Whether to create a backup of the file before modifying it.

	.PARAMETER OutPath
		Folder to which to write the converted scriptfile.

	.PARAMETER Force
		Whether to update files that end in ".backup.ps1"
		By default these are skipped, as they would be the backup-files of previous conversions ... or even the current one, when providing input via pipeline!

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Get-ChildItem C:\scripts -Recurse -Filter *.ps1 | Convert-ReScriptFile

		Converts all scripts under C:\scripts according to the provided transformation sets.
	#>
	[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
	[OutputType([Refactor.TransformationResult])]
	[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'inplace')]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[PsfArgumentCompleter('Refactor.TokenProvider')]
		[string[]]
		$ProviderName = '*',

		[Parameter(ParameterSetName = 'inplace')]
		[switch]
		$Backup,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'path')]
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$OutPath,

		[switch]
		$Force
	)
	
	begin {
		$lastResolvedPath = ""
	}
	process
	{
		if ($OutPath -ne $lastResolvedPath) {
			$resolvedOutPath = Resolve-PSFPath -Path $OutPath
			$lastResolvedPath = $OutPath
		}
		foreach ($file in $Path | Resolve-PSFPath) {
			if (-not $Force -and -not $OutPath -and $file -match '\.backup\.ps1$|\.backup\.psm1$') { continue }
			Write-PSFMessage -Message 'Processing file: {0}' -StringValues $file
			$scriptfile = [Refactor.ScriptFile]::new($file)
			
			try {
				$result = $scriptfile.Transform($scriptfile.GetTokens($ProviderName))
			}
			catch {
				Write-PSFMessage -Level Error -Message 'Failed to convert file: {0}' -StringValues $file -Target $scriptfile -ErrorRecord $_ -EnableException $true -PSCmdlet $PSCmdlet
			}

			if ($OutPath) {
				Invoke-PSFProtectedCommand -Action 'Replacing content of script' -Target $file -ScriptBlock {
					$scriptfile.WriteTo($resolvedOutPath, "")
				} -PSCmdlet $PSCmdlet -EnableException $EnableException -Continue
			}
			else {
				Invoke-PSFProtectedCommand -Action 'Replacing content of script' -Target $file -ScriptBlock {
					$scriptfile.Save($Backup.ToBool())
				} -PSCmdlet $PSCmdlet -EnableException $EnableException -Continue
			}
			$result
			Write-PSFMessage -Message 'Finished processing file: {0} | Transform Count {1} | Success {2}' -StringValues $file, $result.Count, $result.Success
		}
	}
}