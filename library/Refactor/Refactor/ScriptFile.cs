using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Management.Automation.Language;
using System.Text;
using System.Text.RegularExpressions;

namespace Refactor
{
    /// <summary>
    /// Wrapper around a scriptfile, base from which tokens are generated and transform results are written back to
    /// </summary>
    public class ScriptFile
    {
        /// <summary>
        /// Path to the file being processed
        /// </summary>
        public string Path
        {
            get => String.IsNullOrEmpty(_Path) ? _Name : _Path;
            set => _Path = value;
        }
        private string _Path;
        private string _Name;

        /// <summary>
        /// Original AST of the file being processed
        /// </summary>
        public Ast Ast;

        /// <summary>
        /// Any modification loci and length that have previously been applied to the file.
        /// This is to ensure, that anything modified does not affect other transformations that were generated before said modification.
        /// </summary>
        public Dictionary<int, int> Modifiers = new Dictionary<int, int>();

        /// <summary>
        /// Actual string content of the file after modifications
        /// </summary>
        public string Content;
        private string _OriginalContent;

        /// <summary>
        /// Whether the current modifications have been written back to file
        /// </summary>
        public bool Saved
        {
            get
            {
                if (!String.IsNullOrEmpty(_Path))
                    return Content == File.ReadAllText(Path);
                return false;
            }
        }

        /// <summary>
        /// Generate a new scriptfile object off the path to a scriptfile
        /// </summary>
        /// <param name="Path">Path to the file being wrapped</param>
        public ScriptFile(string Path)
        {
            this.Path = Path;
            Ast = GetAst(Path);
            Reload();
        }

        /// <summary>
        /// Generate a new scriptfile object off the content of a scriptcode without any backing file
        /// </summary>
        /// <param name="Name">The name of the content</param>
        /// <param name="Content">The actual script code / content of the script</param>
        public ScriptFile(string Name, string Content)
        {
            _OriginalContent = Content;
            _Name = Name;
            Reload();
        }

        /// <summary>
        /// Applies the current state of the wrapped file to this in-memory object
        /// </summary>
        public void Reload()
        {
            Modifiers = new Dictionary<int, int>();

            if (!String.IsNullOrEmpty(_Path))
            {
                Content = File.ReadAllText(_Path);
                Ast = GetAst(Path);
            }
            else
            {
                Content = _OriginalContent;
                Ast = GetAstFromText(Content);
            }
        }

        /// <summary>
        /// Writes back the current Content back to file, saving all modifications applied so far.
        /// </summary>
        /// <param name="Backup">Whether to create a backup of the previous state. This will create a copy of that file in the same folder with ".backup" appended to the name.</param>
        public void Save(bool Backup = false)
        {
            if (String.IsNullOrEmpty(_Path))
                throw new InvalidOperationException("Cannot save a script that was not originally read from file!");

            if (Backup)
                File.Copy(Path, Regex.Replace(Path, "\\.([^\\.]+)$", ".backup.$1"), true);
            File.WriteAllText(Path, Content, new UTF8Encoding(true));
            Reload();
        }

        /// <summary>
        /// Returnes the starting index (or offset) in a file for a given original index, after taking modifications into consideration.
        /// </summary>
        /// <param name="Index">Index number as originally parsed out of the file</param>
        /// <returns>The effective index number / offset to use instead for the current state.</returns>
        public int GetEffectiveIndex(int Index)
        {
            int newIndex = Index;

            foreach (var entry in Modifiers)
                if (entry.Key < Index)
                    newIndex = newIndex + entry.Value;

            return newIndex;
        }

        /// <summary>
        /// Returns a list of all tokens, generated from all token providers that have been registered
        /// </summary>
        /// <param name="Provider">A list of provider-names to filter by</param>
        /// <returns>The processed tokens</returns>
        public ScriptToken[] GetTokens(string[] Provider = null)
        {
            List<ScriptToken> tokens = new List<ScriptToken>();

            List<ScriptBlock> providers = new List<ScriptBlock>();

            using (PowerShell runspace = PowerShell.Create(RunspaceMode.CurrentRunspace))
            {
                runspace.AddCommand(Host.ProviderCommand);
                runspace.AddParameter("Component", "Tokenizer");
                if (Provider != null)
                    runspace.AddParameter("Name", Provider);
                foreach (ScriptBlock result in runspace.Invoke<ScriptBlock>())
                    providers.Add(result);
            }

            using (PowerShell runspace = PowerShell.Create(RunspaceMode.CurrentRunspace))
            {
                foreach (ScriptBlock provider in providers)
                {
                    runspace.AddScript(provider.ToString());
                    runspace.AddArgument(Ast);
                    foreach (ScriptToken result in runspace.Invoke<ScriptToken>())
                        tokens.Add(result);
                }
            }
            return tokens.ToArray();
        }

        /// <summary>
        /// Apply all transforms to the tokens specified
        /// </summary>
        /// <param name="Tokens">The tokens to transform</param>
        /// <returns>A result object, reporting the state of each individual transformation</returns>
        public TransformationResult Transform(ScriptToken[] Tokens)
        {
            TransformationResult results = new TransformationResult(Path);

            foreach (ScriptToken token in Tokens)
            {
                results.PrepMessages(token);

                try { token.Transform(); }
                catch (Exception e)
                {
                    results.Results.Add(new TransformationResultEntry(Path, false, null, token, $"Error transforming { token.Type } : { e.Message }", e));
                    results.DrainMessages(token);
                    continue;
                }

                // Check Change validity
                int total = token.GetChanges().Count;
                int valid = token.GetChanges().Where(o => o.IsValid(this)).Count();
                if (!token.AllowPartial && total > valid)
                {
                    results.Results.Add(new TransformationResultEntry(Path, false, null, token, "Text already modified! This usually happens when applying multiple transformations to the same region of code. Reload file and scan for tokens before proceeding."));
                    results.DrainMessages(token);
                    continue;
                }

                // Apply Changes
                foreach (Change change in token.GetChanges().Where(o => o.IsValid(this)))
                {
                    int index = GetEffectiveIndex(change.Offset);
                    Content = Content.Substring(0, index) + change.After + Content.Substring(index + change.Before.Length);
                    Modifiers[change.Offset] = change.After.Length - change.Before.Length;
                    results.Results.Add(new TransformationResultEntry(Path, true, change, token));
                }
                results.DrainMessages(token);
            }

            return results;
        }

        /// <summary>
        /// Get the Ast representing the code in the file specified.
        /// Ignores all syntax errors
        /// </summary>
        /// <param name="Path">Path to the file to parse</param>
        /// <returns>The Ast object representing the file specified</returns>
        public static Ast GetAst(string Path)
        {
            var tokens = new Token[0];
            var errors = new ParseError[0];
            return Parser.ParseFile(Path, out tokens, out errors);
        }

        /// <summary>
        /// Get the Ast representing the code in the text specified.
        /// Ignores all syntax errors
        /// </summary>
        /// <param name="Content">The text content to parse</param>
        /// <returns>The Ast object representing the text specified</returns>
        public static Ast GetAstFromText(string Content)
        {
            var tokens = new Token[0];
            var errors = new ParseError[0];
            return Parser.ParseInput(Content, out tokens, out errors);
        }

        /// <summary>
        /// Safely returns the substring of the input string without exception.
        /// Bad indexes will result in either an empty string or a string of unexpected length.
        /// </summary>
        /// <param name="Content">The source string to process</param>
        /// <param name="Start">The start index from where to read</param>
        /// <param name="Length">How many characters to read</param>
        /// <returns>The selected substring</returns>
        internal static string GetStringContent(string Content, int Start, int Length)
        {
            if (Start > Content.Length)
                return "";
            if (Start + Length > Content.Length)
                return Content.Substring(Start);
            return Content.Substring(Start, Length);
        }
    }
}
