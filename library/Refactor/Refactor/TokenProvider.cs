using System.Management.Automation;

namespace Refactor
{
    /// <summary>
    /// All the information needed to process a specific tokentype
    /// </summary>
    public class TokenProvider
    {
        /// <summary>
        /// Name of the provider
        /// </summary>
        public string Name;
        /// <summary>
        /// The property to use for indexing transforms
        /// </summary>
        public string TransformIndex;
        /// <summary>
        /// The parameters that must be specified when registering transforms
        /// </summary>
        public string[] TransformParametersMandatory;
        /// <summary>
        /// The parameters that may be specified when registering transforms.
        /// Use to build out dynamic parameters for the specific register call
        /// </summary>
        public string[] TransformParameters;
        /// <summary>
        /// Code that parses an Ast provided and generates tokens from it
        /// </summary>
        public ScriptBlock Tokenizer;
        /// <summary>
        /// Code that takes a token and applies relevant transforms to it
        /// </summary>
        public ScriptBlock Converter;
    }
}
