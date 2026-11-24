<%@ Page Title="Contact | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Contact.aspx.cs" Inherits="BloomSpace.Pages.ContactPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-compact">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">Say hello</span>
                <h1>We would love <em>to hear from you.</em></h1>
                <p>Questions about an order, a delivery date or a bouquet you have in mind? Our florists reply within one working day.</p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number">1 day</span>
                <span class="page-hero-label">Typical<br />reply time</span>
            </div>
        </div>
    </section>

    <section class="section contact-section">
        <div class="container contact-layout">

            <div class="contact-info">
                <span class="eyebrow">The studio</span>
                <h2>Come by, call,<br /><em>or write.</em></h2>
                <p class="contact-lede">
                    We are a small team, so there is a real person at the other end of
                    every message. Tell us what you need and we will help you find the
                    right flowers.
                </p>

                <div class="contact-cards">
                    <a class="contact-card" href="mailto:hello@bloomspace.in">
                        <span class="contact-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><rect x="3" y="5" width="18" height="14" rx="2" /><path d="m3.5 6.5 8.5 6 8.5-6" /></svg>
                        </span>
                        <span>
                            <small>Email</small>
                            <strong>hello@bloomspace.in</strong>
                        </span>
                    </a>

                    <a class="contact-card" href="tel:+914412345678">
                        <span class="contact-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M6.5 3.5h3l1.5 4-2 1.5a12 12 0 0 0 6 6l1.5-2 4 1.5v3a2 2 0 0 1-2.2 2A17.5 17.5 0 0 1 4.5 5.7a2 2 0 0 1 2-2.2Z" /></svg>
                        </span>
                        <span>
                            <small>Phone</small>
                            <strong>+91 44 1234 5678</strong>
                        </span>
                    </a>

                    <div class="contact-card">
                        <span class="contact-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><path d="M12 21s7-5.5 7-11a7 7 0 1 0-14 0c0 5.5 7 11 7 11Z" /><circle cx="12" cy="10" r="2.5" /></svg>
                        </span>
                        <span>
                            <small>Studio</small>
                            <strong>12, 2nd Avenue, Anna Nagar, Chennai 600040</strong>
                        </span>
                    </div>

                    <div class="contact-card">
                        <span class="contact-icon" aria-hidden="true">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="8.5" /><path d="M12 7v5l3 2" /></svg>
                        </span>
                        <span>
                            <small>Hours</small>
                            <strong>Mon &ndash; Sat, 9:00 AM &ndash; 7:00 PM</strong>
                        </span>
                    </div>
                </div>

                <p class="contact-note">
                    For an existing order, please include your order number
                    (for example, BS-00012) so we can help you faster.
                </p>
            </div>

            <div class="contact-form-card">
                <h2>Send a message</h2>
                <p class="checkout-subtitle">Fill in the details below and we will get back to you by email.</p>

                <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="alert alert-success">
                    Thank you &mdash; your message is with our team. We usually reply within one working day.
                </asp:Panel>

                <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="alert alert-error">
                    <asp:Literal ID="litError" runat="server" />
                </asp:Panel>

                <div class="form-grid">
                    <div class="form-field">
                        <asp:Label ID="lblName" runat="server" AssociatedControlID="txtName" CssClass="field-label">Your name</asp:Label>
                        <asp:TextBox ID="txtName" runat="server" CssClass="input" MaxLength="100" autocomplete="name" />
                    </div>

                    <div class="form-field">
                        <asp:Label ID="lblEmail" runat="server" AssociatedControlID="txtEmail" CssClass="field-label">Email address</asp:Label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="input" TextMode="Email" MaxLength="150" autocomplete="email" />
                    </div>
                </div>

                <div class="form-field">
                    <asp:Label ID="lblSubject" runat="server" AssociatedControlID="txtSubject" CssClass="field-label">Subject</asp:Label>
                    <asp:TextBox ID="txtSubject" runat="server" CssClass="input" MaxLength="150" />
                </div>

                <div class="form-field">
                    <asp:Label ID="lblMessage" runat="server" AssociatedControlID="txtMessage" CssClass="field-label">Message</asp:Label>
                    <asp:TextBox ID="txtMessage" runat="server" CssClass="input input-textarea" TextMode="MultiLine" Rows="6" MaxLength="2000" />
                    <span class="field-hint">A few details help us help you: the occasion, your delivery date and your pincode.</span>
                </div>

                <div class="hp-field" aria-hidden="true">
                    <label for="<%= txtWebsite.ClientID %>">Website</label>
                    <asp:TextBox ID="txtWebsite" runat="server" TabIndex="-1" autocomplete="off" />
                </div>

                <asp:Button ID="btnSend" runat="server" CssClass="btn btn-primary btn-block" Text="Send message" OnClick="btnSend_Click" />

                <p class="secure-note">Your details are used only to reply to this message.</p>
            </div>

        </div>
    </section>

</asp:Content>
