using System;
using System.Collections.Generic;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace BloomSpace.Pages
{
    public partial class ShopPage : BloomPage
    {
        private string CurrentCategory
        {
            get { return (Request.QueryString["category"] ?? string.Empty).Trim(); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadProducts();

                if (Request.QueryString["added"] == "1")
                {
                    ShowMessage("Your bouquet has been added to the bag.", true);
                }
            }
        }

        private void LoadProducts()
        {
            try
            {
                List<FlowerProduct> products = CartService.GetShopFlowers(CurrentCategory);

                rptProducts.DataSource = products;
                rptProducts.DataBind();

                pnlEmpty.Visible = products.Count == 0;
                litCategoryLabel.Text = string.IsNullOrWhiteSpace(CurrentCategory)
                    ? "All flowers"
                    : CurrentCategory;

                litResultCount.Text = products.Count.ToString("00") +
                    (products.Count == 1 ? " bouquet" : " bouquets");
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                pnlEmpty.Visible = false;
                ShowMessage(
                    "The collection could not be loaded. Please check the database connection and refresh the page.",
                    false);
            }
        }

        protected string FilterClass(string category)
        {
            bool isAll = string.IsNullOrWhiteSpace(CurrentCategory) && string.IsNullOrWhiteSpace(category);
            bool isMatch = !string.IsNullOrWhiteSpace(category) &&
                string.Equals(CurrentCategory, category, StringComparison.OrdinalIgnoreCase);

            return isAll || isMatch ? "filter-btn active" : "filter-btn";
        }

        protected void rptProducts_Add(object sender, CommandEventArgs e)
        {
            if (!Auth.RequireLogin(this))
            {
                return;
            }

            int flowerId;

            if (!int.TryParse(Convert.ToString(e.CommandArgument), out flowerId) || flowerId <= 0)
            {
                ShowMessage("That bouquet could not be added. Please try again.", false);
                return;
            }

            try
            {
                CartService.AddFlower(Auth.CurrentUserId.Value, flowerId, 1);

                string url = ResolveUrl("~/Pages/Shop.aspx") + "?added=1";

                if (!string.IsNullOrWhiteSpace(CurrentCategory))
                {
                    url += "&category=" + HttpUtility.UrlEncode(CurrentCategory);
                }

                Response.Redirect(url, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (ArgumentException exception)
            {
                ShowMessage(exception.Message, false);
            }
            catch (InvalidOperationException exception)
            {
                ShowMessage(exception.Message, false);
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowMessage("We could not add that bouquet right now. Please try again.", false);
            }
        }

        private void ShowMessage(string message, bool success)
        {
            pnlMessage.Visible = true;
            pnlMessage.CssClass = success ? "alert alert-success" : "alert alert-error";
            litMessage.Text = Server.HtmlEncode(message);
        }
    }
}
