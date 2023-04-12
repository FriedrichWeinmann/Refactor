function Import-ReTokenTransformationSet {
	<#
	.SYNOPSIS
		Imports a token transformation file.
	
	.DESCRIPTION
		Imports a token transformation file.
		Can be either json or psd1 format

		Root level must contain at least three nodes:
		+ Version: The schema version of this file. Should be 1
		+ Type: The type of token being transformed. E.g.: "Command"
		+ Content: A hashtable containing the actual sets of transformation. The properties required depend on the Token Provider.

		Example:
		@{
			Version = 1
			Type = 'Command'
			Content = @{
				"Get-AzureADUser" = @{
					Name = "Get-AzureADUser"
					NewName  = "Get-MgUser"
					Comment = "Filter and search parameters cannot be mapped straight, may require manual attention"
					Parameters = @{
						Search = "Filter" # Rename Search on "Get-AzureADUser" to "Filter" on "Get-MgUser"
					}
				}
			}
		}
	
	.PARAMETER Path
		Path to the file to import.
		Must be json or psd1 format
	
	.EXAMPLE
		PS C:\> Import-ReTokenTransformationSet -Path .\azureAD-to-graph.psd1

		Imports all the transformationsets stored in "azureAD-to-graph.psd1" in the current folder.
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path
	)
	
	begin {
		function Import-TransformV1 {
			[CmdletBinding()]
			param (
				$Data,

				$Path
			)

			$msgDefault = @{
				Level = "Warning"
				FunctionName = 'Import-ReTokenTransformationSet'
				PSCmdlet = $PSCmdlet
				StringValues = $Path
			}

			$defaultType = $Data.Type
			$contentHash = $Data.Content | ConvertTo-PSFHashtable
			foreach ($entry in $contentHash.Values) {
				$entryHash = $entry | ConvertTo-PSFHashtable
				if ($defaultType -and -not $entryHash.Type) {
					$entryHash.Type = $defaultType
				}
				if (-not $entryHash.Type) {
					Write-PSFMessage @msgDefault -Message "Invalid entry within file - No Type defined: {0}" -Target $entryHash
					continue
				}

				try { Register-ReTokenTransformation @entryHash -ErrorAction Stop }
				catch {
					Write-PSFMessage @msgDefault -Message "Error processing entry within file: {0}" -ErrorRecord $_ -Target $entryHash
					continue
				}
			}
		}
	}
	process {
		:main foreach ($filePath in $Path | Resolve-PSFPath -Provider FileSystem) {
			if (Test-Path -LiteralPath $filePath -PathType Container) { continue }

			$fileInfo = Get-Item -LiteralPath $filePath
			$data = switch ($fileInfo.Extension) {
				'.json' {
					Get-Content -LiteralPath $fileInfo.FullName | ConvertFrom-Json
				}
				'.psd1' {
					Import-PSFPowerShellDataFile -LiteralPath $fileInfo.FullName
				}
				default {
					$exception = [System.ArgumentException]::new("Unknown file extension: $($fileInfo.Extension)")
					Write-PSFMessage -Message "Error importing $($fileInfo.FullName): Unknown file extension: $($fileInfo.Extension)" -Level Error -Exception $exception -EnableException $true -Target $fileInfo -OverrideExceptionMessage
					continue main
				}
			}

			switch ("$($data.Version)") {
				"1" { Import-TransformV1 -Data $data -Path $fileInfo.FullName }
				default {
					$exception = [System.ArgumentException]::new("Unknown schema version: $($data.Version)")
					Write-PSFMessage -Message "Error importing $($fileInfo.FullName): Unknown schema version: $($data.Version)" -Level Error -Exception $exception -EnableException $true -Target $fileInfo -OverrideExceptionMessage
					continue main
				}
			}
		}
	}
}