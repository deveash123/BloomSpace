using System;
using System.Web.UI;

namespace BloomSpace
{
    /// <summary>
    /// Base page for every .aspx file.
    /// Binds ViewState to the session (a small anti-CSRF hardening measure)
    /// and writes unexpected errors to App_Data/Logs.
    /// </summary>
    public class BloomPage : Page
    {
        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Auth.IsLoggedIn && Session != null)
            {
                ViewStateUserKey = Session.SessionID;
            }
        }

        protected override void OnError(EventArgs e)
        {
            Exception exception = Server.GetLastError();

            if (exception != null)
            {
                Logger.Log(exception);
            }

            base.OnError(e);
        }
    }
}
