using System.Collections.Generic;
using System.Management.Automation.Language;

namespace Refactor
{
    /// <summary>
    /// Generic AST token.
    /// </summary>
    public class AstToken : ScriptToken
    {
        /// <summary>
        /// The kind of token this is.
        /// Must match the name of the token provider to use.
        /// </summary>
        public override string Type { get { return "Ast"; } }

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
        /// Total length of the ast
        /// </summary>
        public int Length => Ast.Extent.EndOffset - Ast.Extent.StartOffset;

        /// <summary>
        /// The text the Ast should have
        /// </summary>
        public string NewText;

        /// <summary>
        /// Create a new ast token based off an ast object.
        /// </summary>
        /// <param name="AstObject">The AST describing a powershell element</param>
        public AstToken(Ast AstObject)
        {
            Ast = AstObject;
            Name = AstObject.GetType().Name;
            NewText = Ast.Extent.Text;
        }

        /// <summary>
        /// The changes applied to this token.
        /// </summary>
        /// <returns>The changes applied to this token.</returns>
        public override List<Change> GetChanges()
        {
            var changes = new List<Change>();
            Change change = new Change();
            change.Before = Ast.Extent.Text;
            change.After = NewText;
            change.Offset = Ast.Extent.StartOffset;
            change.Token = this;
            change.Path = Ast?.Extent.File;
            if (change.After != change.Before)
                changes.Add(change);
            return changes;
        }
    }
}