using System;
using System.Collections.Generic;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BloomSpace.Pages
{
    public partial class CartPage : BloomPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Auth.RequireLogin(this))
            {
                return;
            }

            DateTime tomorrow = DateTime.Today.AddDays(1);

            txtDeliveryDate.Attributes["min"] = tomorrow.ToString("yyyy-MM-dd");
            txtDeliveryDate.Attributes["max"] = DateTime.Today.AddDays(30).ToString("yyyy-MM-dd");

            if (!IsPostBack)
            {
                LoadCart();
                PrefillCustomer();

                if (Request.QueryString["added"] != null)
                {
                    ShowMessage("Your bouquet has been added to the bag.", true);
                }
                else if (Request.QueryString["updated"] == "1")
                {
                    ShowMessage("Your bag has been updated.", true);
                }
                else if (Request.QueryString["removed"] == "1")
                {
                    ShowMessage("The item has been removed from your bag.", true);
                }

                if (string.IsNullOrWhiteSpace(txtDeliveryDate.Text))
                {
                    txtDeliveryDate.Text = tomorrow.ToString("yyyy-MM-dd");
                }
            }
        }

        private void LoadCart()
        {
            try
            {
                int userId = Auth.CurrentUserId.Value;
                CartSummary cart = CartService.GetCart(userId);

                rptCart.DataSource = cart.Lines;
                rptCart.DataBind();

                pnlEmpty.Visible = cart.Lines.Count == 0;
                pnlCart.Visible = cart.Lines.Count > 0;

                litHeroCount.Text = cart.ItemCount.ToString("00");
                litItemCount.Text = cart.ItemCount + (cart.ItemCount == 1 ? " bouquet" : " bouquets");
                litSubtotal.Text = cart.SubtotalText;
                litDelivery.Text = cart.DeliveryFeeText;
                litGrandTotal.Text = cart.GrandTotalText;

                litDeliveryNote.Text = cart.HasFreeDelivery
                    ? "Complimentary delivery has been applied to your order."
                    : "Add " + cart.AmountToFreeDeliveryText + " more to unlock complimentary delivery.";

                btnPlaceOrder.Enabled = cart.Lines.Count > 0 && !cart.HasInvalidLines;

                if (cart.HasInvalidLines)
                {
                    ShowMessage(
                        "Some items in your bag are no longer available. Remove them to continue to checkout.",
                        false);
                }
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                pnlCart.Visible = false;
                pnlEmpty.Visible = true;
                btnPlaceOrder.Enabled = false;
                ShowMessage(
                    "Your bag could not be loaded. Please check the database connection and refresh the page.",
                    false);
            }
        }

        private void PrefillCustomer()
        {
            try
            {
                UserRecord user = AccountService.GetUser(Auth.CurrentUserId.Value);

                if (user != null)
                {
                    txtName.Text = user.FullName;
                    txtPhone.Text = user.Phone;
                }
            }
            catch (Exception exception)
            {
                // Pre-filling is a convenience; the customer can still type their details.
                Logger.Log(exception);
            }
        }

        /// <summary>
        /// Reads the quantity inputs, validates them all first, then saves.
        /// CartService filters by UserId, so only the customer's own lines change.
        /// </summary>
        private bool ApplyPostedQuantities(out string error)
        {
            error = null;

            int userId = Auth.CurrentUserId.Value;
            CartSummary cart = CartService.GetCart(userId);
            Dictionary<int, int> updates = new Dictionary<int, int>();

            foreach (CartLine line in cart.Lines)
            {
                string raw = Request.Form["qty_" + line.CartId];

                if (raw == null)
                {
                    continue;
                }

                int quantity;

                if (!int.TryParse(raw, out quantity) || quantity < 1 || quantity > 99)
                {
                    error = "Each quantity must be a whole number between 1 and 99.";
                    return false;
                }

                if (quantity != line.Quantity)
                {
                    updates[line.CartId] = quantity;
                }
            }

            foreach (KeyValuePair<int, int> update in updates)
            {
                CartService.UpdateQuantity(userId, update.Key, update.Value);
            }

            return true;
        }

        protected void btnUpdateCart_Click(object sender, EventArgs e)
        {
            string error;

            try
            {
                if (!ApplyPostedQuantities(out error))
                {
                    ShowMessage(error, false);
                    LoadCart();
                    return;
                }

                Response.Redirect("~/Pages/Cart.aspx?updated=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowMessage("Your bag could not be updated. Please try again.", false);
                LoadCart();
            }
        }

        protected void rptCart_Remove(object sender, CommandEventArgs e)
        {
            int cartId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out cartId) || cartId <= 0)
            {
                ShowMessage("That item could not be removed. Please try again.", false);
                return;
            }

            try
            {
                CartService.RemoveLine(Auth.CurrentUserId.Value, cartId);
                Response.Redirect("~/Pages/Cart.aspx?removed=1", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowMessage("That item could not be removed. Please try again.", false);
            }
        }

        protected void btnPlaceOrder_Click(object sender, EventArgs e)
        {
            string error;

            try
            {
                if (!ApplyPostedQuantities(out error))
                {
                    ShowCheckoutError(error);
                    LoadCart();
                    return;
                }

                DateTime deliveryDate;
                string[] formats = new string[] { "yyyy-MM-dd", "dd-MM-yyyy", "dd/MM/yyyy", "yyyy/MM/dd", "MM/dd/yyyy" };

                if (!DateTime.TryParseExact(
                    txtDeliveryDate.Text,
                    formats,
                    CultureInfo.InvariantCulture,
                    DateTimeStyles.None,
                    out deliveryDate) &&
                    !DateTime.TryParse(txtDeliveryDate.Text, CultureInfo.InvariantCulture, DateTimeStyles.None, out deliveryDate))
                {
                    ShowCheckoutError("Please choose a valid preferred delivery date.");
                    LoadCart();
                    return;
                }

                int orderId = OrderService.PlaceOrder(
                    Auth.CurrentUserId.Value,
                    txtName.Text,
                    txtPhone.Text,
                    txtAddress.Text,
                    deliveryDate,
                    out error);

                if (orderId <= 0)
                {
                    ShowCheckoutError(error ?? "Your order could not be placed. Please check your details.");
                    LoadCart();
                    return;
                }

                Response.Redirect("~/Pages/OrderConfirmation.aspx?orderId=" + orderId, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowCheckoutError(
                    "We could not place your order right now. No payment has been taken. Please try again.");
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "alert alert-success" : "alert alert-error";
            litMessage.Text = Server.HtmlEncode(message);
        }

        private void ShowCheckoutError(string message)
        {
            pnlCheckoutError.Visible = true;
            litCheckoutError.Text = Server.HtmlEncode(message);
        }
    }
}
