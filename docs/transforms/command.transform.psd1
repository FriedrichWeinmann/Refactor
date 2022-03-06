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
			Name              = "Get-AzureADUser"
			# (optional) New name to rename it to
			NewName           = "Get-MgUser"
			# (optional) A comment to always include in the result
			MsgInfo           = "Filter and search parameters cannot be mapped straight, may require manual attention"
			# (optional) A warning to always include in the result
			MsgWarning           = 'Some warning text'
			# (optional) An error to always include in the result
			MsgError             = 'Some error text'
			# (optional) Parameters to rename
			Parameters        = @{
				Search = "Filter" # Rename Search on "Get-AzureADUser" to "Filter" on "Get-MgUser"
			}
			# (optional) Include an informative message in the result in case the specified parameters is used
			InfoParameters    = @{
				Search = 'The search condition requires manual adjustment'
			}
			# (optional) Include a warning message in the result in case the specified parameters is used
			WarningParameters = @{
				Search = 'The search condition requires manual adjustment'
			}
			# (optional) Include an error message in the result in case the specified parameters is used
			ErrorParameters   = @{
				Search = 'The search condition requires manual adjustment'
			}
			# (optional) Include an informative message in the result, if not all parameters can be resolved
			UnknownInfo       = 'Significant breaking change happened in this command''s parameters, may require manual control.'
			# (optional) Include a warning message in the result, if not all parameters can be resolved
			UnknownWarning    = 'Significant breaking change happened in this command''s parameters, may require manual control.'
			# (optional) Include an error message in the result, if not all parameters can be resolved
			UnknownError      = 'Significant breaking change happened in this command''s parameters, may require manual control.'
		}
		'Set-AzureADApplication' = @{
			Name       = 'Set-AzureADApplication'
			NewName    = 'Set-MgADApplication'
			Parameters = @{
				PublicClient = 'Public'
			}
		}
		'Set-AzureADUser' = @{
			Name = 'Set-AzureADUser'
			NewName = 'Set-AzADUser'
			Parameters = @{
				EmployeeID = 'EmployeeID2'
				MailNickname = 'MailNickname2'
				Country = 'Country2'
			}
			InfoParameters    = @{
				Country = 'The Country parameter has a but in v7.1. See https://google.com'
			}
			WarningParameters = @{
				CompanyName = 'The CompanyName parameter has been deprecated'
			}
			ErrorParameters   = @{
				UPNOrObjectId = 'The UPNOrObjectId parameter is broken'
			}
		}
	}
}