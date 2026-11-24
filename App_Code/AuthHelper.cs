using System;
using System.Web;
using System.Web.UI;

namespace BloomSpace
{
    /// <summary>Session-based login helpers.</summary>
    public static class AuthHelper
    {
        private const string KeyId = "BS_UserId";
        private const string KeyName = "BS_UserName";

        public static int CurrentUserId
        {
            get
            {
                HttpContext ctx = HttpContext.Current;
                if (ctx == null || ctx.Session == null) return 0;
                object v = ctx.Session[KeyId];
                return (v is int) ? (int)v : 0;
            }
        }

        public static string CurrentUserName
        {
            get
            {
                HttpContext ctx = HttpContext.Current;
                if (ctx == null || ctx.Session == null) return "";
                return ctx.Session[KeyName] as string ?? "";
            }
        }

        public static bool IsLoggedIn
        {
            get { return CurrentUserId > 0; }
        }

        /// <summary>Starts a clean session for the user.</summary>
        public static void SignIn(int userId, string fullName)
        {
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session[KeyId] = userId;
            HttpContext.Current.Session[KeyName] = fullName;
        }

        public static void SignOut()
        {
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session.Abandon();
        }

        /// <summary>Sends visitors who are not logged in to the login page, then brings them back afterwards.</summary>
        public static void RequireLogin(Page page)
        {
            if (!IsLoggedIn)
            {
                string back = HttpUtility.UrlEncode(page.Request.RawUrl);
                page.Response.Redirect("~/Account/Login.aspx?returnUrl=" + back, true);
            }
        }

        /// <summary>
        /// Only allows local return addresses (blocks open-redirect tricks such as //evil.com).
        /// </summary>
        public static string SafeReturnUrl(string url, string fallback)
        {
            if (string.IsNullOrWhiteSpace(url)) return fallback;
            if (!url.StartsWith("/") || url.StartsWith("//") || url.StartsWith("/\\")) return fallback;
            return url;
        }
    }
}
