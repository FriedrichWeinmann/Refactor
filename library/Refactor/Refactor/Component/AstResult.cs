using System.Linq;
using System.Management.Automation.Language;

namespace Refactor.Component
{
    /// <summary>
    /// Result set of an Ast Token scan. Returned by Read-ReAstComponent, processed by Write-ReAstComponent.
    /// </summary>
    public class AstResult
    {
        /// <summary>
        /// What kind of AST was it?
        /// </summary>
        public string Type { get => Token.Ast.GetType().Name; }

        /// <summary>
        /// Name of the file the AST token was generated from.
        /// </summary>
        public string FileName { get => File.Path.Split('\\', '/').Last(); }

        /// <summary>
        /// Starting line in the file that the AST token was generated from.
        /// </summary>
        public int Line { get => Token.Ast.Extent.StartLineNumber; }

        /// <summary>
        /// Path of the file the AST token was generated from.
        /// </summary>
        public string Path { get => File.Path; }

        /// <summary>
        /// Text of the AST
        /// </summary>
        public string Text { get => Token.Text; }

        /// <summary>
        /// New text of the AST
        /// </summary>
        public string NewText
        {
            get { return Token.NewText; }
            set { Token.NewText = value; }
        }

        /// <summary>
        /// Ast object found
        /// </summary>
        public Ast Ast {  get => Token.Ast; }
        
        /// <summary>
        /// The token generated from the AST token provider
        /// </summary>
        public AstToken Token;

        /// <summary>
        /// The open ScriptFile, used for applying changes
        /// </summary>
        public ScriptFile File;

        /// <summary>
        /// The scan result of any given target processed by Read-ReAstComponent.
        /// In case you need to link all results from a single scan.
        /// </summary>
        public ScriptResult Result;

        /// <summary>
        /// Generate a new AST Result
        /// </summary>
        /// <param name="Token">The token being represented</param>
        /// <param name="File">The scriptfile scanned</param>
        /// <param name="Result">The result object containing all tokens from a given scan.</param>
        public AstResult(AstToken Token, ScriptFile File, ScriptResult Result)
        {
            this.Token = Token;
            this.File = File;
            this.Result = Result;
        }
    }
}
