namespace Refactor
{
    /// <summary>
    /// Global tools, data and settings related to the Refactor module library
    /// </summary>
    public static class Host
    {
        /// <summary>
        /// Command used to list all available token providers
        /// </summary>
        public static string ProviderCommand = "Get-ASTokenProvider";

        /// <summary>
        /// Command used convert tokens
        /// </summary>
        public static string TransformCommand = "Convert-ASScriptToken";
    }
}
