<%@ Page Title="Your Bag | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Cart.aspx.cs" Inherits="BloomSpace.Pages.CartPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-compact">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">Your selection</span>
                <h1>Your bag, <em>beautifully gathered.</em></h1>
                <p>Review your flowers, update quantities and tell us where to send them.</p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number"><asp:Literal ID="litHeroCount" runat="server" Text="00" /></span>
                <span class="page-hero-label">Bouquets<br />in your bag</span>
            </div>
        </div>
    </section>

    <section class="section cart-section">
        <div class="container">

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <span class="empty-mark" aria-hidden="true"></span>
                <h2>Your bag is waiting for its first bloom.</h2>
                <p>Explore the signature collection, or design a bouquet that is entirely your own.</p>
                <div class="empty-actions">
                    <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Build a bouquet</a>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlCart" runat="server">

                <div class="cart-layout">

                    <div class="cart-main">

                        <div class="cart-head">
                            <h2>Your bag</h2>
                            <span><asp:Literal ID="litItemCount" runat="server" /></span>
                        </div>

                        <asp:Repeater ID="rptCart" runat="server">
                            <ItemTemplate>
                                <article class="cart-line">
                                    <div class="cart-line-media">
                                        <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Title") %>' loading="lazy" />
                                    </div>

                                    <div class="cart-line-info">
                                        <span class="cart-line-kicker"><%# Convert.ToBoolean(Eval("IsCustom")) ? "Made by you" : "Ready-made" %></span>
                                        <h3><%#: Eval("Title") %></h3>
                                        <p class="cart-line-desc"><%#: Eval("Description") %></p>

                                        <div class="cart-line-details">
                                            <span>Wrapping <strong><%#: Eval("WrappingName") %></strong></span>
                                            <span>Ribbon <strong><%#: Eval("RibbonName") %></strong></span>
                                            <span>Per bouquet <strong><%#: Eval("UnitPriceText") %></strong></span>
                                        </div>

                                        <asp:Panel runat="server" Visible='<%# !Convert.ToBoolean(Eval("IsValid")) %>' CssClass="cart-line-warning">
                                            <%#: Eval("ValidationMessage") %>
                                        </asp:Panel>
                                    </div>

                                    <div class="cart-line-qty">
                                        <label class="qty-label" for='qty_<%# Eval("CartId") %>'>Quantity</label>
                                        <div class="qty-stepper">
                                            <button type="button" class="qty-btn" data-step="-1" aria-label="Decrease quantity">&minus;</button>
                                            <input type="number"
                                                   id='qty_<%# Eval("CartId") %>'
                                                   name='qty_<%# Eval("CartId") %>'
                                                   value='<%# Eval("Quantity") %>'
                                                   min="1"
                                                   max="99"
                                                   inputmode="numeric"
                                                   class="qty-input cart-qty-input" />
                                            <button type="button" class="qty-btn" data-step="1" aria-label="Increase quantity">+</button>
                                        </div>
                                        <asp:LinkButton ID="lnkRemove" runat="server"
                                                        CssClass="cart-remove"
                                                        CommandArgument='<%# Eval("CartId") %>'
                                                        CausesValidation="false"
                                                        OnCommand="rptCart_Remove">Remove</asp:LinkButton>
                                    </div>

                                    <div class="cart-line-total">
                                        <span class="cart-line-total-label">Total</span>
                                        <span><%#: Eval("LineTotalText") %></span>
                                    </div>
                                </article>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="cart-actions">
                            <a class="btn btn-ghost" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Continue shopping</a>
                            <asp:Button ID="btnUpdateCart" runat="server"
                                        CssClass="btn btn-outline"
                                        Text="Update bag"
                                        CausesValidation="false"
                                        OnClick="btnUpdateCart_Click" />
                        </div>

                        <div class="cart-delivery-note">
                            <span class="cart-note-mark" aria-hidden="true"></span>
                            <p>
                                Every bouquet is hand-tied on the morning of delivery.
                                Complimentary delivery is applied automatically to orders above &#8377;2,000.
                            </p>
                        </div>

                    </div>

                    <aside class="cart-aside">
                        <div class="checkout-card">

                            <span class="eyebrow">Checkout</span>
                            <h2>Order summary</h2>

                            <dl class="summary-totals">
                                <div><dt>Subtotal</dt><dd><asp:Literal ID="litSubtotal" runat="server" /></dd></div>
                                <div><dt>Delivery</dt><dd><asp:Literal ID="litDelivery" runat="server" /></dd></div>
                                <div class="summary-grand"><dt>Total</dt><dd><asp:Literal ID="litGrandTotal" runat="server" /></dd></div>
                            </dl>

                            <p class="summary-note"><asp:Literal ID="litDeliveryNote" runat="server" /></p>

                            <hr class="rule" />

                            <h3 class="checkout-subtitle">Delivery details</h3>

                            <div class="form-field">
                                <asp:Label ID="lblName" runat="server" AssociatedControlID="txtName" CssClass="field-label">Full name</asp:Label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="input" MaxLength="100" autocomplete="name" />
                            </div>

                            <div class="form-field">
                                <asp:Label ID="lblPhone" runat="server" AssociatedControlID="txtPhone" CssClass="field-label">Phone number</asp:Label>
                                <asp:TextBox ID="txtPhone" runat="server" CssClass="input" MaxLength="15" TextMode="Phone" autocomplete="tel" />
                            </div>

                            <div class="form-field">
                                <asp:Label ID="lblAddress" runat="server" AssociatedControlID="txtAddress" CssClass="field-label">Full delivery address</asp:Label>
                                <asp:TextBox ID="txtAddress" runat="server" CssClass="input input-textarea" TextMode="MultiLine" Rows="3" MaxLength="500" autocomplete="street-address" />
                            </div>

                            <div class="form-field">
                                <asp:Label ID="lblDeliveryDate" runat="server" AssociatedControlID="txtDeliveryDate" CssClass="field-label">Preferred delivery date</asp:Label>
                                <asp:TextBox ID="txtDeliveryDate" runat="server" CssClass="input" TextMode="Date" />
                                <span class="field-hint">Deliveries are available from tomorrow through the next 30 days.</span>
                            </div>

                            <asp:Panel ID="pnlCheckoutError" runat="server" Visible="false" CssClass="form-error">
                                <asp:Literal ID="litCheckoutError" runat="server" />
                            </asp:Panel>

                            <asp:Button ID="btnPlaceOrder" runat="server"
                                        CssClass="btn btn-primary btn-block"
                                        Text="Place order"
                                        OnClick="btnPlaceOrder_Click" />

                            <p class="secure-note">
                                Your details are validated on our server and your prices are verified
                                before the order is saved.
                            </p>
                        </div>
                    </aside>

                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
