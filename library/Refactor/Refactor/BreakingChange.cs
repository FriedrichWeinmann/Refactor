using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Refactor
{
    /// <summary>
    /// Result Container for a Breaking Change Scan
    /// </summary>
    public class BreakingChange
    {
        // Code Metadata
        /// <summary>
        /// Path to the file being scanned
        /// </summary>
        public string Path;

        /// <summary>
        /// Name of the file being scanned
        /// </summary>
        public string Name;

        /// <summary>
        /// Line within the file where the result was found
        /// </summary>
        public int Line;

        // Command Data
        /// <summary>
        /// Name of the command that represents a breaking change
        /// </summary>
        public string Command;

        /// <summary>
        /// Name of the parameter affected by the breaking change
        /// </summary>
        public string Parameter;

        // Message
        /// <summary>
        /// What kind of break message is this. Generally only errors or warnings.
        /// </summary>
        public MessageType Type;

        /// <summary>
        /// Description of the breaking change
        /// </summary>
        public string Description;

        // Breaking Change Metadata
        /// <summary>
        /// Name of the module the command is from
        /// </summary>
        public string Module;

        /// <summary>
        /// Version in which the breaking change was introduced
        /// </summary>
        public string Version;

        /// <summary>
        /// Tags assigned to this breaking change
        /// </summary>
        public string[] Tags;
    }
}
