# Changelog

## 1.1.15 (2022-06-15)

+ Upd: Class: ScriptFile - added WriteTo method to support exporting to a path other than the source file
+ Upd: Convert-ReScriptFile - added `-OutPath` parameter to support writing the converted files to another folder
+ Fix: Get-ReScriptFile - fails to create over an empty file-content

## 1.1.12 (2022-04-15)

+ Fix: Get-ReScriptFile - generates error when not providing a path

## 1.1.11 (2022-04-14)

+ Upd: Get-ReScriptFile - added option to specify name and scriptcode, rather than being limited to reading from file.
+ Upd: CommandToken - will display line rather than offset by default
+ Upd: ScriptFile.cs - added ability to define script files from their text content, rather than just their path, in order to support working with non-file based services (scanning code retrieved from an API, ...)

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
