using System;
using System.Web;
using System.Web.UI;

namespace BloomSpace
{
    /// <summary>
    /// Session-based authentication helpers.
    /// Only the user id, name and email are kept in session - never a password.
    /// </summary>
    public static class Auth
    {
        public const string SessionUserId = "BloomUserId";
        public const string SessionUserName = "BloomUserName";
        public const string SessionUserEmail = "BloomUserEmail";

        public static int? CurrentUserId
        {
            get
            {
                HttpContext context = HttpContext.Current;

                if (context == null || context.Session == null)
                {
                    return null;
                }

                object value = context.Session[SessionUserId];

                if (value == null)
                {
                    return null;
                }

                int id;

                if (int.TryParse(Convert.ToString(value), out id) && id > 0)
                {
                    return id;
                }

                return null;
            }
        }

        public static string CurrentUserName
        {
            get
            {
                HttpContext context = HttpContext.Current;

                if (context == null || context.Session == null)
                {
                    return string.Empty;
                }

                return Convert.ToString(context.Session[SessionUserName]) ?? string.Empty;
            }
        }

        public static string CurrentUserEmail
        {
            get
            {
                HttpContext context = HttpContext.Current;

                if (context == null || context.Session == null)
                {
                    return string.Empty;
                }

                return Convert.ToString(context.Session[SessionUserEmail]) ?? string.Empty;
            }
        }

        public static bool IsLoggedIn
        {
            get { return CurrentUserId.HasValue; }
        }

        public static string FirstName
        {
            get
            {
                string name = CurrentUserName.Trim();

                if (name.Length == 0)
                {
                    return "there";
                }

                int space = name.IndexOf(' ');

                return space > 0 ? name.Substring(0, space) : name;
            }
        }

        public static void SignIn(int userId, string fullName, string email)
        {
            HttpContext context = HttpContext.Current;

            if (context == null || context.Session == null)
            {
                throw new InvalidOperationException("Session is not available.");
            }

            // Clear any previous session data (limits session fixation risk).
            context.Session.Clear();

            context.Session[SessionUserId] = userId;
            context.Session[SessionUserName] = fullName ?? string.Empty;
            context.Session[SessionUserEmail] = email ?? string.Empty;
        }

        public static void SignOut()
        {
            HttpContext context = HttpContext.Current;

            if (context == null)
            {
                return;
            }

            if (context.Session != null)
            {
                context.Session.Clear();
                context.Session.Abandon();
            }
        }

        /// <summary>
        /// Redirects guests to the login page and remembers where they were going.
        /// Returns false when a redirect has been started, so callers can simply
        /// <c>if (!Auth.RequireLogin(this)) return;</c>
        /// </summary>
        public static bool RequireLogin(Page page)
        {
            if (page == null)
            {
                return false;
            }

            if (IsLoggedIn)
            {
                return true;
            }

            string returnUrl = page.Request.RawUrl ?? "~/Pages/Home.aspx";

            page.Response.Redirect(
                "~/Account/Login.aspx?returnUrl=" + HttpUtility.UrlEncode(returnUrl),
                false);

            HttpContext.Current.ApplicationInstance.CompleteRequest();
            return false;
        }

        /// <summary>
        /// Only accepts application-relative return URLs, preventing open redirects.
        /// </summary>
        public static string SafeReturnUrl(string returnUrl, string fallback)
        {
            if (string.IsNullOrWhiteSpace(returnUrl))
            {
                return fallback;
            }

            string value = returnUrl.Trim();

            if (value.StartsWith("~/", StringComparison.Ordinal))
            {
                return value;
            }

            if (value.StartsWith("/", StringComparison.Ordinal) &&
                !value.StartsWith("//", StringComparison.Ordinal))
            {
                return "~" + value;
            }

            return fallback;
        }
    }
}
