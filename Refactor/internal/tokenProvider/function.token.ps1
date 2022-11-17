$tokenizer = {
	param (
		$Ast
	)

	$functionAsts = Search-ReAst -Ast $Ast -Filter {
		$args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]
	}

	foreach ($functionAst in $functionAsts.Data) {
		[Refactor.FunctionToken]::new($functionAst)
	}
}
$converter = {
	param (
		[Refactor.ScriptToken]
		$Token,

		$Preview
	)

	$transform = Get-ReTokenTransformationSet -Type Function | Where-Object Name -EQ $Token.Name
	if (-not $transform) { return }

	#region Function Name
	if ($transform.NewName) {
		$startIndex = $Token.Ast.Extent.Text.IndexOf($Token.Ast.Name)
		$Token.AddChange($Token.Ast.Name, $transform.NewName, $startIndex, $null)

		$helpData = $Token.Ast.GetHelpContent()
		$endOffset = $Token.Ast.Body.ParamBlock.Extent.StartOffset
		if (-not $endOffset) { $Token.Ast.Body.DynamicParamBlock.Extent.StartOffset }
		if (-not $endOffset) { $Token.Ast.Body.BeginBlock.Extent.StartOffset }
		if (-not $endOffset) { $Token.Ast.Body.ProcessBlock.Extent.StartOffset }
		if (-not $endOffset) { $Token.Ast.Body.EndBlock.Extent.StartOffset }

		foreach ($example in $helpData.Examples) {
			foreach ($line in $example -split "`n") {
				if ($line -notmatch "\b$($Token.Ast.Name)\b") { continue }
				$lineIndex = $Token.Ast.Extent.Text.Indexof($line)
				$commandIndex = ($line -split "\b$($Token.Ast.Name)\b")[0].Length
				# Hard-Prevent editing in function body.
				# Renaming references, including recursive references, is responsibility of the Command token
				if (($lineIndex + $line.Length) -gt $endOffset) { continue }

				$Token.AddChange($Token.Ast.Name, $transform.NewName, ($lineIndex + $commandIndex), $null)
			}
		}
	}
	#endregion Function Name

	# Return changes
	$Token.GetChanges()
}
$parameters = @(
	'Name'
	'NewName'
)
$param = @{
	Name                = 'Function'
	TransformIndex      = 'Name'
	ParametersMandatory = 'Name'
	Parameters          = $parameters
	Tokenizer           = $tokenizer
	Converter           = $converter
}
Register-ReTokenProvider @param