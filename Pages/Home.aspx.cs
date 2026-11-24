using System;
using System.Data;
using BloomSpace;

public partial class Pages_Home : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (IsPostBack) return;

        try
        {
            // Featured flowers come from SQL Server (IsFeatured = 1).
            DataTable dt = Db.Table(
                @"SELECT TOP (4) FlowerId, Name, Category, UnitPrice, ImageUrl
                  FROM dbo.Flowers WHERE IsActive = 1 AND IsFeatured = 1
                  ORDER BY FlowerId");
            rptFeatured.DataSource = dt;
            rptFeatured.DataBind();
            pnlFeatured.Visible = dt.Rows.Count > 0;
            pnlFeaturedEmpty.Visible = dt.Rows.Count == 0;
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            pnlFeatured.Visible = false;
            pnlFeaturedEmpty.Visible = true;
        }
    }
}
