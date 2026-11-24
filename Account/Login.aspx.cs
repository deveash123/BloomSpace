using System;
using System.Data;
using System.Web;
using BloomSpace;

public partial class Account_Login : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        // Already logged in? No need to see the login form.
        if (!IsPostBack && AuthHelper.IsLoggedIn)
        {
            Response.Redirect(GetReturnUrl());
        }
    }

    protected void btnLogin_Click(object sender, EventArgs e)
    {
        string email = (txtEmail.Text ?? "").Trim().ToLowerInvariant();
        string password = txtPassword.Text ?? "";

        if (!Validation.IsValidEmail(email) || password.Length == 0)
        {
            ShowError("Please enter your email address and password.");
            return;
        }

        try
        {
            DataTable dt = Db.Table(
                "SELECT UserId, FullName, PasswordHash, PasswordSalt, Iterations FROM dbo.Users WHERE Email = @e",
                Db.P("@e", email));

            bool ok = false;
            if (dt.Rows.Count == 1)
            {
                DataRow row = dt.Rows[0];
                ok = PasswordHasher.Verify(password, (string)row["PasswordHash"], (string)row["PasswordSalt"], (int)row["Iterations"]);
                if (ok)
                {
                    AuthHelper.SignIn((int)row["UserId"], (string)row["FullName"]);
                    Response.Redirect(GetReturnUrl(), false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }
            else
            {
                // Unknown email: do the same amount of work so timing does not reveal which emails exist.
                PasswordHasher.BurnTime(password);
            }

            // Same message for "no such email" and "wrong password".
            ShowError("The email or password you entered is not correct. Please try again.");
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowError("Sorry, we could not log you in right now. Please try again in a moment.");
        }
    }

    private string GetReturnUrl()
    {
        return AuthHelper.SafeReturnUrl(Request.QueryString["returnUrl"], ResolveUrl("~/Pages/Home.aspx"));
    }

    private void ShowError(string message)
    {
        litMessage.Text = HttpUtility.HtmlEncode(message);
        pnlMessage.Visible = true;
    }
}
