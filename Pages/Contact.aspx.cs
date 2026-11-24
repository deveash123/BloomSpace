using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace BloomSpace.Pages
{
    public partial class ContactPage : BloomPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
            {
                return;
            }

            if (Auth.IsLoggedIn)
            {
                if (string.IsNullOrEmpty(txtName.Text))
                {
                    txtName.Text = Auth.CurrentUserName;
                }

                if (string.IsNullOrEmpty(txtEmail.Text))
                {
                    txtEmail.Text = Auth.CurrentUserEmail;
                }
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            pnlSuccess.Visible = false;
            pnlError.Visible = false;

            // Honeypot: real visitors never fill this hidden field.
            if (!string.IsNullOrWhiteSpace(txtWebsite.Text))
            {
                ShowSuccess();
                return;
            }

            string name = (txtName.Text ?? string.Empty).Trim();
            string email = (txtEmail.Text ?? string.Empty).Trim();
            string subject = (txtSubject.Text ?? string.Empty).Trim();
            string message = (txtMessage.Text ?? string.Empty).Trim();

            if (!Validation.IsValidName(name))
            {
                ShowError("Please enter your name (letters only, at least two characters).");
                return;
            }

            if (!Validation.IsValidEmail(email))
            {
                ShowError("Please enter a valid email address so we can reply.");
                return;
            }

            if (subject.Length < 3 || subject.Length > 150)
            {
                ShowError("Please add a short subject, between 3 and 150 characters.");
                return;
            }

            if (message.Length < 10 || message.Length > 2000)
            {
                ShowError("Please write a message between 10 and 2000 characters.");
                return;
            }

            try
            {
                const string sql = @"
INSERT INTO dbo.ContactMessages (FullName, Email, Subject, Message)
VALUES (@FullName, @Email, @Subject, @Message);";

                Db.ExecuteNonQuery(
                    sql,
                    new SqlParameter("@FullName", SqlDbType.NVarChar, 100) { Value = name },
                    new SqlParameter("@Email", SqlDbType.NVarChar, 150) { Value = email },
                    new SqlParameter("@Subject", SqlDbType.NVarChar, 150) { Value = subject },
                    new SqlParameter("@Message", SqlDbType.NVarChar, 2000) { Value = message });

                ShowSuccess();
            }
            catch (Exception exception)
            {
                Logger.Log(exception);
                ShowError("We could not send your message right now. Please try again in a moment.");
            }
        }

        private void ShowSuccess()
        {
            pnlSuccess.Visible = true;
            txtSubject.Text = string.Empty;
            txtMessage.Text = string.Empty;
        }

        private void ShowError(string message)
        {
            pnlError.Visible = true;
            litError.Text = Server.HtmlEncode(message);
        }
    }
}
