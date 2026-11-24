using System;
using System.IO;
using System.Web;

namespace BloomSpace
{
    /// <summary>
    /// Writes unexpected exceptions to App_Data/Logs so the developer can
    /// inspect them, while customers only ever see a friendly message.
    /// </summary>
    public static class Logger
    {
        private static readonly object SyncRoot = new object();

        public static void Log(Exception exception)
        {
            if (exception == null || exception is System.Threading.ThreadAbortException)
            {
                return;
            }

            try
            {
                string folder;

                if (HttpContext.Current != null)
                {
                    folder = HttpContext.Current.Server.MapPath("~/App_Data/Logs");
                }
                else
                {
                    folder = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "App_Data", "Logs");
                }

                Directory.CreateDirectory(folder);

                string file = Path.Combine(
                    folder,
                    "errors-" + DateTime.Now.ToString("yyyy-MM-dd") + ".log");

                string entry =
                    "==============================================================" + Environment.NewLine +
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + Environment.NewLine +
                    exception.ToString() + Environment.NewLine + Environment.NewLine;

                lock (SyncRoot)
                {
                    File.AppendAllText(file, entry);
                }
            }
            catch
            {
                // Logging must never take the website down.
            }
        }
    }
}
