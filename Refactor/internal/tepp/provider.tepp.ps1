Register-PSFTeppScriptblock -Name 'Refactor.TokenProvider' -ScriptBlock {
	(Get-ReTokenProvider).Name
}