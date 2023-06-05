function Test-ReSyntax {
	<#
	.SYNOPSIS
		Tests whether the syntax of a given scriptfile or scriptcode is valid.
	
	.DESCRIPTION
		Tests whether the syntax of a given scriptfile or scriptcode is valid.
		This uses the PowerShell syntax validation.
		Some cases - especially around PowerShell classes - may evaluate as syntax error when missing dependencies.
	
	.PARAMETER Path
		Path to the file to test.
	
	.PARAMETER LiteralPath
		Non-interpreted path to the file to test.
	
	.PARAMETER Code
		Actual code to test.

	.PARAMETER Not
		Reverses the returned logic: A syntax error found returns as $true, an error-free script returns $false.
	
	.EXAMPLE
		PS C:\> Test-ReSyntax .\script.ps1
		
		Verifies the syntax of the file 'script.ps1' in the current path.
	#>
	[OutputType([bool])]
	[CmdletBinding(DefaultParameterSetName = 'path')]
	param (
		[Parameter(Mandatory = $true, ParameterSetName = 'path', Position = 0)]
		[string]
		$Path,

		[Parameter(Mandatory = $true, ParameterSetName = 'literal')]
		[string]
		$LiteralPath,

		[Parameter(Mandatory = $true, ParameterSetName = 'code')]
		[string]
		$Code,

		[switch]
		$Not
	)

	process {
		if ($Code) {
			$result = Read-ReAst -ScriptCode $Code
			($result.Errors -as [bool]) -eq (-not $Not)
		}
		if ($Path) {
			try { $resolvedPath = Resolve-PSFPath -Path $Path -Provider FileSystem -SingleItem }
			catch { return $false -eq (-not $Not) }

			$fileItem = Get-Item -LiteralPath $resolvedPath
		}
		if ($LiteralPath) {
			try { $fileItem = Get-Item -LiteralPath $LiteralPath -ErrorAction Stop }
			catch { return $false -eq (-not $Not)}
		}

		$tokens = $null
		$errors = $null
		$null = [System.Management.Automation.Language.Parser]::ParseFile($fileItem.FullName, [ref]$tokens, [ref]$errors)
		($errors -as [bool]) -eq $Not
	}
}