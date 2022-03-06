using System;
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation.Language;
using System.Text;
using System.Threading.Tasks;

namespace Refactor
{
    /// <summary>
    /// Result of an Ast search
    /// </summary>
    public class SearchResult
    {
        /// <summary>
        /// Starting line in the file
        /// </summary>
        public int Start => Ast.Extent.StartLineNumber;

        /// <summary>
        /// Ending line in the file
        /// </summary>
        public int End => Ast.Extent.EndLineNumber;

        /// <summary>
        /// name of the file from which the searchresult came
        /// </summary>
        public string FileName => Ast.Extent.File.Split('\\','/').Last();

        /// <summary>
        /// Path to the file searched
        /// </summary>
        public string File => Ast.Extent.File;

        /// <summary>
        /// The actual Ast object
        /// </summary>
        public Ast Data => Ast;

        /// <summary>
        /// What kind of object it is
        /// </summary>
        public string Type => Ast.GetType().Name;

        private Ast Ast;

        /// <summary>
        /// Create a new search result
        /// </summary>
        /// <param name="Ast">The Ast object found</param>
        public SearchResult(Ast Ast)
        {
            if (Ast == null)
                throw new ArgumentNullException("Ast");
            this.Ast = Ast;
        }
    }
}