<%@ Page Title="Create Account" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="Account_Register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">
            <div class="auth-wrap">
                <div class="form-card">
                    <h1>Create Your Account</h1>
                    <p class="auth-sub">Join Bloom Space to order flowers and design custom bouquets.</p>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                        <asp:Literal ID="litMessage" runat="server" />
                    </asp:Panel>

                    <div class="form-group">
                        <label for="<%= txtName.ClientID %>">Full name</label>
                        <asp:TextBox ID="txtName" runat="server" MaxLength="100" autocomplete="name" />
                    </div>
                    <div class="form-group">
                        <label for="<%= txtEmail.ClientID %>">Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="email" />
                    </div>
                    <div class="form-group">
                        <label for="<%= txtPhone.ClientID %>">Phone number</label>
                        <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="20" autocomplete="tel" />
                        <div class="form-hint">10-digit Indian mobile number.</div>
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label for="<%= txtPassword.ClientID %>">Password</label>
                            <div class="password-field-wrap">
                                <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="new-password" />
                                <button type="button" class="password-toggle" aria-label="Show password" tabindex="-1">
                                    <svg class="eye-icon eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                    <svg class="eye-icon eye-closed" style="display:none;" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                                </button>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="<%= txtConfirm.ClientID %>">Confirm password</label>
                            <div class="password-field-wrap">
                                <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="100" autocomplete="new-password" />
                                <button type="button" class="password-toggle" aria-label="Show password" tabindex="-1">
                                    <svg class="eye-icon eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                    <svg class="eye-icon eye-closed" style="display:none;" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                                </button>
                            </div>
                        </div>
                    </div>
                    <div class="form-hint" style="margin: -8px 0 20px;">At least 8 characters, with a letter and a number.</div>

                    <asp:Button ID="btnRegister" runat="server" Text="Create Account" CssClass="btn btn-block" OnClick="btnRegister_Click" />

                    <p class="auth-switch">Already have an account? <a href="<%= ResolveUrl("~/Account/Login.aspx") %>">Log in</a></p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
