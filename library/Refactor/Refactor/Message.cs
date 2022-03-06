namespace Refactor
{
    /// <summary>
    /// Status message of a transformation action
    /// </summary>
    public class Message
    {
        /// <summary>
        /// What level of information are we talking about?
        /// </summary>
        public MessageType Type = MessageType.Information;

        /// <summary>
        /// The actual message text
        /// </summary>
        public string Text;

        /// <summary>
        /// Any additional data to attach to the message
        /// </summary>
        public object Data;

        /// <summary>
        /// The Token on which things went wrong
        /// </summary>
        public ScriptToken Token;

        /// <summary>
        /// Create a new message object
        /// </summary>
        /// <param name="Type">What level of information are we talking about?</param>
        /// <param name="Text">The actual message text</param>
        /// <param name="Data">Any additional data to attach to the message</param>
        /// <param name="Token">The Token on which things went wrong</param>
        public Message(MessageType Type, string Text, object Data, ScriptToken Token)
        {
            this.Type = Type;
            this.Text = Text;
            this.Data = Data;
            this.Token = Token;
        }
    }
}
