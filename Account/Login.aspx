<%@ Page Title="Sign In | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="BloomSpace.Account.LoginPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="auth-section">
        <div class="auth-visual">
            <img src="<%= ResolveUrl("~/Images/Flowers/hero-bouquet.svg") %>" alt="A signature Bloom Space bouquet" />
            <div class="auth-visual-copy">
                <span class="eyebrow">Welcome back</span>
                <h2>Every bloom<br /><em>tells a story.</em></h2>
                <p>Sign in to revisit your bag, place an order, or design a bouquet that is entirely your own.</p>
            </div>
        </div>

        <div class="auth-panel">
            <div class="auth-card">
                <a class="brand auth-brand" href="<%= ResolveUrl("~/Pages/Home.aspx") %>">
                    <img class="brand-mark" src="<%= ResolveUrl("~/Images/Logo/bloom-mark.svg") %>" alt="" width="36" height="36" />
                    <span class="brand-text">
                        BLOOM<span>SPACE</span>
                        <small>Every bloom tells a story</small>
                    </span>
                </a>

                <h1>Sign in</h1>
                <p class="auth-lede">Your flowers, your orders and your custom bouquets, all in one place.</p>

                <asp:Panel ID="pnlInfo" runat="server" Visible="false" CssClass="alert alert-success">
                    <asp:Literal ID="litInfo" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error">
                    <asp:Literal ID="litError" runat="server" />
                </asp:Panel>

                <div class="form-field">
                    <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" CssClass="field-label">Email address</asp:Label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="input" TextMode="Email" MaxLength="150" autocomplete="email" />
                </div>

                <div class="form-field">
                    <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" CssClass="field-label">Password</asp:Label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" MaxLength="128" autocomplete="current-password" />
                </div>

                <asp:Button ID="btnLogin" runat="server" CssClass="btn btn-primary btn-block" Text="Sign in" OnClick="btnLogin_Click" />

                <p class="auth-switch">
                    New to Bloom Space?
                    <a href="<%= RegisterUrl %>">Create an account</a>
                </p>

                <p class="auth-note">
                    Your password is protected with salted PBKDF2 hashing. We never store it in plain text.
                </p>
            </div>
        </div>
    </section>

</asp:Content>
