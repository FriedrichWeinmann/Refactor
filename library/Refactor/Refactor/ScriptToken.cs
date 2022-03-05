using System.Collections.Generic;
using System.Management.Automation;
using System.Management.Automation.Language;

namespace Refactor
{
    /// <summary>
    /// The base class for token objects.
    /// Extend from this if you want to define your own custom token type
    /// </summary>
    public abstract class ScriptToken
    {
        /// <summary>
        /// Name of the token.
        /// Used for identifying transforms and matched against their index.
        /// </summary>
        public string Name;

        /// <summary>
        /// AST object representing the code content of the Token.
        /// Is optional
        /// </summary>
        public Ast Ast;

        /// <summary>
        /// The kind of token this is.
        /// Must match the name of the token provider to use.
        /// </summary>
        public abstract string Type { get; }

        /// <summary>
        /// Whether the changes wrought by the token can be applied if only some of them remainvalid
        /// </summary>
        public bool AllowPartial;

        /// <summary>
        /// Convert the token-related text by applying transformation rule as implemented by the provider
        /// </summary>
        /// <returns>The new text that should replace the original text represented by this token.</returns>
        public void Transform()
        {
            using (PowerShell runspace = PowerShell.Create(RunspaceMode.CurrentRunspace))
            {
                runspace.AddCommand(Host.TransformCommand);
                runspace.AddArgument(this);
                runspace.Invoke<string>();
            }
        }

        /// <summary>
        /// Returns changes the token would apply.
        /// Run after calling transform
        /// </summary>
        /// <returns>The changes applied by this token after its transformation</returns>
        public abstract List<Change> GetChanges();
    }
}
