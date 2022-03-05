using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;

namespace Refactor
{
    /// <summary>
    /// Object representing a single command in a script
    /// </summary>
    public class CommandToken : ScriptToken
    {
        /// <summary>
        /// The kind of token this is.
        /// Must match the name of the token provider to use.
        /// </summary>
        public override string Type { get { return "Command"; } }

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
        /// The updated text after running the token transformation
        /// </summary>
        public string NewText;

        /// <summary>
        /// The parameters that are KNOWN to be used in the command
        /// </summary>
        public Dictionary<string, string> Parameters = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Whether we are confident having identified all the parameters used
        /// </summary>
        public bool ParametersKnown = true;

        /// <summary>
        /// Any splats used in this command
        /// </summary>
        public Dictionary<Ast, Splat> Splats = new Dictionary<Ast, Splat>();

        /// <summary>
        /// Whether this command has any splats
        /// </summary>
        public bool HasSplat;

        /// <summary>
        /// Create a new command token off a CommandAst object
        /// </summary>
        /// <param name="Command">The Ast off which to build the Command Token</param>
        public CommandToken(CommandAst Command)
        {
            Ast = Command;
            Name = ((StringConstantExpressionAst)Command.CommandElements[0]).Value;
            var parameters = Command.CommandElements.Where(o => o.GetType() == typeof(CommandParameterAst));
            var nonParameters = Command.CommandElements.Where(o => o.GetType() != typeof(CommandParameterAst) && o != Command.CommandElements[0] && !IsSplat(o));
            foreach (CommandParameterAst parameter in parameters)
                Parameters[parameter.ParameterName] = parameter.ParameterName;
            if (parameters.Count() != nonParameters.Count())
                ParametersKnown = false;
        }

        /// <summary>
        /// Whether a given Ast object is a splat.
        /// </summary>
        /// <param name="AstObject">The Ast object to check</param>
        /// <returns>Whether a given Ast object is a splat.</returns>
        private bool IsSplat(Ast AstObject)
        {
            if (AstObject == null)
                return false;
            if (AstObject.GetType() != typeof(VariableExpressionAst))
                return false;

            return ((VariableExpressionAst)AstObject).Splatted;
        }

        /// <summary>
        /// Returns changes the token would apply.
        /// Run after calling transform
        /// </summary>
        /// <returns>The changes applied by this token after its transformation</returns>
        public override List<Change> GetChanges()
        {
            List<Change> result = new List<Change>();

            Change change = new Change();
            change.Before = Text;
            change.After = NewText;
            change.Offset = StartOffset;
            change.Path = Ast.Extent.File;
            change.Token = this;
            change.Data = Ast;
            result.Add(change);

            return result;
        }
    }
}
