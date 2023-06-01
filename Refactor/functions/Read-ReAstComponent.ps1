function Read-ReAstComponent {
	<#
	.SYNOPSIS
		Search for instances of a given AST type.
	
	.DESCRIPTION
		Search for instances of a given AST type.
		This command - together with its sibling command "Write-ReAstComponent" - is designed to simplify code updates.

		Use the data on the object, update its "NewText" property and use the "Write"-command to apply it back to the original document.
	
	.PARAMETER Name
		Name of the "file" to search.
		Use this together with the 'ScriptCode' parameter when you do not actually have a file object and just the code itself.
		Usually happens when scanning a git repository or otherwise getting the data from some API/service.
	
	.PARAMETER ScriptCode
		Code of the "file" to search.
		Use this together with the 'Name' parameter when you do not actually have a file object and just the code itself.
		Usually happens when scanning a git repository or otherwise getting the data from some API/service.
	
	.PARAMETER Path
		Path to the file to scan.
		Uses wildcards to interpret results.
	
	.PARAMETER LiteralPath
		Literal path to the file to scan.
		Does not interpret the path and instead use it as it is written.
		Useful when there are brackets in the filename.
	
	.PARAMETER Select
		The AST types to select for.
	
	.EXAMPLE
		PS C:\> Get-ChildItem -Recurse -Filter *.ps1 | Read-ReAstComponent -Select FunctionDefinitionAst, ForEachStatementAst
		
		Reads all ps1 files in the current folder and subfolders and scans for all function definitions and foreach statements.
	#>
	[CmdletBinding(DefaultParameterSetName = 'File')]
	param (
		[Parameter(Position = 0, ParameterSetName = 'Script', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[string]
		$Name,
		
		[Parameter(Position = 1, ParameterSetName = 'Script', Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('Content')]
		[string]
		$ScriptCode,

		[Parameter(Mandatory = $true, ParameterSetName = 'File', ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
		[Alias('FullName')]
		[string[]]
		$Path,

		[Parameter(Mandatory = $true, ParameterSetName = 'Literal')]
		[string[]]
		$LiteralPath,

		[Parameter(Mandatory = $true)]
		[PsfArgumentCompleter('Refactor.AstTypes')]
		[PsfValidateSet(TabCompletion = 'Refactor.AstTypes')]
		[string[]]
		$Select
	)

	process {
		#region Resolve Targets
		$targets = [System.Collections.ArrayList]@()
		if ($Name) {
			$null = $targets.Add(
				[PSCustomObject]@{
					Name    = $Name
					Content = $ScriptCode
					Path    = ''
				}
			)
		}
		foreach ($pathEntry in $Path) {
			try { $resolvedPaths = Resolve-PSFPath -Path $pathEntry -Provider FileSystem }
			catch {
				Write-Error $_
				continue
			}

			foreach ($resolvedPath in $resolvedPaths) {
				$null = $targets.Add(
					[PSCustomObject]@{
						Name    = Split-Path -Path $resolvedPath -Leaf
						Path    = $resolvedPath
					}
				)
			}
		}
		foreach ($pathEntry in $LiteralPath) {
			try { $resolvedPath = (Get-Item -LiteralPath $pathEntry -ErrorAction Stop).FullName }
			catch {
				Write-Error $_
				continue
			}

			$null = $targets.Add(
				[PSCustomObject]@{
					Name    = Split-Path -Path $resolvedPath -Leaf
					Path    = $resolvedPath
				}
			)
		}
		#endregion Resolve Targets

		Clear-ReTokenTransformationSet
		Register-ReTokenTransformation -Type ast -TypeName $Select

		foreach ($target in $targets) {
			# Create ScriptFile object
			if ($target.Path) {
				$scriptFile = [Refactor.ScriptFile]::new($target.Path)
			}
			else {
				$scriptFile = [Refactor.ScriptFile]::new($target.Name, $target.Content)
			}

			# Generate Tokens
			$tokens = $scriptFile.GetTokens('Ast')

			# Profit!
			$result = [Refactor.Component.ScriptResult]::new()
			$result.File = $scriptFile
			$result.Types = $Select
			foreach ($token in $tokens) { $result.Tokens.Add($token) }

			foreach ($token in $tokens) {
				[Refactor.Component.AstResult]::new($token, $scriptFile, $result)
			}
		}
		
		Clear-ReTokenTransformationSet
	}
}