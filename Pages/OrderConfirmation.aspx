<%@ Page Title="Order Confirmation" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="OrderConfirmation.aspx.cs" Inherits="Pages_OrderConfirmation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">

            <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="empty-state">
                <h2>We could not find that order</h2>
                <p>The order may not exist, or it belongs to a different account.</p>
                <div class="empty-actions"><a class="btn" href="<%= ResolveUrl("~/Pages/Home.aspx") %>">Back to Home</a></div>
            </asp:Panel>

            <asp:Panel ID="pnlOrder" runat="server">
                <div class="confirm-card">
                    <div class="confirm-head">
                        <div class="confirm-check">
                            <svg viewBox="0 0 24 24" width="36" height="36" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12.5l4.500 4.500L19 7.500" /></svg>
                        </div>
                        <h1>Thank You!</h1>
                        <p>Your order has been placed. Every bloom tells a story, and yours is on its way.</p>
                    </div>

                    <dl class="confirm-meta">
                        <div><dt>Order number</dt><dd>#<asp:Literal ID="litOrderId" runat="server" /></dd></div>
                        <div><dt>Status</dt><dd><asp:Literal ID="litStatus" runat="server" /></dd></div>
                        <div><dt>Deliver to</dt><dd><asp:Literal ID="litName" runat="server" /> &middot; <asp:Literal ID="litPhone" runat="server" /></dd></div>
                        <div><dt>Delivery date</dt><dd><asp:Literal ID="litDate" runat="server" /></dd></div>
                        <div style="grid-column: 1 / -1;"><dt>Address</dt><dd><asp:Literal ID="litAddress" runat="server" /></dd></div>
                    </dl>

                    <h2 style="font-size: 1.5rem;">Order summary</h2>
                    <asp:Literal ID="litLines" runat="server" />

                    <div class="totals" style="margin-top: 22px;">
                        <div class="row"><span>Subtotal</span><asp:Literal ID="litSubtotal" runat="server" /></div>
                        <div class="row"><span>Delivery fee</span><asp:Literal ID="litFee" runat="server" /></div>
                        <div class="row grand"><span>Total amount</span><asp:Literal ID="litTotal" runat="server" /></div>
                    </div>

                    <div class="empty-actions" style="margin-top: 30px;">
                        <a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Continue Shopping</a>
                        <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design Another Bouquet</a>
                    </div>
                </div>
            </asp:Panel>

        </div>
    </section>
</asp:Content>
