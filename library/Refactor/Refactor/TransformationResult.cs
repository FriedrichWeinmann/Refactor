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
    }
}
