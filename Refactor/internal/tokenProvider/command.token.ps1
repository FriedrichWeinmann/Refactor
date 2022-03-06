$tokenizer = {
	Read-ReScriptCommand -Ast $args[0]
}
$converter = {
	param (
		[Refactor.ScriptToken]
		$Token
	)
	$transform = Get-ReTokenTransformationSet -Type Command | Where-Object Name -EQ $Token.Name

	if ($transform.MsgInfo) {
		$Token.WriteMessage('Information', $transform.MsgInfo, $transform)
	}
	if ($transform.MsgWarning) {
		$Token.WriteMessage('Warning', $transform.MsgWarning, $transform)
	}
	if ($transform.MsgError) {
		$Token.WriteMessage('Error', $transform.MsgError, $transform)
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

	#region Conditional Messages
	if ($transform.InfoParameters) { $transform.InfoParameters | ConvertTo-PSFHashtable }
	foreach ($parameter in $transform.InfoParameters.Keys) {
		if ($Token.Parameters[$parameter]) {
			$Token.WriteMessage('Information', $transform.InfoParameters[$parameter], $transform)
		}
	}
	if ($transform.WarningParameters) { $transform.WarningParameters | ConvertTo-PSFHashtable }
	foreach ($parameter in $transform.WarningParameters.Keys) {
		if ($Token.Parameters[$parameter]) {
			$Token.WriteMessage('Warning', $transform.WarningParameters[$parameter], $transform)
		}
	}
	if ($transform.ErrorParameters) { $transform.ErrorParameters | ConvertTo-PSFHashtable }
	foreach ($parameter in $transform.ErrorParameters.Keys) {
		if ($Token.Parameters[$parameter]) {
			$Token.WriteMessage('Error', $transform.ErrorParameters[$parameter], $transform)
		}
	}
	if (-not $Token.ParametersKnown) {
		if ($transform.UnknownInfo) {
			$Token.WriteMessage('Information', $transform.UnknownInfo, $transform)
		}
		if ($transform.UnknownWarning) {
			$Token.WriteMessage('Warning', $transform.UnknownInfo, $transform)
		}
		if ($transform.UnknownError) {
			$Token.WriteMessage('Error', $transform.UnknownInfo, $transform)
		}
	}
	#endregion Conditional Messages

	$Token.NewText = $items -join " "
	if (-not $changed) { $Token.NewText = $Token.Text }

	#region Add changes for splat properties
	foreach ($property in $Token.Splats.Values.Parameters.Keys) {
		if ($transform.Parameters.Keys -notcontains $property) { continue }

		foreach ($ast in $Token.Splats.Values.Assignments) {
			#region Case: Method Invocation
			if ($ast -is [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
				if ($ast.Arguments[0].Value -ne $property) { continue }
				$Token.AddChange($ast.Arguments[0].Extent.Text, ("'{0}'" -f ($transform.Parameters[$property] -replace "^'|'$|^`"|`"$")), $ast.Arguments[0].Extent.StartOffset, $ast)
				continue
			}
			#endregion Case: Method Invocation

			#region Case: Original assignment
			if ($ast.Left -is [System.Management.Automation.Language.VariableExpressionAst]) {
				foreach ($hashKey in $ast.Right.Expression.KeyValuePairs.Item1) {
					if ($hashKey.Value -ne $property) { continue }
					$Token.AddChange($hashKey.Extent.Text, ("'{0}'" -f ($transform.Parameters[$property] -replace "^'|'$|^`"|`"$")), $hashKey.Extent.StartOffset, $hashKey)
				}
				continue
			}
			#endregion Case: Original assignment

			#region Case: Property assignment
			if ($ast.Left -is [System.Management.Automation.Language.MemberExpressionAst]) {
				if ($ast.Left.Member.Value -ne $property) { continue }
				$Token.AddChange($ast.Left.Member.Extent.Text, $transform.Parameters[$property], $ast.Left.Member.Extent.StartOffset, $ast)
				continue
			}
			#endregion Case: Property assignment

			#region Case: Index assignment
			if ($ast.Left -is [System.Management.Automation.Language.IndexExpressionAst]) {
				if ($ast.Left.Index.Value -ne $property) { continue }
				$Token.AddChange($ast.Left.Index.Extent.Text, ("'{0}'" -f ($transform.Parameters[$property] -replace "^'|'$|^`"|`"$")), $ast.Left.Index.Extent.StartOffset, $ast)
				continue
			}
			#endregion Case: Index assignment
		}
	}
	#endregion Add changes for splat properties

	# Return changes
	$Token.GetChanges()
}
$parameters = @(
	'Name'
	'NewName'
	'Parameters'

	'MsgInfo'
	'MsgWarning'
	'MsgError'

	'InfoParameters'
	'WarningParameters'
	'ErrorParameters'

	'UnknownInfo'
	'UnknownWarning'
	'UnknownError'
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