using System;
using BloomSpace;

public partial class Pages_DeliveryPolicy : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // The fee shown here always matches the fee charged (both come from Web.config).
        litFee.Text = Money.Rupees(Db.DeliveryFee);
    }
}
