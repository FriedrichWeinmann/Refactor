function Get-ReSplat {
	<#
	.SYNOPSIS
		Resolves all splats in the offered Ast.
	
	.DESCRIPTION
		Resolves all splats in the offered Ast.
		This will look up any hashtable definitions and property-assignments to that hashtable,
		whether through property notation, index assignment or add method.

		It will then attempt to define an authorative list of properties assigned to that hashtable.
		If the result is unclear, that will be indicated accordingly.

		Return Objects include properties:
		+ Splat : The original Ast where the hashtable is used for splatting
		+ Parameters : A hashtable containing all properties clearly identified
		+ ParametersKnown : Whether we are confident of having identified all properties passed through as parameters

	.PARAMETER Ast
		The Ast object to search.
		Use "Read-ReAst" to parse a scriptfile into an AST object.
	
	.EXAMPLE
		PS C:\> Get-ReSplat -Ast $ast

		Returns all splats used in the Abstract Syntax Tree object specified
	#>
	[OutputType([Refactor.Splat])]
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[System.Management.Automation.Language.Ast]
		$Ast
	)

	$splats = Search-ReAst -Ast $Ast -Filter {
		if ($args[0] -isnot [System.Management.Automation.Language.VariableExpressionAst]) { return $false }
		$args[0].Splatted
	}
	if (-not $splats) { return }

	foreach ($splat in $splats) {
		# Select the last variable declaration _before_ the splat is being used
		$assignments = Search-ReAst -Ast $Ast -Filter {
			if ($args[0] -isnot [System.Management.Automation.Language.AssignmentStatementAst]) { return $false }
			if ($args[0].Left -isnot [System.Management.Automation.Language.VariableExpressionAst]) { return $false }
			$args[0].Left.VariablePath.UserPath -eq $splat.Data.VariablePath.UserPath
		}
		$declaration = $assignments | Where-Object { $_.Start -lt $splat.Start } | Sort-Object {
			$_.Start
		} -Descending | Select-Object -First 1

		$result = [Refactor.Splat]@{
			Ast = $splat.Data
		}

		if (-not $declaration) {
			$result.ParametersKnown = $false
			$result
			continue
		}

		$propertyAssignments = Search-ReAst -Ast $Ast -Filter {
			if ($args[0].Extent.StartLineNumber -le $declaration.Start) { return $false }
			if ($args[0].Extent.StartLineNumber -ge $splat.Start) { return $false }

			$isAssignment = $(
				($args[0] -is [System.Management.Automation.Language.AssignmentStatementAst]) -and (
					($args[0].Left.VariablePath.UserPath -eq $splat.Data.VariablePath.UserPath) -or
					($args[0].Left.Expression.VariablePath.UserPath -eq $splat.Data.VariablePath.UserPath) -or
					($args[0].Left.Target.VariablePath.UserPath -eq $splat.Data.VariablePath.UserPath)
				)
			)
			$isAddition = $(
				($args[0] -is [System.Management.Automation.Language.InvokeMemberExpressionAst]) -and
				($args[0].Expression.VariablePath.UserPath -eq $splat.Data.VariablePath.UserPath) -and
				($args[0].Member.Value -eq 'Add')
			)
			$isAddition -or $isAssignment
		}

		if ($declaration.Data.Right.Expression -isnot [System.Management.Automation.Language.HashtableAst]) {
			$result.ParametersKnown = $false
		}

		foreach ($pair in $declaration.Data.Right.Expression.KeyValuePairs) {
			if ($pair.Item1 -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
				$result.Parameters[$pair.Item1.Value] = $pair.Item1.Value
			}
			else {
				$result.ParametersKnown = $false
			}
		}

		foreach ($assignment in $propertyAssignments) {
			switch ($assignment.Type) {
				'AssignmentStatementAst' {
					if ($assignment.Data.Left.Member -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
						$result.Parameters[$assignment.Data.Left.Member.Value] = $assignment.Data.Left.Member.Value
						continue
					}
					if ($assignment.Data.Left.Index -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
						$result.Parameters[$assignment.Data.Left.Index.Value] = $assignment.Data.Left.Index.Value
						continue
					}

					$result.ParametersKnown = $false
				}
				'InvokeMemberExpressionAst' {
					if ($assignment.Data.Arguments[0] -is [System.Management.Automation.Language.StringConstantExpressionAst]) {
						$result.Parameters[$assignment.Data.Arguments[0].Value] = $assignment.Data.Arguments[0].Value
						continue
					}

					$result.ParametersKnown = $false
				}
			}
		}
		# Include all relevant Ast objects
		$result.Assignments = @($declaration.Data) + @($propertyAssignments.Data) | Remove-PSFNull -Enumerate
		$result
	}
}