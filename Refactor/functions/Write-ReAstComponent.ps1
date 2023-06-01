function Write-ReAstComponent {
	<#
	.SYNOPSIS
		Updates a scriptfile that was read from using Read-ReAstComponent.
	
	.DESCRIPTION
		Updates a scriptfile that was read from using Read-ReAstComponent.
		Automatically picks up the file to update from the scan results.
		Expects the caller to first apply changes on the test results outside of the Refactor module.

		This command processes all output in end, to support sane pipeline processing of multiple findings from a single file.
	
	.PARAMETER Components
		Component objects scanned from the file to update.
		Use Read-ReAstComponent.
		Pass all objects from the search in one go (or pipe them into the command)
	
	.PARAMETER PassThru
		Return result objects from the conversion.
		By default, this command updates the files in situ or in the target location (OutPath).
		Whether you use this parameter or not, scan results that were provided input from memory - and are thus not backed by a file - will always be returned as output.
	
	.PARAMETER Backup
		Whether to create a backup of the file before modifying it.

	.PARAMETER OutPath
		Folder to which to write the converted scriptfile.

	.PARAMETER WhatIf
		If this switch is enabled, no actions are performed but informational messages will be displayed that explain what would happen if the command were to run.

	.PARAMETER Confirm
		If this switch is enabled, you will be prompted for confirmation before executing any operations that change state.
	
	.EXAMPLE
		PS C:\> Write-ReAstComponent -Components $scriptParts
		
		Writes back the components in $scriptParts, which had previously been generated using Read-ReAstComponent, then had their content modified.
	#>
	[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'default')]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[Refactor.Component.AstResult[]]
		$Components,

		[switch]
		$PassThru,

		[Parameter(ParameterSetName = 'inplace')]
		[switch]
		$Backup,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'path')]
		[PsfValidateScript('PSFramework.Validate.FSPath.Folder', ErrorString = 'PSFramework.Validate.FSPath.Folder')]
		[string]
		$OutPath,

		[switch]
		$EnableException
	)
	begin {
		$componentObjects = [System.Collections.ArrayList]@()
		if ($OutPath) {
			$resolvedOutPath = Resolve-PSFPath -Path $OutPath
		}
	}
	process {
		$null = $componentObjects.AddRange($Components)
	}
	end {
		$grouped = $componentObjects | Group-Object { $_.Result.Id }
		foreach ($tokenGroup in $grouped) {
			$scriptFile = $tokenGroup.Group[0].File
			$before = $scriptFile.Text
			$null = $scriptFile.Transform($tokenGroup.Group.Token)
			if (-not $OutPath -and $before -eq $scriptFile.Text) { continue }

			if ($PassThru) {
				[Refactor.Component.ScriptFileConverted]::new($tokenGroup.Group[0].Result)
			}

			#region From File
			if ($scriptFile.FromFile) {
				if ($OutPath) {
					Invoke-PSFProtectedCommand -Action "Writing updated script to $resolvedOutPath" -Target $scriptFile.Path -ScriptBlock {
						$scriptfile.WriteTo($resolvedOutPath, "")
					} -PSCmdlet $PSCmdlet -EnableException $EnableException -Continue
					continue
				}

				Invoke-PSFProtectedCommand -Action 'Replacing content of script' -Target $scriptFile.Path -ScriptBlock {
					$scriptfile.Save($Backup.ToBool())
				} -PSCmdlet $PSCmdlet -EnableException $EnableException -Continue
			}
			#endregion From File

			#region From Content
			else {
				if ($OutPath) {
					Invoke-PSFProtectedCommand -Action "Writing updated script to $resolvedOutPath" -Target $scriptFile.Path -ScriptBlock {
						$scriptfile.WriteTo($resolvedOutPath, $scriptFile.Path)
					} -PSCmdlet $PSCmdlet -EnableException $EnableException -Continue
					continue
				}

				# Since it's already returned once for $PassThru, let's not double up here
				if (-not $PassThru) {
					[Refactor.Component.ScriptFileConverted]::new($tokenGroup[0].Result)
				}
			}
			#endregion From Content
		}
	}
}