# Changelog

## 1.1.8 (2022-04-11)

+ New: Component: Breaking Change - Scan script files for breaking changes
+ New: Command Get-ReToken - Scans a script file for all tokens contained within.
+ Upd: Added "Line" property to all tokens
+ Upd: Get-ReTokenProvider - `-Name` parameter now accepts an array of values
+ Upd: ScriptFile - GetTokens() now supports specifying a list of providers to process
+ Upd: Convert-ReScriptFile - implements ShouldProcess
+ Upd: Convert-ReScriptFile - added `-ProviderName` parameter to support filtering by provider name
+ Upd: Read-ReAst - changed `-ScriptCode` parameter to expect a string as input

## 1.0.0 (2022-03-06)

+ Initial Release
