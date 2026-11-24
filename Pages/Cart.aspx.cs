using System;
using System.Data;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using BloomSpace;

public partial class Pages_Cart : System.Web.UI.Page
{
    private const int MaxDaysAhead = 60;

    private DataTable _wraps;
    private DataTable _ribbons;

    protected void Page_Load(object sender, EventArgs e)
    {
        // Cart and checkout are for logged-in customers only.
        AuthHelper.RequireLogin(this);

        if (IsPostBack) return;

        if (Request.QueryString["added"] == "bouquet")
        {
            ShowMessage("Your custom bouquet has been added to your cart.", false);
        }

        PrefillCheckout();
        BindCart();
    }

    // ------------------------------------------------------------------ binding

    private void BindCart()
    {
        try
        {
            CartSummary cart = CartService.Load(AuthHelper.CurrentUserId);

            pnlEmpty.Visible = cart.IsEmpty;
            pnlCart.Visible = !cart.IsEmpty;
            if (cart.IsEmpty) return;

            _wraps = Db.Table("SELECT WrappingId, Name, Price FROM dbo.WrappingSheets WHERE IsActive = 1 ORDER BY WrappingId");
            _ribbons = Db.Table("SELECT RibbonId, Name, Price FROM dbo.Ribbons WHERE IsActive = 1 ORDER BY RibbonId");

            rptGroups.DataSource = cart.Groups;
            rptGroups.DataBind();

            litSubtotal.Text = HttpUtility.HtmlEncode(Money.Rupees(cart.Subtotal));
            litDelivery.Text = HttpUtility.HtmlEncode(Money.Rupees(cart.DeliveryFee));
            litTotal.Text = HttpUtility.HtmlEncode(Money.Rupees(cart.Total));
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            pnlCart.Visible = false;
            pnlEmpty.Visible = false;
            ShowMessage("Sorry, we could not load your cart right now. Please try again shortly.", true);
        }
    }

    protected void rptGroups_ItemDataBound(object sender, RepeaterItemEventArgs e)
    {
        if (e.Item.ItemType != ListItemType.Item && e.Item.ItemType != ListItemType.AlternatingItem) return;

        CartGroup group = (CartGroup)e.Item.DataItem;

        Repeater items = (Repeater)e.Item.FindControl("rptItems");
        items.DataSource = group.Items;
        items.DataBind();

        if (group.IsBouquet)
        {
            DropDownList ddlWrap = (DropDownList)e.Item.FindControl("ddlWrap");
            DropDownList ddlRibbon = (DropDownList)e.Item.FindControl("ddlRibbon");
            FillOptions(ddlWrap, _wraps, "WrappingId", group.WrappingId);
            FillOptions(ddlRibbon, _ribbons, "RibbonId", group.RibbonId);
        }
    }

    private static void FillOptions(DropDownList ddl, DataTable table, string idColumn, int selectedId)
    {
        ddl.Items.Clear();
        foreach (DataRow r in table.Rows)
        {
            string label = (string)r["Name"] + " (" + Money.Rupees((decimal)r["Price"]) + ")";
            ddl.Items.Add(new ListItem(label, Convert.ToString(r[idColumn])));
        }
        ListItem match = ddl.Items.FindByValue(selectedId.ToString());
        if (match != null) ddl.SelectedValue = match.Value;
    }

    private void PrefillCheckout()
    {
        try
        {
            DataTable dt = Db.Table("SELECT FullName, Phone FROM dbo.Users WHERE UserId = @u", Db.P("@u", AuthHelper.CurrentUserId));
            if (dt.Rows.Count == 1)
            {
                txtName.Text = (string)dt.Rows[0]["FullName"];
                txtPhone.Text = (string)dt.Rows[0]["Phone"];
            }
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
        }
        txtDate.Attributes["min"] = DateTime.Today.AddDays(1).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        txtDate.Attributes["max"] = DateTime.Today.AddDays(MaxDaysAhead).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        txtDate.Text = DateTime.Today.AddDays(2).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
    }

    // ------------------------------------------------------------------ cart commands

    /// <summary>Update / remove a single flower row.</summary>
    protected void rptItems_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        int cartId;
        if (!int.TryParse(Convert.ToString(e.CommandArgument), out cartId)) return;
        int userId = AuthHelper.CurrentUserId;

        try
        {
            if (e.CommandName == "update")
            {
                TextBox txt = (TextBox)e.Item.FindControl("txtQty");
                int qty;
                if (!int.TryParse(txt.Text, out qty) || qty < 1 || qty > CartService.MaxQty)
                {
                    ShowMessage("Please enter a quantity between 1 and " + CartService.MaxQty + ".", true);
                }
                else if (CartService.UpdateQuantity(userId, cartId, qty))
                {
                    ShowMessage("Quantity updated.", false);
                }
            }
            else if (e.CommandName == "remove")
            {
                CartService.RemoveItem(userId, cartId);
                ShowMessage("Item removed from your cart.", false);
            }
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowMessage("Sorry, we could not update your cart. Please try again.", true);
        }
        BindCart();
    }

    /// <summary>Remove a whole bouquet, or save a new wrapping / ribbon for it.</summary>
    protected void rptGroups_ItemCommand(object source, RepeaterCommandEventArgs e)
    {
        Guid bouquetId;
        if (!Guid.TryParse(Convert.ToString(e.CommandArgument), out bouquetId)) return;
        int userId = AuthHelper.CurrentUserId;

        try
        {
            if (e.CommandName == "removeBouquet")
            {
                CartService.RemoveBouquet(userId, bouquetId);
                ShowMessage("Bouquet removed from your cart.", false);
            }
            else if (e.CommandName == "saveOptions")
            {
                DropDownList ddlWrap = (DropDownList)e.Item.FindControl("ddlWrap");
                DropDownList ddlRibbon = (DropDownList)e.Item.FindControl("ddlRibbon");
                int wrapId, ribbonId;
                if (int.TryParse(ddlWrap.SelectedValue, out wrapId) && int.TryParse(ddlRibbon.SelectedValue, out ribbonId)
                    && CartService.UpdateBouquetOptions(userId, bouquetId, wrapId, ribbonId))
                {
                    ShowMessage("Wrapping and ribbon updated.", false);
                }
                else
                {
                    ShowMessage("Please choose a valid wrapping and ribbon.", true);
                }
            }
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowMessage("Sorry, we could not update your cart. Please try again.", true);
        }
        BindCart();
    }

    // ------------------------------------------------------------------ checkout

    protected void btnPlaceOrder_Click(object sender, EventArgs e)
    {
        string name = (txtName.Text ?? "").Trim();
        string phone = Validation.NormalizePhone(txtPhone.Text);
        string address = (txtAddress.Text ?? "").Trim();

        // ---- Server-side validation of every field ----
        string problem = null;
        DateTime date = DateTime.MinValue;

        if (!Validation.IsValidName(name))
            problem = "Please enter the customer's full name.";
        else if (phone == null)
            problem = "Please enter a valid 10-digit Indian mobile number.";
        else if (!Validation.IsValidAddress(address))
            problem = "Please enter the full delivery address (at least 10 characters).";
        else if (!DateTime.TryParseExact((txtDate.Text ?? "").Trim(), "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date))
            problem = "Please choose a delivery date.";
        else if (date.Date < DateTime.Today.AddDays(1) || date.Date > DateTime.Today.AddDays(MaxDaysAhead))
            problem = "Please choose a delivery date between tomorrow and " + MaxDaysAhead + " days from now.";

        if (problem != null)
        {
            ShowMessage(problem, true);
            BindCart();
            return;
        }

        // ---- Create the order in one SQL transaction (prices are recalculated from the database) ----
        string error;
        int orderId;
        try
        {
            orderId = OrderService.PlaceOrder(AuthHelper.CurrentUserId, name, phone, address, date, out error);
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowMessage("We could not place your order right now. Please try again in a moment.", true);
            BindCart();
            return;
        }

        if (orderId == 0)
        {
            ShowMessage(error, true);
            BindCart();
            return;
        }

        Response.Redirect("~/Pages/OrderConfirmation.aspx?id=" + orderId);
    }

    private void ShowMessage(string message, bool isError)
    {
        litMessage.Text = HttpUtility.HtmlEncode(message);
        pnlMessage.CssClass = isError ? "alert alert-error" : "alert alert-success";
        pnlMessage.Visible = true;
    }
}
