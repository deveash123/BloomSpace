using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using System.Web;
using BloomSpace;

public partial class Pages_Orders : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Must be logged in to view personal orders.
        AuthHelper.RequireLogin(this);

        if (!IsPostBack)
        {
            LoadOrders();
        }
    }

    private void LoadOrders()
    {
        int userId = AuthHelper.CurrentUserId;
        List<OrderInfo> orders;

        try
        {
            orders = OrderService.GetOrdersForUser(userId);
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            orders = new List<OrderInfo>();
        }

        if (orders == null || orders.Count == 0)
        {
            pnlNoOrders.Visible = true;
            pnlOrders.Visible = false;
            return;
        }

        pnlNoOrders.Visible = false;
        pnlOrders.Visible = true;

        StringBuilder sb = new StringBuilder();
        foreach (OrderInfo order in orders)
        {
            sb.Append(RenderOrderCard(order));
        }
        litOrdersHtml.Text = sb.ToString();
    }

    private string RenderOrderCard(OrderInfo o)
    {
        StringBuilder sb = new StringBuilder();

        string status = (o.Status ?? "Placed").Trim();
        int stepIndex = GetStatusStepIndex(status);

        sb.Append("<div class=\"order-card\">");

        // --- Card Header ---
        sb.Append("<div class=\"order-card-header\">");
        sb.Append("<div class=\"order-header-left\">");
        sb.Append("<span class=\"order-num\">Order #").Append(o.OrderId).Append("</span>");
        sb.Append("<span class=\"order-date\">Placed on ").Append(o.OrderedAt.ToString("d MMMM yyyy, h:mm tt", CultureInfo.InvariantCulture)).Append("</span>");
        sb.Append("</div>");
        sb.Append("<div class=\"order-header-right\">");
        sb.Append("<span class=\"status-pill status-").Append(status.ToLowerInvariant().Replace(" ", "-")).Append("\">");
        sb.Append(Enc(GetStatusDisplay(status)));
        sb.Append("</span>");
        sb.Append("</div>");
        sb.Append("</div>");

        // --- Live Delivery Tracker Stepper ---
        sb.Append("<div class=\"order-tracker\" aria-label=\"Delivery Progress\">");
        sb.Append("<div class=\"tracker-bar\">");
        sb.Append("<div class=\"tracker-progress\" style=\"width: ").Append(GetProgressPercent(stepIndex)).Append("%;\"></div>");
        sb.Append("</div>");
        sb.Append("<div class=\"tracker-steps\">");

        sb.Append(RenderTrackerStep("1", "Confirmed", "Order received", stepIndex >= 1, stepIndex == 1));
        sb.Append(RenderTrackerStep("2", "Arranging", "Handcrafted in studio", stepIndex >= 2, stepIndex == 2));
        sb.Append(RenderTrackerStep("3", "Out for Delivery", "On the way with courier", stepIndex >= 3, stepIndex == 3));
        sb.Append(RenderTrackerStep("4", "Delivered", "Delivered to recipient", stepIndex >= 4, stepIndex == 4));

        sb.Append("</div>");
        sb.Append("</div>");

        // --- Delivery Details & Recipient ---
        sb.Append("<div class=\"order-details-grid\">");

        sb.Append("<div class=\"detail-col\">");
        sb.Append("<h4>Delivery Information</h4>");
        sb.Append("<p><strong>Recipient:</strong> ").Append(Enc(o.CustomerName)).Append("</p>");
        sb.Append("<p><strong>Phone:</strong> ").Append(Enc(o.Phone)).Append("</p>");
        sb.Append("<p><strong>Address:</strong> ").Append(Enc(o.DeliveryAddress).Replace("\n", ", ")).Append("</p>");
        sb.Append("<p><strong>Scheduled Date:</strong> ").Append(o.DeliveryDate.ToString("dddd, d MMMM yyyy", CultureInfo.InvariantCulture)).Append("</p>");
        sb.Append("</div>");

        // --- Price & Actions Column ---
        sb.Append("<div class=\"detail-col detail-summary\">");
        sb.Append("<h4>Payment Summary</h4>");
        sb.Append("<div class=\"order-price-row\"><span>Flower subtotal</span><span>").Append(Enc(Money.Rupees(o.Subtotal))).Append("</span></div>");
        sb.Append("<div class=\"order-price-row\"><span>Delivery fee</span><span>").Append(Enc(Money.Rupees(o.DeliveryFee))).Append("</span></div>");
        sb.Append("<div class=\"order-price-row grand\"><span>Total paid</span><span>").Append(Enc(Money.Rupees(o.TotalAmount))).Append("</span></div>");
        sb.Append("<div class=\"order-actions-bar\">");
        sb.Append("<a class=\"btn btn-small btn-outline\" href=\"").Append(ResolveUrl("~/Pages/OrderConfirmation.aspx?id=" + o.OrderId)).Append("\">View Full Receipt</a>");
        sb.Append("<a class=\"btn btn-small\" href=\"").Append(ResolveUrl("~/Pages/CustomBouquet.aspx")).Append("\">Order Again</a>");
        sb.Append("</div>");
        sb.Append("</div>");

        sb.Append("</div>"); // order-details-grid

        // --- Items Breakdown ---
        sb.Append("<div class=\"order-items-toggle\">");
        sb.Append("<h4>Items in this order (").Append(o.Lines.Count).Append(")</h4>");
        sb.Append("<div class=\"order-items-list\">");

        // Group by bouquet or single stem
        int? curBouquet = -999;
        bool bOpen = false;
        foreach (OrderLine l in o.Lines)
        {
            if (l.BouquetNo.HasValue)
            {
                if (curBouquet != l.BouquetNo)
                {
                    if (bOpen) sb.Append("</div></div>");
                    sb.Append("<div class=\"ordered-bouquet-card\">");
                    sb.Append("<div class=\"ob-title\"><span class=\"badge-tag\">Custom Bouquet</span> with ").Append(Enc(l.WrappingName)).Append(" &amp; ").Append(Enc(l.RibbonName)).Append("</div>");
                    sb.Append("<div class=\"ob-items\">");
                    bOpen = true;
                    curBouquet = l.BouquetNo;
                }
                sb.Append("<div class=\"ob-line\">");
                sb.Append("<span>").Append(l.Quantity).Append(" &times; ").Append(Enc(l.FlowerName)).Append("</span>");
                sb.Append("<span>").Append(Enc(Money.Rupees(l.LineTotal))).Append("</span>");
                sb.Append("</div>");
            }
            else
            {
                if (bOpen) { sb.Append("</div></div>"); bOpen = false; curBouquet = -999; }
                sb.Append("<div class=\"ordered-single-item\">");
                sb.Append("<span>").Append(l.Quantity).Append(" &times; ").Append(Enc(l.FlowerName)).Append("</span>");
                sb.Append("<span>").Append(Enc(Money.Rupees(l.LineTotal))).Append("</span>");
                sb.Append("</div>");
            }
        }
        if (bOpen) sb.Append("</div></div>");

        sb.Append("</div>"); // order-items-list
        sb.Append("</div>"); // order-items-toggle

        sb.Append("</div>"); // order-card
        return sb.ToString();
    }

    private string RenderTrackerStep(string num, string title, string sub, bool isCompleted, bool isCurrent)
    {
        string stateClass = isCurrent ? "is-current" : (isCompleted ? "is-complete" : "is-pending");
        StringBuilder sb = new StringBuilder();
        sb.Append("<div class=\"tracker-step ").Append(stateClass).Append("\">");
        sb.Append("<div class=\"step-marker\">");
        if (isCompleted && !isCurrent)
        {
            sb.Append("<svg viewBox=\"0 0 24 24\" width=\"14\" height=\"14\" fill=\"none\" stroke=\"currentColor\" stroke-width=\"3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"><path d=\"M5 13l4 4L19 7\"></path></svg>");
        }
        else
        {
            sb.Append(num);
        }
        sb.Append("</div>");
        sb.Append("<div class=\"step-text\">");
        sb.Append("<span class=\"step-title\">").Append(Enc(title)).Append("</span>");
        sb.Append("<span class=\"step-sub\">").Append(Enc(sub)).Append("</span>");
        sb.Append("</div>");
        sb.Append("</div>");
        return sb.ToString();
    }

    private int GetStatusStepIndex(string status)
    {
        switch (status.ToLowerInvariant())
        {
            case "placed":
                return 1;
            case "preparing":
            case "arranging":
                return 2;
            case "out for delivery":
            case "shipped":
                return 3;
            case "delivered":
                return 4;
            default:
                return 1;
        }
    }

    private string GetStatusDisplay(string status)
    {
        switch (status.ToLowerInvariant())
        {
            case "placed":
                return "Order Confirmed";
            case "preparing":
            case "arranging":
                return "Arranging in Studio";
            case "out for delivery":
                return "Out for Delivery";
            case "delivered":
                return "Delivered with Care";
            default:
                return status;
        }
    }

    private int GetProgressPercent(int step)
    {
        switch (step)
        {
            case 1: return 12;
            case 2: return 40;
            case 3: return 75;
            case 4: return 100;
            default: return 12;
        }
    }

    private static string Enc(string s) { return HttpUtility.HtmlEncode(s ?? ""); }
}
