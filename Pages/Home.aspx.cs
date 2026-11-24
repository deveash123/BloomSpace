using System;
using System.Web.UI;

namespace BloomSpace.Pages
{
    public partial class HomePage : BloomPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["error"] == "1")
            {
                pnlGlobalError.Visible = true;
            }

            if (Request.QueryString["welcome"] == "1" && Auth.IsLoggedIn)
            {
                pnlWelcome.Visible = true;
                litWelcomeName.Text = Server.HtmlEncode(Auth.FirstName);
            }

            if (!IsPostBack)
            {
                LoadFeaturedFlowers();
            }
        }

        private void LoadFeaturedFlowers()
        {
            try
            {
                rptFeatured.DataSource = CartService.GetFeaturedFlowers(4);
                rptFeatured.DataBind();
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                pnlFeaturedError.Visible = true;
                litFeaturedError.Text =
                    "Our collection is taking a moment to load. Please refresh the page, or make sure the BloomSpaceDB database has been created.";
            }
        }
    }
}
