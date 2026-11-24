using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web;
using BloomSpace;

public partial class Pages_OrderConfirmation : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        AuthHelper.RequireLogin(this);
        if (IsPostBack) return;

        int orderId;
        if (!int.TryParse(Request.QueryString["id"], out orderId))
        {
            ShowNotFound();
            return;
        }

        OrderInfo order;
        try
        {
            // The query filters by UserId too, so nobody can open another customer's order by changing the number.
            order = OrderService.GetOrder(orderId, AuthHelper.CurrentUserId);
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowNotFound();
            return;
        }

        if (order == null)
        {
            ShowNotFound();
            return;
        }

        litOrderId.Text = order.OrderId.ToString();
        litStatus.Text = Enc(order.Status);
        litName.Text = Enc(order.CustomerName);
        litPhone.Text = Enc(order.Phone);
        litAddress.Text = Enc(order.DeliveryAddress).Replace("\n", "<br />");
        litDate.Text = order.DeliveryDate.ToString("dddd, d MMMM yyyy", CultureInfo.InvariantCulture);
        litSubtotal.Text = Enc(Money.Rupees(order.Subtotal));
        litFee.Text = Enc(Money.Rupees(order.DeliveryFee));
        litTotal.Text = Enc(Money.Rupees(order.TotalAmount));
        litLines.Text = BuildLines(order);
    }

    /// <summary>Builds the order summary, grouping custom-bouquet rows together.</summary>
    private static string BuildLines(OrderInfo order)
    {
        StringBuilder sb = new StringBuilder();

        // Single stems first
        bool anySingles = false;
        foreach (OrderLine l in order.Lines)
        {
            if (l.BouquetNo.HasValue) continue;
            if (!anySingles)
            {
                sb.Append("<div class=\"order-group\"><h4>Individual Flowers</h4>");
                anySingles = true;
            }
            sb.Append(Row(l.Quantity + " × " + l.FlowerName, l.LineTotal, false));
        }
        if (anySingles) sb.Append("</div>");

        // Then each bouquet
        SortedDictionary<int, List<OrderLine>> bouquets = new SortedDictionary<int, List<OrderLine>>();
        foreach (OrderLine l in order.Lines)
        {
            if (!l.BouquetNo.HasValue) continue;
            if (!bouquets.ContainsKey(l.BouquetNo.Value)) bouquets[l.BouquetNo.Value] = new List<OrderLine>();
            bouquets[l.BouquetNo.Value].Add(l);
        }
        foreach (KeyValuePair<int, List<OrderLine>> b in bouquets)
        {
            sb.Append("<div class=\"order-group\"><h4>Custom Bouquet ").Append(b.Key).Append("</h4>");
            decimal wrap = 0m, ribbon = 0m;
            string wrapName = "", ribbonName = "";
            foreach (OrderLine l in b.Value)
            {
                sb.Append(Row(l.Quantity + " × " + l.FlowerName, l.UnitPrice * l.Quantity, false));
                wrap += l.WrappingPrice;
                ribbon += l.RibbonPrice;
                if (l.WrappingName.Length > 0) wrapName = l.WrappingName;
                if (l.RibbonName.Length > 0) ribbonName = l.RibbonName;
            }
            sb.Append(Row(wrapName + " (wrapping)", wrap, true));
            sb.Append(Row(ribbonName + " (ribbon)", ribbon, true));
            sb.Append("</div>");
        }
        return sb.ToString();
    }

    private static string Row(string label, decimal amount, bool sub)
    {
        return "<div class=\"order-row" + (sub ? " sub" : "") + "\"><span>" + Enc(label) + "</span><span>" + Enc(Money.Rupees(amount)) + "</span></div>";
    }

    private void ShowNotFound()
    {
        pnlOrder.Visible = false;
        pnlNotFound.Visible = true;
    }

    private static string Enc(string s) { return HttpUtility.HtmlEncode(s); }
}
