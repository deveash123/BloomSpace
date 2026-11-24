<%@ Page Title="My Orders" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Orders.aspx.cs" Inherits="Pages_Orders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Account &middot; Delivery Tracking</span>
            <h1>My Orders &amp; Tracking</h1>
            <p>Track the progress of your handcrafted floral arrangements and view your complete order history.</p>
        </div>
    </section>

    <section class="section-tight">
        <div class="container">

            <asp:Panel ID="pnlNoOrders" runat="server" Visible="false" CssClass="empty-state">
                <div class="empty-icon" style="margin-bottom: 18px;">
                    <svg viewBox="0 0 24 24" width="56" height="56" fill="none" stroke="currentColor" stroke-width="1.2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--rose);">
                        <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                        <line x1="3" y1="6" x2="21" y2="6"></line>
                        <path d="M16 10a4 4 0 0 1-8 0"></path>
                    </svg>
                </div>
                <h2>No orders placed yet</h2>
                <p>When you order fresh stems or design a custom bouquet, you can monitor its preparation and delivery progress right here.</p>
                <div class="empty-actions" style="margin-top: 24px;">
                    <a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Explore Flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design Custom Bouquet</a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlOrders" runat="server">
                <div class="orders-feed">
                    <asp:Literal ID="litOrdersHtml" runat="server" />
                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
