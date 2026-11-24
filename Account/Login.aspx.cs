using System;
using System.Web;
using System.Web.UI;

namespace BloomSpace.Account
{
    public partial class LoginPage : BloomPage
    {
        public string RegisterUrl
        {
            get
            {
                string url = ResolveUrl("~/Account/Register.aspx");
                string returnUrl = Request.QueryString["returnUrl"];

                if (!string.IsNullOrWhiteSpace(returnUrl))
                {
                    url += "?returnUrl=" + HttpUtility.UrlEncode(returnUrl);
                }

                return url;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Auth.IsLoggedIn)
            {
                Response.Redirect("~/Pages/Home.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack && Request.QueryString["registered"] == "1")
            {
                ShowInfo("Your account has been created. Please sign in to continue.");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string email = (txtEmail.Text ?? string.Empty).Trim();
            string password = txtPassword.Text ?? string.Empty;

            if (!Validation.IsValidEmail(email))
            {
                ShowError("Please enter a valid email address.");
                return;
            }

            if (string.IsNullOrEmpty(password))
            {
                ShowError("Please enter your password.");
                return;
            }

            try
            {
                UserRecord user = AccountService.Authenticate(email, password);

                if (user == null)
                {
                    // Deliberately generic: do not reveal whether the email exists.
                    ShowError("Email or password is incorrect. Please try again.");
                    txtPassword.Text = string.Empty;
                    return;
                }

                Auth.SignIn(user.UserId, user.FullName, user.Email);

                string returnUrl = Auth.SafeReturnUrl(
                    Request.QueryString["returnUrl"],
                    "~/Pages/Home.aspx");

                Response.Redirect(returnUrl, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowError("We could not sign you in right now. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }

        private void ShowInfo(string message)
        {
            pnlInfo.Visible = true;
            litInfo.Text = Server.HtmlEncode(message);
        }
    }
}
