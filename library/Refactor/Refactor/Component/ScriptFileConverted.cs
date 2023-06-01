using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Refactor.Component
{
    /// <summary>
    /// A summary object of a post-conversion scriptfile that was generated from Write-ReAstComponent.
    /// </summary>
    public class ScriptFileConverted
    {
        /// <summary>
        /// Name of the file converted
        /// </summary>
        public string Name;

        /// <summary>
        /// Path to the file that was converted (whether in situ or via OutPath to another path, this points at the original source)
        /// </summary>
        public string Path;

        /// <summary>
        /// Text-content of the file after it was transformed.
        /// </summary>
        public string Text;

        /// <summary>
        /// The ID of the search result that was converted. Just in case one needs to track things.
        /// </summary>
        public string ConversionID { get => Result.ID; }

        private ScriptResult Result;

        /// <summary>
        /// Create a new script file object representing a converted object.
        /// </summary>
        /// <param name="Result">The search result that was applied.</param>
        public ScriptFileConverted(ScriptResult Result)
        {
            this.Result = Result;
            Path = Result.File.Path;
            Name = Result.File.Path.Split('\\', '/').Last();
            Text = Result.File.Content;
        }
    }
}