using System;
using System.Web;
using System.Web.UI;

namespace BloomSpace.Account
{
    public partial class RegisterPage : BloomPage
    {
        public string LoginUrl
        {
            get
            {
                string url = ResolveUrl("~/Account/Login.aspx");
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
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            string email = (txtEmail.Text ?? string.Empty).Trim();

            try
            {
                string error = AccountService.Register(
                    txtFullName.Text,
                    email,
                    txtPhone.Text,
                    txtPassword.Text,
                    txtConfirmPassword.Text);

                if (error != null)
                {
                    ShowError(error);
                    txtPassword.Text = string.Empty;
                    txtConfirmPassword.Text = string.Empty;
                    return;
                }

                // Sign the new customer in straight away.
                UserRecord user = AccountService.Authenticate(email, txtPassword.Text);

                if (user == null)
                {
                    Response.Redirect("~/Account/Login.aspx?registered=1", false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                Auth.SignIn(user.UserId, user.FullName, user.Email);

                string target = Auth.SafeReturnUrl(
                    Request.QueryString["returnUrl"],
                    "~/Pages/Home.aspx");

                if (target == "~/Pages/Home.aspx")
                {
                    target += "?welcome=1";
                }

                Response.Redirect(target, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw;
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowError("We could not create your account right now. Please try again.");
            }
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }
    }
}
