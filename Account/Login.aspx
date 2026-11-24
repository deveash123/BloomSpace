<%@ Page Title="Log In" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="Account_Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">
            <div class="auth-wrap">
                <div class="form-card">
                    <h1>Welcome Back</h1>
                    <p class="auth-sub">Log in to see your cart and place orders.</p>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                        <asp:Literal ID="litMessage" runat="server" />
                    </asp:Panel>

                    <div class="form-group">
                        <label for="<%= txtEmail.ClientID %>">Email address</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="email" />
                    </div>
                    <div class="form-group">
                        <label for="<%= txtPassword.ClientID %>">Password</label>
                        <div class="password-field-wrap">
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password" />
                            <button type="button" class="password-toggle" aria-label="Show password" tabindex="-1">
                                <svg class="eye-icon eye-open" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path><circle cx="12" cy="12" r="3"></circle></svg>
                                <svg class="eye-icon eye-closed" style="display:none;" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path><line x1="1" y1="1" x2="23" y2="23"></line></svg>
                            </button>
                        </div>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Log In" CssClass="btn btn-block" OnClick="btnLogin_Click" />

                    <p class="auth-switch">New to Bloom Space? <a href="<%= ResolveUrl("~/Account/Register.aspx") %>">Create an account</a></p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
