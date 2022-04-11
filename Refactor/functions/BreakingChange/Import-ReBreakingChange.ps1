function Import-ReBreakingChange {
	<#
	.SYNOPSIS
		Imports a set of Breaking Change configurations from file.
	
	.DESCRIPTION
		Imports a set of Breaking Change configurations from file.
		Expects a PowerShell Document File (.psd1)

		Example layout of import file:

		@{
			MyModule = @{
				'2.0.0' = @{
					'Get-Something' = @{
						Description = 'Command was fully redesigned'
					}
					'Get-SomethingElse' = @{
						Parameters @{
							Param1 = 'Parameter was dropped'
							Param2 = 'Accepts string only now and will not try to parse custom objects anymore'
							Param3 = 'Was renamed to Param4'
						}
						Labels = @('primary')
					}
				}
			}
		}
	
	.PARAMETER Path
		Path to the file(s) to import.
	
	.PARAMETER EnableException
		Replaces user friendly yellow warnings with bloody red exceptions of doom!
		Use this if you want the function to throw terminating errors you want to catch.
	
	.EXAMPLE
		PS C:\> Import-ReBreakingChange -Path .\mymodule.break.psd1

		Imports the mymodule.break.psd1
	#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'File')]
		[PsfValidateScript('PSFramework.Validate.FSPath.File', ErrorString = 'PSFramework.Validate.FSPath.File')]
		[Alias('FullName')]
		[string[]]
		$Path,

		[switch]
		$EnableException
	)

	process {
		foreach ($file in $Path | Resolve-PSFPath) {
			$dataSet = Import-PSFPowerShellDataFile -Path $file

			foreach ($module in $dataSet.Keys) {
				foreach ($version in $dataSet.$module.Keys) {
					if (-not ($version -as [version])) {
						Stop-PSFFunction -Message "Invalid Version node $($version) for module $($module). Ensure it is a valid version number, prerelease version notations are not supported!" -EnableException $EnableException -Continue -Cmdlet $PSCmdlet
					}
					foreach ($command in $dataSet.$module.$version.Keys) {
						$commandData = $dataSet.$module.$version.$command

						$param = @{
							Module = $module
							Version = $version
							Command = $command
						}
						if ($commandData.Description) { $param.Description = $commandData.Description }
						if ($commandData.Parameters) { $param.Parameters = $commandData.Parameters }
						if ($commandData.Tags) { $param.Tags = $commandData.Tags }
						
						Register-ReBreakingChange @param
					}
				}
			}
		}
	}
}