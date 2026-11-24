using System;
using System.Data;
using System.Web;
using System.Web.UI.WebControls;
using BloomSpace;

public partial class Pages_Shop : System.Web.UI.Page
{
    private static readonly string[] Categories = { "Roses", "Tulips", "Lilies", "Sunflowers" };

    /// <summary>The category from ?category=... (only the four known names are accepted), or null for "All".</summary>
    private string CurrentCategory
    {
        get
        {
            string c = Request.QueryString["category"];
            return (c != null && Array.IndexOf(Categories, c) >= 0) ? c : null;
        }
    }

    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        if (Request.QueryString["added"] == "1")
        {
            ShowMessage("Added to your cart. <a href=\"" + HttpUtility.HtmlAttributeEncode(ResolveUrl("~/Pages/Cart.aspx")) + "\">View cart</a>", false);
        }
        else if (Request.QueryString["error"] == "1")
        {
            ShowMessage("Sorry, that flower could not be added. Please try again.", true);
        }

        BindProducts();
    }

    private void BindProducts()
    {
        try
        {
            string cat = CurrentCategory;
            DataTable dt;
            if (cat == null)
            {
                dt = Db.Table(@"SELECT FlowerId, Name, Category, Description, UnitPrice, ImageUrl
                                FROM dbo.Flowers WHERE IsActive = 1 ORDER BY Category, Name");
            }
            else
            {
                dt = Db.Table(@"SELECT FlowerId, Name, Category, Description, UnitPrice, ImageUrl
                                FROM dbo.Flowers WHERE IsActive = 1 AND Category = @c ORDER BY Name",
                              Db.P("@c", cat));
            }

            rptProducts.DataSource = dt;
            rptProducts.DataBind();
            pnlProducts.Visible = dt.Rows.Count > 0;
            pnlEmpty.Visible = dt.Rows.Count == 0;
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            pnlProducts.Visible = false;
            pnlEmpty.Visible = false;
            ShowMessage("Sorry, we could not load the flowers right now. Please try again shortly.", true);
        }
    }

    protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        if (e.CommandName != "add") return;

        // Only logged-in customers have a cart; guests are sent to log in and then brought back here.
        AuthHelper.RequireLogin(this);

        int flowerId;
        bool ok = false;
        if (int.TryParse(Convert.ToString(e.CommandArgument), out flowerId))
        {
            try
            {
                ok = CartService.AddSingle(AuthHelper.CurrentUserId, flowerId, 1);
            }
            catch (Exception ex)
            {
                ErrorLog.Write(ex);
            }
        }

        string cat = CurrentCategory;
        string url = "~/Pages/Shop.aspx?" + (cat != null ? "category=" + cat + "&" : "") + (ok ? "added=1" : "error=1");
        Response.Redirect(url);
    }

    private void ShowMessage(string html, bool isError)
    {
        litMessage.Text = isError ? HttpUtility.HtmlEncode(html) : html;   // html is built by this file only
        pnlMessage.CssClass = isError ? "alert alert-error" : "alert alert-success";
        pnlMessage.Visible = true;
    }

    /// <summary>Returns "active" for the filter pill that matches the current category.</summary>
    protected string Tab(string category)
    {
        return string.Equals(CurrentCategory, category, StringComparison.Ordinal) ? "active" : "";
    }
}
