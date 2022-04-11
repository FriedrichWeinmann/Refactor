function Search-ReBreakingChange {
	<#
	.SYNOPSIS
		Search script files for breaking changes.
	
	.DESCRIPTION
		Search script files for breaking changes.
		Use Import-ReBreakingChange or Register-ReBreakingChange to define which command was broken in what module and version.
	
	.PARAMETER Path
		Path to the file(s) to scan.
	
	.PARAMETER Content
		Script Content to scan.
	
	.PARAMETER Name
		Name of the scanned content
	
	.PARAMETER Module
		The module(s) to scan for.
		This can be either a name (and then use the version definitions from -FromVersion and -ToVersion parameters),
		or a Hashtable with three keys: Name, FromVersion and ToVersion.
		Example inputs:

		MyModule
		@{ Name = 'MyModule'; FromVersion = '1.0.0'; ToVersion = '2.0.0' }
	
	.PARAMETER FromVersion
		The version of the module for which the script was written.
	
	.PARAMETER ToVersion
		The version of the module to which the script is being migrated
	
	.PARAMETER Tags
		Only include breaking changes that include one of these tags.
		This allows targeting a specific subset of breaking changes.
	
	.EXAMPLE
		PS C:\> Get-ChildItem -Path C:\scripts -Recurse -Filter *.ps1 | Search-ReBreakingChange -Module Az -FromVersion 5.0 -ToVersion 7.0
		
		Return all breaking changes in all scripts between Az v5.0 and v7.0.
		Requires a breaking change definition file for the Az Modules to be registered, in order to work.
	#>
	[CmdletBinding(DefaultParameterSetName = 'File')]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'File')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Content')]
		[string]
		$Content,

		[Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'Content')]
		[string]
		$Name,

		[Parameter(Mandatory = $true)]
		[object[]]
		$Module,

		[Version]
		$FromVersion,

		[Version]
		$ToVersion,

		[string[]]
		$Tags = @()
	)

	begin {
		#region Collect Changes to apply
		$changeObjects = foreach ($moduleItem in $Module) {
			$fromV = $FromVersion
			$toV = $ToVersion
			if ($moduleItem.FromVersion) { $fromV = $moduleItem.FromVersion }
			if ($moduleItem.ToVersion) { $toV = $moduleItem.ToVersion }
			$moduleName = $moduleItem.Name
			if (-not $moduleName) { $moduleName = $moduleItem.ModuleName }
			if (-not $moduleName) { $moduleName = $moduleItem -as [string] }

			if (-not $fromV) { Write-PSFMessage -Level Warning -Message "Unable to identify the starting version from which the module $moduleItem is being migrated! be sure to specify the '-FromVersion' parameter." -Target $moduleItem }
			if (-not $toV) { Write-PSFMessage -Level Warning -Message "Unable to identify the destination version from which the module $moduleItem is being migrated! be sure to specify the '-ToVersion' parameter." -Target $moduleItem }
			if (-not $fromV) { Write-PSFMessage -Level Warning -Message "Unable to identify the name of the module being migrated! Be sure to specify a legitimate name to the '-Module' parameter." -Target $moduleItem }
			if (-not ($fromV -and $toV -and $moduleName)) {
				Stop-PSFFunction -Message "Failed to resolve the migration metadata - provide a module, the source and the destination version number!" -EnableException $true -Cmdlet $PSCmdlet
			}

			Get-ReBreakingChange -Module $moduleName -Tags $Tags | Where-Object {
				$fromV -lt $_.Version -and
				$toV -ge $_.Version
			}
		}
		$changes = @{ }
		foreach ($group in $changeObjects | Group-Object Command) {
			$changes[$group.Name] = $group.Group
		}
		#endregion Collect Changes to apply
	}
	process {
		switch ($PSCmdlet.ParameterSetName) {
			File {
				foreach ($filePath in $Path) {
					$ast = Read-ReAst -Path $filePath
					Find-BreakingChange -Ast $ast.Ast -Changes $changes
				}
			}
			Content {
				$ast = Read-ReAst -ScriptCode $Content
				Find-BreakingChange -Ast $ast.Ast -Name $Name -Changes $changes
			}
		}
	}
}