<%@ Page Title="Contact" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Contact.aspx.cs" Inherits="Pages_Contact" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Get in touch</span>
            <h1>Contact Us</h1>
            <p>Questions, special requests or feedback? We would love to hear from you.</p>
        </div>
    </section>

    <section class="section">
        <div class="container contact-layout">

            <div class="contact-card">
                <h2 style="font-size: 1.6rem;">Our Details</h2>
                <ul class="contact-list">
                    <li><strong>Studio</strong>12 Garden Street, Chennai, Tamil Nadu 600001</li>
                    <li><strong>Phone</strong>+91 90000 00000</li>
                    <li><strong>Email</strong>hello@bloomspace.example</li>
                    <li><strong>Hours</strong>Monday to Saturday, 9:00 AM to 7:00 PM</li>
                </ul>
            </div>

            <div class="form-card">
                <h2 style="font-size: 1.6rem;">Send a Message</h2>

                <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                    <asp:Literal ID="litMessage" runat="server" />
                </asp:Panel>

                <asp:Panel ID="pnlForm" runat="server">
                    <div class="form-row">
                        <div class="form-group">
                            <label for="<%= txtName.ClientID %>">Your name</label>
                            <asp:TextBox ID="txtName" runat="server" MaxLength="100" autocomplete="name" />
                        </div>
                        <div class="form-group">
                            <label for="<%= txtEmail.ClientID %>">Email address</label>
                            <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" MaxLength="256" autocomplete="email" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="<%= txtSubject.ClientID %>">Subject</label>
                        <asp:TextBox ID="txtSubject" runat="server" MaxLength="150" />
                    </div>
                    <div class="form-group">
                        <label for="<%= txtBody.ClientID %>">Message</label>
                        <asp:TextBox ID="txtBody" runat="server" TextMode="MultiLine" Rows="5" MaxLength="2000" />
                    </div>
                    <asp:Button ID="btnSend" runat="server" Text="Send Message" CssClass="btn" OnClick="btnSend_Click" />
                </asp:Panel>
            </div>

        </div>
    </section>

</asp:Content>
