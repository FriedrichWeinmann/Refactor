using System.Collections.Generic;

namespace Refactor
{
    /// <summary>
    /// A generic token class, intended for all-script Token provider
    /// </summary>
    public class GenericToken : ScriptToken
    {
        /// <summary>
        /// The kind of token this is.
        /// Must match the name of the token provider to use.
        /// </summary>
        public override string Type => TokenType;
        private string TokenType;

        /// <summary>
        /// A free field to add arbitrary data
        /// </summary>
        public object Data;

        /// <summary>
        /// The changes to apply during transform
        /// </summary>
        public List<Change> Changes = new List<Change>();

        /// <summary>
        /// Returns changes the token would apply.
        /// Run after calling transform
        /// </summary>
        /// <returns>The changes applied by this token after its transformation</returns>
        public override List<Change> GetChanges()
        {
            return Changes;
        }

        /// <summary>
        /// Create a new generic token object
        /// </summary>
        /// <param name="Type">The type of the token. Must match the Token Provider name employing the object.</param>
        /// <param name="Name">The name of the token. used to match against transforms.</param>
        public GenericToken(string Type, string Name)
        {
            TokenType = Type;
            this.Name = Name;
        }
    }
}
