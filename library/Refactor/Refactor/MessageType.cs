namespace Refactor
{
    /// <summary>
    /// The category of a Message object
    /// </summary>
    public enum MessageType
    {
        /// <summary>
        /// General Information
        /// </summary>
        Information = 1,

        /// <summary>
        /// Something was not entirely a success
        /// </summary>
        Warning = 2,

        /// <summary>
        /// Something went really wrong
        /// </summary>
        Error = 3
    }
}
