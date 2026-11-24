<%@ Page Title="Create Account | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="BloomSpace.Account.RegisterPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="auth-section">
        <div class="auth-visual">
            <img src="<%= ResolveUrl("~/Images/Flowers/custom-bouquet.svg") %>" alt="A custom Bloom Space bouquet" />
            <div class="auth-visual-copy">
                <span class="eyebrow">Join Bloom Space</span>
                <h2>Beautiful flowers,<br /><em>beautifully simple.</em></h2>
                <p>Create an account to save your bag, place orders and design custom bouquets for the people you love.</p>
            </div>
        </div>

        <div class="auth-panel">
            <div class="auth-card auth-card-wide">
                <a class="brand auth-brand" href="<%= ResolveUrl("~/Pages/Home.aspx") %>">
                    <img class="brand-mark" src="<%= ResolveUrl("~/Images/Logo/bloom-mark.svg") %>" alt="" width="36" height="36" />
                    <span class="brand-text">
                        BLOOM<span>SPACE</span>
                        <small>Every bloom tells a story</small>
                    </span>
                </a>

                <h1>Create your account</h1>
                <p class="auth-lede">A few details, and your first bouquet is only a moment away.</p>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error">
                    <asp:Literal ID="litError" runat="server" />
                </asp:Panel>

                <div class="form-field">
                    <asp:Label ID="lblFullName" runat="server" AssociatedControlID="txtFullName" CssClass="field-label">Full name</asp:Label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="input" MaxLength="100" autocomplete="name" />
                </div>

                <div class="form-field">
                    <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" CssClass="field-label">Email address</asp:Label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="input" TextMode="Email" MaxLength="150" autocomplete="email" />
                </div>

                <div class="form-field">
                    <asp:Label ID="lblPhone" runat="server" AssociatedControlID="txtPhone" CssClass="field-label">Phone number</asp:Label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="input" TextMode="Phone" MaxLength="15" autocomplete="tel" />
                    <span class="field-hint">A 10-digit Indian mobile number, for delivery updates only.</span>
                </div>

                <div class="form-grid">
                    <div class="form-field">
                        <asp:Label ID="lblPassword" runat="server" AssociatedControlID="txtPassword" CssClass="field-label">Password</asp:Label>
                        <asp:TextBox ID="txtPassword" runat="server" CssClass="input" TextMode="Password" MaxLength="128" autocomplete="new-password" />
                    </div>

                    <div class="form-field">
                        <asp:Label ID="lblConfirmPassword" runat="server" AssociatedControlID="txtConfirmPassword" CssClass="field-label">Confirm password</asp:Label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="input" TextMode="Password" MaxLength="128" autocomplete="new-password" />
                    </div>
                </div>

                <span class="field-hint">At least 8 characters, including a letter and a number.</span>

                <asp:Button ID="btnRegister" runat="server" CssClass="btn btn-primary btn-block" Text="Create account" OnClick="btnRegister_Click" />

                <p class="auth-switch">
                    Already have an account?
                    <a href="<%= LoginUrl %>">Sign in</a>
                </p>

                <p class="auth-note">
                    Your password is hashed with a unique salt before it is stored. We never keep plain-text passwords.
                </p>
            </div>
        </div>
    </section>

</asp:Content>
