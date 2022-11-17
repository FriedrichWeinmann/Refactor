using System.Collections.Generic;
using System.Management.Automation.Language;

namespace Refactor
{
    /// <summary>
    /// Token representing a function definition
    /// </summary>
    public class FunctionToken : ScriptToken
    {
        /// <summary>
        /// The kind of token this is.
        /// Must match the name of the token provider to use.
        /// </summary>
        public override string Type { get { return "Function"; } }

        /// <summary>
        /// The actual Text within the file that should be replaced after executing transform.
        /// </summary>
        public string Text { get { return Ast.Extent.Text; } }

        /// <summary>
        /// The start offset within the original code.
        /// Used to identify the code's position in the original text when replacing with transformed content.
        /// </summary>
        public int StartOffset { get { return Ast.Extent.StartOffset; } }

        /// <summary>
        /// Total length of the function definition
        /// </summary>
        public int Length => Ast.Extent.EndOffset - Ast.Extent.StartOffset;

        /// <summary>
        /// The changes applied to this Token.
        /// Filled by calling Transform()
        /// </summary>
        public List<Change> Changes = new List<Change>();

        /// <summary>
        /// Create a new function token based off a function definition ast.
        /// </summary>
        /// <param name="Definition">The AST describing a function definition</param>
        public FunctionToken(FunctionDefinitionAst Definition)
        {
            Ast = Definition;
            Name = Definition.Name;
        }

        /// <summary>
        /// The changes applied to this token.
        /// </summary>
        /// <returns>The changes applied to this token.</returns>
        public override List<Change> GetChanges()
        {
            var changes = new List<Change>();
            changes.AddRange(Changes);
            return changes;
        }

        /// <summary>
        /// Add a new change to this token
        /// </summary>
        /// <param name="Before">The text before the change</param>
        /// <param name="After">The text after the change</param>
        /// <param name="Offset">The starting offset in the source text being modified</param>
        /// <param name="Data">Any additional data to include (such as the Ast maybe)</param>
        public void AddChange(string Before, string After, int Offset, object Data = null)
        {
            Change change = new Change();
            change.Before = Before;
            change.After = After;
            change.Offset = Offset;
            change.Data = Data;
            change.Token = this;
            change.Path = Ast?.Extent.File;
            Changes.Add(change);
        }
    }
}
