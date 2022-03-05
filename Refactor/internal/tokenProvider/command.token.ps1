$tokenizer = {
	Read-ReScriptCommand -Ast $args[0]
}
$converter = {
	param (
		[Refactor.ScriptToken]
		$Token,

		[bool]
		$Preview
	)
	$transform = Get-ReTokenTransformationSet -Type Command | Where-Object Name -EQ $Token.Name
	if (-not $transform -and -not $Preview) { return $Token.Text }

	if ($transform.Warning) {
		Write-PSFMessage -Level Warning -Message $transform.Warning -Target $Token -Data @{ Token = $Token; Transform = $transform }
	}

	$changed = $false
	$items = foreach ($commandElement in $Token.Ast.CommandElements) {
		# Command itself
		if ($commandElement -eq $Token.Ast.CommandElements[0]) {
			if ($transform.NewName) { $transform.NewName; $changed = $true }
			else { $commandElement.Value }
			continue
		}

		if ($commandElement -isnot [System.Management.Automation.Language.CommandParameterAst]) {
			$commandElement.Extent.Text
			continue
		}
		if (-not $transform.Parameters) {
			$commandElement.Extent.Text
			continue
		}
		# Not guaranteed to be a hashtable
		$transform.Parameters = $transform.Parameters | ConvertTo-PSFHashtable
		if (-not $transform.Parameters[$commandElement.ParameterName]) {
			$commandElement.Extent.Text
			continue
		}

		"-$($transform.Parameters[$commandElement.ParameterName])"
		$changed = $true
	}

	$newText = $items -join " "
	if (-not $changed) { $newText = $Token.Text }

	if (-not $Preview) { return $newText }

	[PSCustomObject]@{
		OldText   = $Token.Text
		NewText   = $newText
		Token     = $Token
		Command   = $Token.Name
		Transform = $transform
		Comment   = $transform.Comment
	}
}
$parameters = @(
	'Name'
	'NewName'
	'Parameters'
	'Warning'
	'Comment'
)
$param = @{
	Name                = 'Command'
	TransformIndex      = 'Name'
	ParametersMandatory = 'Name'
	Parameters          = $parameters
	Tokenizer           = $tokenizer
	Converter           = $converter
}
Register-ReTokenProvider @param