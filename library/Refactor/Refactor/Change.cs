namespace Refactor
{
    /// <summary>
    /// Type representing a single script change / string replacement operation
    /// </summary>
    public class Change
    {
        /// <summary>
        /// The text before applying the change
        /// </summary>
        public string Before;

        /// <summary>
        /// The text after applying the change
        /// </summary>
        public string After;

        /// <summary>
        /// The starting index in the source code from where to begin the replacement
        /// </summary>
        public int Offset;

        /// <summary>
        /// Path of the file in which changes should be applied
        /// </summary>
        public string Path;

        /// <summary>
        /// The token generating this change
        /// </summary>
        public ScriptToken Token;

        /// <summary>
        /// Any additional data that should be included in this change object
        /// </summary>
        public object Data;

        internal bool IsValid(ScriptFile File)
        {
            int index = File.GetEffectiveIndex(Offset);
            return ScriptFile.GetStringContent(File.Content, index, Before.Length) == Before;
        }
    }
}
