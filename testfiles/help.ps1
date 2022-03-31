<#
	.SYNOPSIS
	Does something
	
	.DESCRIPTION
	Does something
	More details
	
	.PARAMETER ParamA
	Whatever
	
	.PARAMETER ParamB
	Whatever Else
	
	.PARAMETER ParamC
	Kind of unimportant
	So who cares about ParamC?
	
	.EXAMPLE
	PS C:\> Get-Test1 -ParamA $value

	Does something.
	Probably.
	
	.NOTES
	Version: 1.0.0
	Author: Max
	Company Contoso Ltd.
#>
function Get-Test1 {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$ParamA,
		[ValidateSet(1,2,3)]
		$ParamB,
		$ParamC
	)
}

function Get-Test2 {
<#
	.SYNOPSIS
	Does something
	
	.DESCRIPTION
	Does something
	More details
	
	.PARAMETER ParamA
	Whatever
	
	.PARAMETER ParamB
	Whatever Else
	
	.PARAMETER ParamC
	Kind of unimportant
	So who cares about ParamC?
	
	.EXAMPLE
	PS C:\> Get-Test2 -ParamA $value

	Does something.
	Probably.
	
	.NOTES
	Version: 1.0.0
	Author: Max
	Company Contoso Ltd.
#>
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		$ParamA,
		[ValidateSet(1,2,3)]
		$ParamB,
		$ParamC
	)
}

function Get-Test3 {
<#
	.SYNOPSIS
	Does something
	
	.DESCRIPTION
	Does something
	More details
	
	.EXAMPLE
	PS C:\> Get-Test3 -ParamA $value

	Does something.
	Probably.
	
	.NOTES
	Version: 1.0.0
	Author: Max
	Company Contoso Ltd.
#>
	[CmdletBinding()]
	param (
		# Whatever
		[Parameter(Mandatory = $true)]
		$ParamA,
		# Whatever Else
		[ValidateSet(1,2,3)]
		$ParamB,

		# Kind of unimportant
		# So who cares about ParamC?
		$ParamC
	)
}