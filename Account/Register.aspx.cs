using System;
using System.Data.SqlClient;
using System.Web;
using BloomSpace;

public partial class Account_Register : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!IsPostBack && AuthHelper.IsLoggedIn)
        {
            Response.Redirect("~/Pages/Home.aspx");
        }
    }

    protected void btnRegister_Click(object sender, EventArgs e)
    {
        string name = (txtName.Text ?? "").Trim();
        string email = (txtEmail.Text ?? "").Trim().ToLowerInvariant();
        string phone = Validation.NormalizePhone(txtPhone.Text);
        string password = txtPassword.Text ?? "";
        string confirm = txtConfirm.Text ?? "";

        // ---- Server-side validation ----
        if (!Validation.IsValidName(name))
        {
            ShowError("Please enter your full name (letters only, at least 2 characters).");
            return;
        }
        if (!Validation.IsValidEmail(email))
        {
            ShowError("Please enter a valid email address.");
            return;
        }
        if (phone == null)
        {
            ShowError("Please enter a valid 10-digit Indian mobile number.");
            return;
        }
        string passwordProblem = Validation.PasswordProblem(password);
        if (passwordProblem != null)
        {
            ShowError(passwordProblem);
            return;
        }
        if (password != confirm)
        {
            ShowError("The two passwords do not match.");
            return;
        }

        try
        {
            // Friendly early check (the UNIQUE constraint below is the real guarantee).
            object existing = Db.Scalar("SELECT COUNT(*) FROM dbo.Users WHERE Email = @e", Db.P("@e", email));
            if (Convert.ToInt32(existing) > 0)
            {
                ShowError("An account with this email already exists. Try logging in instead.");
                return;
            }

            string hash, salt;
            int iterations;
            PasswordHasher.Hash(password, out hash, out salt, out iterations);

            int newUserId;
            using (SqlConnection con = Db.Open())
            using (SqlCommand cmd = new SqlCommand(
                @"INSERT INTO dbo.Users (FullName, Email, Phone, PasswordHash, PasswordSalt, Iterations)
                  OUTPUT INSERTED.UserId
                  VALUES (@n, @e, @p, @h, @s, @i)", con))
            {
                cmd.Parameters.AddWithValue("@n", name);
                cmd.Parameters.AddWithValue("@e", email);
                cmd.Parameters.AddWithValue("@p", phone);
                cmd.Parameters.AddWithValue("@h", hash);
                cmd.Parameters.AddWithValue("@s", salt);
                cmd.Parameters.AddWithValue("@i", iterations);
                newUserId = Convert.ToInt32(cmd.ExecuteScalar());
            }

            AuthHelper.SignIn(newUserId, name);
            string target = AuthHelper.SafeReturnUrl(Request.QueryString["returnUrl"], ResolveUrl("~/Pages/Home.aspx"));
            Response.Redirect(target, false);
            Context.ApplicationInstance.CompleteRequest();
        }
        catch (SqlException ex)
        {
            // 2627 / 2601 = duplicate key: two people registered the same email at the same moment.
            if (ex.Number == 2627 || ex.Number == 2601)
            {
                ShowError("An account with this email already exists. Try logging in instead.");
            }
            else
            {
                ErrorLog.Write(ex);
                ShowError("Sorry, we could not create your account right now. Please try again in a moment.");
            }
        }
        catch (Exception ex)
        {
            ErrorLog.Write(ex);
            ShowError("Sorry, we could not create your account right now. Please try again in a moment.");
        }
    }

    private void ShowError(string message)
    {
        litMessage.Text = HttpUtility.HtmlEncode(message);
        pnlMessage.Visible = true;
    }
}
