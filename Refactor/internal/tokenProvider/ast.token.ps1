$tokenizer = {
	param (
		$Ast
	)

	$astTypes = Get-ReTokenTransformationSet -Type Ast | ForEach-Object TypeName

	$astObjects = Search-ReAst -Ast $Ast -Filter {
		$args[0].GetType().Name -in $astTypes
	}

	foreach ($astObject in $astObjects.Data) {
		[Refactor.AstToken]::new($astObject)
	}
}
$converter = {
	param (
		[Refactor.ScriptToken]
		$Token,

		$Preview
	)

	<#
	The AST Token is special in that it expects the actual changes to be applied not by configuration but manually outside of the process.
	As such it is pointless to use in the full, config-only driven workflow of Convert-ReScriptFile.
	Instead, manually creating the scriptfile object and executing the workflows is the way to go here.
	#>

	# Return changes
	$Token.GetChanges()
}

$parameters = @(
	'TypeName'
)
$param = @{
	Name                = 'Ast'
	TransformIndex      = 'TypeName'
	ParametersMandatory = 'TypeName'
	Parameters          = $parameters
	Tokenizer           = $tokenizer
	Converter           = $converter
}
Register-ReTokenProvider @param