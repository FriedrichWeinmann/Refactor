@{
	# Script module or binary module file associated with this manifest
	RootModule         = 'Refactor.psm1'
	
	# Version number of this module.
	ModuleVersion      = '1.1.15'
	
	# ID used to uniquely identify this module
	GUID               = '505d7400-5106-4643-9c64-c8e430fa0032'
	
	# Author of this module
	Author             = 'Friedrich Weinmann'
	
	# Company or vendor of this module
	CompanyName        = ' '
	
	# Copyright statement for this module
	Copyright          = 'Copyright (c) 2022 Friedrich Weinmann'
	
	# Description of the functionality provided by this module
	Description        = 'PowerShell Code refactoring framework'
	
	# Minimum version of the Windows PowerShell engine required by this module
	PowerShellVersion  = '5.1'
	
	# Modules that must be imported into the global environment prior to importing
	# this module
	RequiredModules    = @(
		@{ ModuleName = 'PSFramework'; ModuleVersion = '1.6.214' }
	)
	
	# Assemblies that must be loaded prior to importing this module
	RequiredAssemblies = @('bin\Refactor.dll')
	
	# Type files (.ps1xml) to be loaded when importing this module
	# TypesToProcess = @('xml\Refactor.Types.ps1xml')
	
	# Format files (.ps1xml) to be loaded when importing this module
	FormatsToProcess   = @('xml\Refactor.Format.ps1xml')
	
	# Functions to export from this module
	FunctionsToExport  = @(
		'Clear-ReBreakingChange'
		'Clear-ReTokenTransformationSet'
		'Convert-ReScriptFile'
		'Convert-ReScriptToken'
		'Get-ReBreakingChange'
		'Get-ReScriptFile'
		'Get-ReSplat'
		'Get-ReToken'
		'Get-ReTokenProvider'
		'Get-ReTokenTransformationSet'
		'Import-ReBreakingChange'
		'Import-ReTokenTransformationSet'
		'New-ReToken'
		'Read-ReAst'
		'Read-ReScriptCommand'
		'Register-ReBreakingChange'
		'Register-ReTokenProvider'
		'Register-ReTokenTransformation'
		'Search-ReAst'
		'Search-ReBreakingChange'
	)
	
	# Cmdlets to export from this module
	# CmdletsToExport   = ''
	
	# Variables to export from this module
	# VariablesToExport = ''
	
	# Aliases to export from this module
	# AliasesToExport   = ''
	
	# List of all modules packaged with this module
	ModuleList         = @()
	
	# List of all files packaged with this module
	FileList           = @()
	
	# Private data to pass to the module specified in ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
	PrivateData        = @{
		
		#Support for PowerShellGet galleries.
		PSData = @{
			
			# Tags applied to this module. These help with module discovery in online galleries.
			Tags         = @('code', 'refactor')
			
			# A URL to the license for this module.
			LicenseUri   = 'https://github.com/FriedrichWeinmann/Refactor/blob/master/LICENSE'
			
			# A URL to the main website for this project.
			ProjectUri   = 'https://github.com/FriedrichWeinmann/Refactor'
			
			# A URL to an icon representing this module.
			# IconUri = ''
			
			# ReleaseNotes of this module
			ReleaseNotes = 'https://github.com/FriedrichWeinmann/Refactor/blob/master/Refactor/changelog.md'
			
		} # End of PSData hashtable
		
	} # End of PrivateData hashtable
}