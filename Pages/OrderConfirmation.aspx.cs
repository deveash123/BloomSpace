using System;
using System.Web.UI;

namespace BloomSpace.Pages
{
    public partial class OrderConfirmationPage : BloomPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Auth.RequireLogin(this))
            {
                return;
            }

            if (IsPostBack)
            {
                return;
            }

            int orderId;

            if (!int.TryParse(Request.QueryString["orderId"], out orderId) || orderId <= 0)
            {
                ShowMissing();
                return;
            }

            try
            {
                OrderView order = OrderService.GetOrder(orderId, Auth.CurrentUserId.Value);

                if (order == null)
                {
                    ShowMissing();
                    return;
                }

                pnlOrder.Visible = true;
                pnlMissing.Visible = false;

                litFirstName.Text = Server.HtmlEncode(Auth.FirstName);
                litOrderNumber.Text = order.OrderId.ToString("D5");
                litOrderDate.Text = Server.HtmlEncode(order.OrderDateText);
                litDeliveryDate.Text = Server.HtmlEncode(order.DeliveryDateText);
                litStatus.Text = Server.HtmlEncode(order.Status);

                rptItems.DataSource = order.Lines;
                rptItems.DataBind();

                litSubtotal.Text = order.SubtotalText;
                litDelivery.Text = order.DeliveryFeeText;
                litGrandTotal.Text = order.GrandTotalText;

                litCustomerName.Text = Server.HtmlEncode(order.CustomerName);

                string address = Server.HtmlEncode(order.DeliveryAddress ?? string.Empty);
                litAddress.Text = address
                    .Replace("\r\n", "<br />")
                    .Replace("\n", "<br />");

                litPhone.Text = Server.HtmlEncode(order.Phone);
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowMissing();
            }
        }

        private void ShowMissing()
        {
            pnlOrder.Visible = false;
            pnlMissing.Visible = true;
        }
    }
}
