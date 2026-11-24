<%@ Page Title="Order Confirmation | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="OrderConfirmation.aspx.cs" Inherits="BloomSpace.Pages.OrderConfirmationPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlOrder" runat="server" Visible="false">

        <section class="confirmation-hero">
            <div class="container confirmation-hero-inner">
                <span class="confirmation-mark" aria-hidden="true">
                    <svg viewBox="0 0 32 32">
                        <circle cx="16" cy="16" r="15" />
                        <path d="m9.5 16.5 4.5 4.5 8.5-9" />
                    </svg>
                </span>
                <span class="eyebrow">Order confirmed</span>
                <h1>Thank you, <em><asp:Literal ID="litFirstName" runat="server" /></em>.</h1>
                <p class="confirmation-lede">
                    Your flowers are now in our florists' hands. We will hand-tie them
                    on the morning of your chosen delivery date.
                </p>

                <div class="confirmation-meta">
                    <div><span>Order</span><strong>BS-<asp:Literal ID="litOrderNumber" runat="server" /></strong></div>
                    <div><span>Placed</span><strong><asp:Literal ID="litOrderDate" runat="server" /></strong></div>
                    <div><span>Delivery</span><strong><asp:Literal ID="litDeliveryDate" runat="server" /></strong></div>
                    <div><span>Status</span><strong><asp:Literal ID="litStatus" runat="server" /></strong></div>
                </div>
            </div>
        </section>

        <section class="section confirmation-section">
            <div class="container confirmation-layout">

                <div class="confirmation-main">
                    <div class="confirmation-heading">
                        <h2>Your flowers</h2>
                        <span>Saved exactly as you ordered them.</span>
                    </div>

                    <asp:Repeater ID="rptItems" runat="server">
                        <ItemTemplate>
                            <article class="order-line">
                                <div class="order-line-main">
                                    <h3><%#: Eval("ItemName") %></h3>
                                    <p>Quantity <%#: Eval("Quantity") %> &middot; Flowers <%#: Eval("UnitPriceText") %> per bouquet</p>
                                    <p class="order-line-options"><%#: Eval("OptionsText") %></p>
                                </div>
                                <strong class="order-line-total"><%#: Eval("LineTotalText") %></strong>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>

                    <div class="confirmation-actions">
                        <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Continue shopping</a>
                        <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design another bouquet</a>
                    </div>
                </div>

                <aside class="confirmation-aside">
                    <div class="checkout-card">
                        <h2>Order summary</h2>

                        <dl class="summary-totals">
                            <div><dt>Flowers</dt><dd><asp:Literal ID="litSubtotal" runat="server" /></dd></div>
                            <div><dt>Delivery</dt><dd><asp:Literal ID="litDelivery" runat="server" /></dd></div>
                            <div class="summary-grand"><dt>Total</dt><dd><asp:Literal ID="litGrandTotal" runat="server" /></dd></div>
                        </dl>

                        <hr class="rule" />

                        <h3 class="checkout-subtitle">Delivering to</h3>
                        <p class="address-block">
                            <strong><asp:Literal ID="litCustomerName" runat="server" /></strong><br />
                            <asp:Literal ID="litAddress" runat="server" /><br />
                            <asp:Literal ID="litPhone" runat="server" />
                        </p>

                        <p class="summary-note">
                            Please keep your phone nearby on the delivery date. Our courier
                            will call before arriving.
                        </p>

                        <p class="secure-note">
                            This order has been saved to your Bloom Space account.
                        </p>
                    </div>
                </aside>

            </div>
        </section>

    </asp:Panel>

    <asp:Panel ID="pnlMissing" runat="server" Visible="true">
        <section class="page-hero page-hero-compact">
            <div class="container page-hero-inner">
                <div>
                    <span class="eyebrow">Order lookup</span>
                    <h1>We couldn't find <em>that order.</em></h1>
                    <p>The order may belong to another account, or the link may have expired.</p>
                </div>
            </div>
        </section>

        <section class="section">
            <div class="container">
                <div class="empty-state">
                    <span class="empty-mark" aria-hidden="true"></span>
                    <h2>Nothing to show here.</h2>
                    <p>Return to your bag or explore the collection to place a new order.</p>
                    <div class="empty-actions">
                        <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop flowers</a>
                        <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/Cart.aspx") %>">View your bag</a>
                    </div>
                </div>
            </div>
        </section>
    </asp:Panel>

</asp:Content>
