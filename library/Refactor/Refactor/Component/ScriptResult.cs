using Refactor;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Refactor.Component
{
    /// <summary>
    /// Result of a single token scan using Read-ReAstComponent
    /// </summary>
    public class ScriptResult
    {
        /// <summary>
        /// The scriptfile scanned
        /// </summary>
        public ScriptFile File;

        /// <summary>
        /// The list of tokens found
        /// </summary>
        public List<AstToken> Tokens = new List<AstToken>();

        /// <summary>
        /// The types of AST scanned for.
        /// </summary>
        public string[] Types;

        /// <summary>
        /// Unique ID to differentiate between the executions
        /// </summary>
        public readonly string ID = Guid.NewGuid().ToString();

        /// <summary>
        /// Default string display of this object
        /// </summary>
        /// <returns>The ID of the scan</returns>
        public override string ToString()
        {
            return ID;
        }
    }
}
