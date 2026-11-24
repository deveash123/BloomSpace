using System;
using System.Web;
using System.Web.UI;

namespace BloomSpace
{
    public partial class SiteMaster : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            bool loggedIn = Auth.IsLoggedIn;

            pnlLoggedIn.Visible = loggedIn;
            pnlGuest.Visible = !loggedIn;
            pnlMobileLoggedIn.Visible = loggedIn;
            pnlMobileGuest.Visible = !loggedIn;

            if (loggedIn)
            {
                string firstName = HttpUtility.HtmlEncode(Auth.FirstName);
                litFirstName.Text = firstName;
                litMobileFirstName.Text = firstName;
            }

            int cartCount = 0;

            try
            {
                int? userId = Auth.CurrentUserId;

                if (userId.HasValue)
                {
                    cartCount = CartService.GetCartCount(userId.Value);
                }
            }
            catch (Exception exception)
            {
                // A catalogue problem must not break the shared header.
                Logger.Log(exception);
            }

            litCartCount.Text = cartCount.ToString();
            litYear.Text = DateTime.Now.Year.ToString();
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Auth.SignOut();
            Response.Redirect("~/Pages/Home.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected string NavClass(string path)
        {
            string current = Request.AppRelativeCurrentExecutionFilePath ?? string.Empty;

            if (string.Equals(current, path, StringComparison.OrdinalIgnoreCase))
            {
                return "active";
            }

            // The site may be opened at "/" (default document resolves to Home).
            if (path.EndsWith("Home.aspx", StringComparison.OrdinalIgnoreCase) &&
                (current == "~/" || current.EndsWith("/Default.aspx", StringComparison.OrdinalIgnoreCase)))
            {
                return "active";
            }

            return string.Empty;
        }

        public string HomeClass { get { return NavClass("~/Pages/Home.aspx"); } }
        public string ShopClass { get { return NavClass("~/Pages/Shop.aspx"); } }
        public string CustomClass { get { return NavClass("~/Pages/CustomBouquet.aspx"); } }
        public string AboutClass { get { return NavClass("~/Pages/About.aspx"); } }
        public string ContactClass { get { return NavClass("~/Pages/Contact.aspx"); } }
    }
}
