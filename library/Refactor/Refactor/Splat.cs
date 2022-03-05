using System;
using System.Collections.Generic;
using System.Management.Automation.Language;

namespace Refactor
{
    /// <summary>
    /// A splat object, including the resolved parameters it will potentially bind
    /// </summary>
    public class Splat
    {
        /// <summary>
        /// Ast of the splat binding.
        /// NOT of where the hashtable is first declared, but where it is ultimately used.
        /// </summary>
        public Ast Ast;

        /// <summary>
        /// Parameters bound through the splat
        /// </summary>
        public Dictionary<string, string> Parameters = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);

        /// <summary>
        /// Whether we can authoratively claim to know which parameters may be bound through this splat.
        /// </summary>
        public bool ParametersKnown = true;
    }
}
