using System.Collections.Generic;
using System.Linq;

namespace Refactor
{
    /// <summary>
    /// Result of all changes applied to a single file
    /// </summary>
    public class TransformationResult
    {
        /// <summary>
        /// path to the file being transformed
        /// </summary>
        public string Path;
        /// <summary>
        /// Name of the file being transformed
        /// </summary>
        public string FileName { get { return new System.IO.FileInfo(Path).Name; } }
        /// <summary>
        /// Whether the transformation was 100 successful
        /// </summary>
        public bool Success { get { return Results.Where(o => !o.Success).Count() == 0; } }
        /// <summary>
        /// Count of transformations executed
        /// </summary>
        public int Count { get { return Results.Count; } }
        /// <summary>
        /// Count of successful transformations executed
        /// </summary>
        public int SuccessCount { get { return Results.Where(o => o.Success).Count(); } }

        /// <summary>
        /// Number of information messages written during the transformation
        /// </summary>
        public int InfoCount => Messages.Where(o => o.Type == MessageType.Information).Count();
        /// <summary>
        /// Number of warning messages written during the transformation
        /// </summary>
        public int WarningCount => Messages.Where(o => o.Type == MessageType.Warning).Count();
        /// <summary>
        /// Number of error messages written during the transformation
        /// </summary>
        public int ErrorCount => Messages.Where(o => o.Type == MessageType.Error).Count();

        /// <summary>
        /// All individual transformation results that have been applied - successful or otherwise
        /// </summary>
        public List<TransformationResultEntry> Results = new List<TransformationResultEntry>();

        /// <summary>
        /// Create a new transformation result report
        /// </summary>
        /// <param name="Path">Path to the script file being transformed</param>
        public TransformationResult(string Path)
        {
            this.Path = Path;
        }

        #region ScriptFile Transform Message handling
        /// <summary>
        /// The messages that happened during this transformation
        /// </summary>
        public List<Message> Messages = new List<Message>();

        /// <summary>
        /// Copy over all messages from the token object and restore the original messages
        /// </summary>
        /// <param name="Token">The token to drain the messages from</param>
        internal void DrainMessages(ScriptToken Token)
        {
            Messages.AddRange(Token.Messages);
            Token.Messages = tokenOriginalMessages;
        }

        /// <summary>
        /// Cache the current messages and create a new list just for this transformation
        /// </summary>
        /// <param name="Token">The Token for which to prep the messages</param>
        internal void PrepMessages(ScriptToken Token)
        {
            tokenOriginalMessages = Token.Messages;
            Token.Messages = new List<Message>();
        }
        private List<Message> tokenOriginalMessages;
        #endregion ScriptFile Transform Message handling
    }
}