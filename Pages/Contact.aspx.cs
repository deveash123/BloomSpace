using System;
using System.Web;
using BloomSpace;

public partial class Pages_Contact : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && AuthHelper.IsLoggedIn)
        {
            txtName.Text = AuthHelper.CurrentUserName;
        }
    }

    protected void btnSend_Click(object sender, EventArgs e)
    {
        string name = (txtName.Text ?? "").Trim();
        string email = (txtEmail.Text ?? "").Trim();
        string subject = (txtSubject.Text ?? "").Trim();
        string body = (txtBody.Text ?? "").Trim();

        string problem = null;
        if (!Validation.IsValidName(name)) problem = "Please enter your name.";
        else if (!Validation.IsValidEmail(email)) problem = "Please enter a valid email address.";
        else if (subject.Length < 3 || subject.Length > 150) problem = "Please enter a subject (3 to 150 characters).";
        else if (body.Length < 10 || body.Length > 2000) problem = "Please write a message between 10 and 2000 characters.";

        if (problem != null)
        {
            ShowMessage(problem, true);
            return;
        }

        try
        {
            using (var con = Db.Open())
            using (var cmd = new System.Data.SqlClient.SqlCommand(
                "INSERT INTO dbo.ContactMessages (FullName, Email, Subject, Message) VALUES (@n, @e, @s, @m)", con))
            {
                cmd.Parameters.AddWithValue("@n", name);
                cmd.Parameters.AddWithValue("@e", email);
                cmd.Parameters.AddWithValue("@s", subject);
                cmd.Parameters.AddWithValue("@m", body);
                cmd.ExecuteNonQuery();
            }
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowMessage("Sorry, we could not send your message right now. Please try again in a moment.", true);
            return;
        }

        pnlForm.Visible = false;
        ShowMessage("Thank you! Your message has been sent. We will get back to you soon.", false);
    }

    private void ShowMessage(string message, bool isError)
    {
        litMessage.Text = HttpUtility.HtmlEncode(message);
        pnlMessage.CssClass = isError ? "alert alert-error" : "alert alert-success";
        pnlMessage.Visible = true;
    }
}
