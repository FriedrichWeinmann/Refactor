[CmdletBinding()]
param (
	[string]
	$UsersPath
)

if (-not (Get-AzContext)) {
	throw "Connect with azure first! Connect-AzAccount ftw"
}

$users = Get-AzADUser
$userConfig = Import-Csv $UsersPath

$param = @{
	Country       = 'USA'
	'CompanyName' = 'Contoso'
	"Foo"         = 42
}

dir @param

# Dummy code to simulate different hashtable assignments
$property = 'EmployeeHireDate'
$properties = @{ Name = 'MailNickname' }

foreach ($entry in $userConfig) {
	if ($entry.UPN -notin $users.UserPrincipalName) { continue }
	$param.EmployeeID = $entry.ID
	$param['EmployeeID'] = $entry.ID
	$param.$property = $entry.JoinedAt
	$param[$property] = $entry.JoinedAt
	$param["$property"] = $entry.JoinedAt
	$param.Add('MailNickname', $entry.MailNickname)
	$param.Add($properties.Name, $entry.MailNickname)
	$param.$($properties.Name) = $entry.MailNickname
	$param[$($properties.Name)] = $entry.MailNickname

	Set-AzureADUser -UPNOrObjectId $entry.UPN @param
}

return

# Some dummy code for this test
Get-AzureADApplication | Set-AzureADApplication -IsDisabled $false `
	-PublicClient $false