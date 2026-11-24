using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Web;
using BloomSpace;

public partial class Pages_CustomBouquet : System.Web.UI.Page
{
    /// <summary>Delivery fee as a plain number for the data-delivery attribute read by script.js.</summary>
    protected string DeliveryFeeAttr
    {
        get { return Money.Plain(Db.DeliveryFee); }
    }

    // The flower cards, wrapping cards and ribbon cards are written as plain HTML inputs
    // (qty_<id>, wrapping, ribbon). On postback we read them from Request.Form and
    // NEVER read a price from the browser.
    protected void Page_Load(object sender, EventArgs e)
    {
        try
        {
            RenderBuilder();
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            pnlBuilder.Visible = false;
            pnlUnavailable.Visible = true;
        }
    }

    private void RenderBuilder()
    {
        DataTable flowers = Db.Table(
            "SELECT FlowerId, Name, Category, UnitPrice, ImageUrl FROM dbo.Flowers WHERE IsActive = 1 ORDER BY Category, Name");
        DataTable wraps = Db.Table(
            "SELECT WrappingId, Name, Price, ColorHex, ImageUrl FROM dbo.WrappingSheets WHERE IsActive = 1 ORDER BY WrappingId");
        DataTable ribbons = Db.Table(
            "SELECT RibbonId, Name, Price, ColorHex, ImageUrl FROM dbo.Ribbons WHERE IsActive = 1 ORDER BY RibbonId");

        if (flowers.Rows.Count == 0 || wraps.Rows.Count == 0 || ribbons.Rows.Count == 0)
        {
            pnlBuilder.Visible = false;
            pnlUnavailable.Visible = true;
            return;
        }

        // Remember what the customer had chosen if the page is shown again after an error message.
        string postedWrap = IsPostBack ? Request.Form["wrapping"] : null;
        string postedRibbon = IsPostBack ? Request.Form["ribbon"] : null;

        // ---- Flowers, grouped by category ----
        StringBuilder sb = new StringBuilder();
        string currentCategory = null;
        bool groupOpen = false;
        foreach (DataRow r in flowers.Rows)
        {
            string category = (string)r["Category"];
            if (category != currentCategory)
            {
                if (groupOpen) sb.Append("</div>");
                sb.Append("<h3 class=\"flower-group-title\">").Append(Enc(category)).Append("</h3>");
                sb.Append("<div class=\"flower-options\">");
                groupOpen = true;
                currentCategory = category;
            }

            int id = (int)r["FlowerId"];
            string name = (string)r["Name"];
            decimal price = (decimal)r["UnitPrice"];
            string img = ResolveUrl((string)r["ImageUrl"]);

            int qty = 0;
            if (IsPostBack)
            {
                int.TryParse(Request.Form["qty_" + id], out qty);
                if (qty < 0) qty = 0;
                if (qty > CartService.MaxQty) qty = CartService.MaxQty;
            }

            sb.Append("<div class=\"flower-card\" data-id=\"").Append(id)
              .Append("\" data-price=\"").Append(Money.Plain(price))
              .Append("\" data-name=\"").Append(Attr(name))
              .Append("\" data-img=\"").Append(Attr(img)).Append("\">");
            sb.Append("<div class=\"flower-card-img\"><img src=\"").Append(Attr(img)).Append("\" alt=\"").Append(Attr(name)).Append("\" loading=\"lazy\" /></div>");
            sb.Append("<div class=\"flower-card-body\">");
            sb.Append("<h4>").Append(Enc(name)).Append("</h4>");
            sb.Append("<p class=\"flower-price\">").Append(Enc(Money.Rupees(price))).Append(" per stem</p>");
            sb.Append("<div class=\"qty-control\" role=\"group\" aria-label=\"Quantity of ").Append(Attr(name)).Append("\">");
            sb.Append("<button type=\"button\" class=\"qty-btn qty-minus\" aria-label=\"Decrease quantity\">&minus;</button>");
            sb.Append("<span class=\"qty-value\" aria-live=\"polite\">").Append(qty).Append("</span>");
            sb.Append("<button type=\"button\" class=\"qty-btn qty-plus\" aria-label=\"Increase quantity\">+</button>");
            sb.Append("</div>");
            sb.Append("<input type=\"hidden\" class=\"qty-input\" name=\"qty_").Append(id).Append("\" value=\"").Append(qty).Append("\" />");
            sb.Append("</div></div>");
        }
        if (groupOpen) sb.Append("</div>");
        litFlowers.Text = sb.ToString();

        // ---- Wrapping + ribbons ----
        litWrapping.Text = BuildOptions(wraps, "WrappingId", "wrapping", postedWrap);
        litRibbons.Text = BuildOptions(ribbons, "RibbonId", "ribbon", postedRibbon);
    }

    private string BuildOptions(DataTable table, string idColumn, string inputName, string postedValue)
    {
        // Nothing posted yet -> the first option starts selected so the estimate works straight away.
        string selectedId = postedValue;
        bool found = false;
        foreach (DataRow r in table.Rows)
        {
            if (Convert.ToString(r[idColumn]) == selectedId) found = true;
        }
        if (!found) selectedId = Convert.ToString(table.Rows[0][idColumn]);

        StringBuilder sb = new StringBuilder();
        foreach (DataRow r in table.Rows)
        {
            string id = Convert.ToString(r[idColumn]);
            string name = (string)r["Name"];
            decimal price = (decimal)r["Price"];
            string color = ((string)r["ColorHex"]).Trim();
            string img = ResolveUrl((string)r["ImageUrl"]);
            bool selected = id == selectedId;

            sb.Append("<label class=\"option-card").Append(selected ? " is-selected" : "").Append("\"")
              .Append(" data-price=\"").Append(Money.Plain(price)).Append("\"")
              .Append(" data-name=\"").Append(Attr(name)).Append("\"")
              .Append(" data-color=\"").Append(Attr(color)).Append("\">");
            sb.Append("<input type=\"radio\" name=\"").Append(inputName).Append("\" value=\"").Append(Attr(id)).Append("\"")
              .Append(selected ? " checked=\"checked\"" : "").Append(" />");
            sb.Append("<img src=\"").Append(Attr(img)).Append("\" alt=\"\" loading=\"lazy\" />");
            sb.Append("<span class=\"option-name\">").Append(Enc(name)).Append("</span>");
            sb.Append("<span class=\"option-price\">+ ").Append(Enc(Money.Rupees(price))).Append("</span>");
            sb.Append("</label>");
        }
        return sb.ToString();
    }

    protected void btnAddBouquet_Click(object sender, EventArgs e)
    {
        // Must be logged in to have a cart.
        AuthHelper.RequireLogin(this);

        // 1. Read ONLY ids and quantities from the form. No prices are accepted from the browser.
        Dictionary<int, int> chosen = new Dictionary<int, int>();
        foreach (string key in Request.Form.AllKeys)
        {
            if (key == null || !key.StartsWith("qty_", StringComparison.Ordinal)) continue;

            int flowerId, qty;
            if (int.TryParse(key.Substring(4), out flowerId) &&
                int.TryParse(Request.Form[key], out qty) && qty > 0)
            {
                chosen[flowerId] = qty;
            }
        }

        int wrappingId, ribbonId;
        if (!int.TryParse(Request.Form["wrapping"], out wrappingId) ||
            !int.TryParse(Request.Form["ribbon"], out ribbonId))
        {
            ShowError("Please choose a wrapping paper and a ribbon.");
            return;
        }

        // 2. The service checks every id against SQL Server and saves the bouquet.
        string error;
        bool ok;
        try
        {
            ok = CartService.AddBouquet(AuthHelper.CurrentUserId, chosen, wrappingId, ribbonId, out error);
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowError("Sorry, we could not add your bouquet right now. Please try again in a moment.");
            return;
        }

        if (!ok)
        {
            ShowError(error);
            return;
        }

        Response.Redirect("~/Pages/Cart.aspx?added=bouquet");
    }

    private void ShowError(string message)
    {
        litMessage.Text = HttpUtility.HtmlEncode(message);
        pnlMessage.Visible = true;
    }

    private static string Enc(string s) { return HttpUtility.HtmlEncode(s); }
    private static string Attr(string s) { return HttpUtility.HtmlAttributeEncode(s); }
}
