using System;
using System.Web;
using System.Web.UI;
using BloomSpace;

/// <summary>Code-behind for the shared layout (header, footer, login state, cart badge).</summary>
public partial class SiteMaster : MasterPage
{
    protected void Page_Load(object sender, EventArgs e)
    {
        litFee.Text = Money.Rupees(Db.DeliveryFee);

        // Make every page title read "Page | Bloom Space".
        if (Page != null && !string.IsNullOrEmpty(Page.Title) && !Page.Title.EndsWith("Bloom Space"))
        {
            Page.Title = Page.Title + " | Bloom Space";
        }
    }

    // PreRender runs after button clicks, so the cart badge is always up to date.
    protected void Page_PreRender(object sender, EventArgs e)
    {
        bool loggedIn = AuthHelper.IsLoggedIn;
        phGuest.Visible = !loggedIn;
        phUser.Visible = loggedIn;

        litCartBadge.Text = "";
        if (loggedIn)
        {
            string name = AuthHelper.CurrentUserName.Trim();
            int space = name.IndexOf(' ');
            string first = space > 0 ? name.Substring(0, space) : name;
            litName.Text = HttpUtility.HtmlEncode(first);

            try
            {
                int stems = CartService.StemCount(AuthHelper.CurrentUserId);
                if (stems > 0)
                {
                    litCartBadge.Text = "<span class=\"cart-badge\">" + stems + "</span>";
                }
            }
            catch (Exception ex)
            {
                ErrorLog.Write(ex);
            }
        }
    }

    protected void lbLogout_Click(object sender, EventArgs e)
    {
        AuthHelper.SignOut();
        Response.Redirect("~/Pages/Home.aspx");
    }

    /// <summary>Returns "active" for the navigation link of the page being viewed.</summary>
    protected string Active(string pageName)
    {
        string path = Request.Path ?? "";
        return path.EndsWith("/" + pageName, StringComparison.OrdinalIgnoreCase) ? "active" : "";
    }
}
