<#
# Command

The "Command" token provider allows renaming commands and their parameters.
It does NOT apply to your own function definitions, but the commands actually called.
#>
@{
	# Must be included in all files. The version notation allows avoiding breaking changes in future updates
	Version = 1

	# The token provider to use.
	Type    = 'Command'

	# The actual entries to process. This is where we place the individual transformation rules
	Content = @{

		"Get-AzureADUser"        = @{
			# Name of the command, as it is used
			Name       = "Get-AzureADUser"
			# (optional) New name to rename it to
			NewName    = "Get-MgUser"
			# (optional) A comment to include in the result
			Comment    = "Filter and search parameters cannot be mapped straight, may require manual attention"
			# (optional) Parameters to rename
			Parameters = @{
				Search = "Filter" # Rename Search on "Get-AzureADUser" to "Filter" on "Get-MgUser"
			}
		}
		'Set-AzureADApplication' = @{
			Name       = 'Set-AzureADApplication'
			NewName    = 'Set-MgADApplication'
			Parameters = @{
				PublicClient = 'Public'
			}
		}
	}
}