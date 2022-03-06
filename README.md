# Refactor

Welcome to the Refactor project.
This module is designed to provide an infrastructure for code analysis and refactoring your code.

Intended use-cases:

+ Bulk Code Scanning
+ Code Migration advisor
+ Code Migration automation
+ Code Maintenance automation

## Installing

To install the module from the PSGallery, run this command:

```powershell
Install-Module Refactor
```

## Getting Started

> Processing command usage

To rename a command, or the parameters used, or maybe just inform on them, you first need to provide a "Transform File".
That is, a `.psd1` or `.json` document describing what you want to change or report upon.

[Here is an example file to use as reference](https://github.com/FriedrichWeinmann/Refactor/blob/master/docs/transforms/command.transform.psd1)

You can then apply the example file against your scripts in bulk.
To simulate this - and demonstrate the example Transform File in action - [there is also an example script to run this against.](https://github.com/FriedrichWeinmann/Refactor/blob/master/testfiles/commands.ps1)

To apply this, run the following:

```powershell
Import-ReTokenTransformationSet -Path .\command.transform.psd1
Get-ChildItem C:\scripts | Convert-ReScriptFile -Backup # -Backup creates a backup file before modifying the existing one
```

## Concepts

This toolkit is freely extensible and intended for both analysis and transformation.
In order to process this in a structured manner, there are several key concepts:

+ Token
+ Token Provider
+ Transform

> Token

A token represents a code element.
It may be a single piece of text in the code scanned, or several associated ones:

+ A single command invocation
+ A single command invocation, the declaration of a hashtable used to splat
+ All instances of a specific variable

A token is associated with a single Token Provider, multiple tokens may describe the same piece of code, or partially overlap.

Tokens are implemented as a class in C#, extending the abstract [ScriptToken](https://github.com/FriedrichWeinmann/Refactor/blob/master/library/Refactor/Refactor/ScriptToken.cs) class.
There is however a [Generic Token Class](https://github.com/FriedrichWeinmann/Refactor/blob/master/library/Refactor/Refactor/GenericToken.cs) that can be reused, avoiding the need to implement your own class in return for less flexibility.
Use the `New-ReToken` command to generate a new generic token.

> Token Provider

A Token Provider is a set of tools used to process tokens.
At its core, it contains two pieces of code:

+ Logic to parse an Abstract Syntax Tree to generate tokens
+ Logic to react to those tokens, reporting on them or converting/transforming them

For example, the [Command Provider](https://github.com/FriedrichWeinmann/Refactor/blob/master/Refactor/internal/tokenProvider/command.token.ps1) was implemented to scan and change how a command is called, renaming the command and its parameters.
It will also rename properties on splats, if possible.

> Transform

A transform, is a set of instructions to a Token Provider.
They are then matched against the relevant Token, which is implemented in the Token Provider.

Here is an [example file for reference](https://github.com/FriedrichWeinmann/Refactor/blob/master/docs/transforms/command.transform.psd1).

The format for Transform Files is predefined:

```powershell
@{
    # Must be included in all files. The version notation allows avoiding breaking changes in future updates
    Version = 1

    # The token provider to use.
    Type    = 'Command'

    # The actual entries to process. This is where we place the individual transformation rules
    Content = @{
        # Add individual entries here
    }
}
```

The structure of the individual entries under Content - which properties are supported and which not - is also defined in the Token provider.
