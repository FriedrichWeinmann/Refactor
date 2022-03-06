using System;

namespace Refactor
{
    /// <summary>
    /// Result of a single token transformation
    /// </summary>
    public class TransformationResultEntry
    {
        /// <summary>
        /// Whether the transformation was successful
        /// </summary>
        public bool Success;

        /// <summary>
        /// The change implemented
        /// </summary>
        public Change Change;

        /// <summary>
        /// The Token the transformation was applied to
        /// </summary>
        public ScriptToken Token;

        /// <summary>
        /// Any message included in the transformation
        /// </summary>
        public string Message;

        /// <summary>
        /// Any errors that happened during execution
        /// </summary>
        public Exception Error;

        /// <summary>
        /// Path to the file being transformed
        /// </summary>
        public string Path;

        /// <summary>
        /// Create a new, empty transformation result entry
        /// </summary>
        public TransformationResultEntry()
        {

        }
        /// <summary>
        /// Create a new, filled out transformation result entry
        /// </summary>
        /// <param name="Path">Path to the file being transformed</param>
        /// <param name="Success">Whether the transformation was successful</param>
        /// <param name="Change">The actual change that was performed</param>
        /// <param name="Token">The Token the transformation was applied to</param>
        /// <param name="Message">Any message included in the transformation</param>
        /// <param name="Error">Any errors that happened during execution</param>
        public TransformationResultEntry(string Path, bool Success, Change Change, ScriptToken Token, string Message = "", Exception Error = null)
        {
            this.Path = Path;
            this.Success = Success;
            this.Change = Change;
            this.Message = Message;
            this.Token = Token;
            this.Error = Error;
        }
    }
}
