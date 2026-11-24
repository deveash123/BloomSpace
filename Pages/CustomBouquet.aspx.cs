using System;
using System.Collections.Generic;
using System.Web.UI;

namespace BloomSpace.Pages
{
    public partial class CustomBouquetPage : BloomPage
    {
        private List<FlowerOption> _flowers = new List<FlowerOption>();

        protected void Page_Load(object sender, EventArgs e)
        {
            LoadCatalogue();

            if (!IsPostBack)
            {
                pnlGuestNote.Visible = !Auth.IsLoggedIn;
            }
        }

        private void LoadCatalogue()
        {
            try
            {
                _flowers = CartService.GetBuilderFlowers();

                if (!IsPostBack)
                {
                    rptFlowers.DataSource = _flowers;
                    rptFlowers.DataBind();

                    rptPreview.DataSource = _flowers;
                    rptPreview.DataBind();

                    rptWrapping.DataSource = CartService.GetWrappingOptions();
                    rptWrapping.DataBind();

                    rptRibbon.DataSource = CartService.GetRibbonOptions();
                    rptRibbon.DataBind();

                    if (_flowers.Count == 0)
                    {
                        ShowPageError("The bouquet studio is being restocked. Please come back shortly.");
                    }
                }
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowPageError(
                    "The bouquet studio could not be loaded. Please check the database connection and refresh the page.");
            }
        }

        protected void btnAddBouquet_Click(object sender, EventArgs e)
        {
            if (!Auth.RequireLogin(this))
            {
                return;
            }

            try
            {
                List<CustomFlowerSelection> selections = new List<CustomFlowerSelection>();

                foreach (FlowerOption flower in _flowers)
                {
                    bool included = string.Equals(
                        Request.Form["chk_" + flower.FlowerId],
                        "1",
                        StringComparison.Ordinal);

                    int quantity;
                    int.TryParse(Request.Form["qty_" + flower.FlowerId], out quantity);

                    if (quantity > 0)
                    {
                        selections.Add(new CustomFlowerSelection
                        {
                            FlowerId = flower.FlowerId,
                            Quantity = quantity
                        });
                    }
                    else if (included)
                    {
                        selections.Add(new CustomFlowerSelection
                        {
                            FlowerId = flower.FlowerId,
                            Quantity = 1
                        });
                    }
                }

                int wrappingId = ReadFormInt("wrappingId");
                int ribbonId = ReadFormInt("ribbonId");

                CartService.AddCustomBouquet(
                    Auth.CurrentUserId.Value,
                    selections,
                    wrappingId,
                    ribbonId);

                Response.Redirect("~/Pages/Cart.aspx?added=custom", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (ArgumentException exception)
            {
                ShowBuilderError(exception.Message);
            }
            catch (InvalidOperationException exception)
            {
                ShowBuilderError(exception.Message);
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowBuilderError("We could not add your bouquet right now. Please try again.");
            }
        }

        private int ReadFormInt(string key)
        {
            int value;
            int.TryParse(Request.Form[key], out value);
            return value;
        }

        private void ShowBuilderError(string message)
        {
            pnlBuilderError.Visible = true;
            litBuilderError.Text = Server.HtmlEncode(message);
        }

        private void ShowPageError(string message)
        {
            pnlPageError.Visible = true;
            litPageError.Text = Server.HtmlEncode(message);
            btnAddBouquet.Enabled = false;
        }
    }
}
