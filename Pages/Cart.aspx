<%@ Page Title="Your Cart" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Cart.aspx.cs" Inherits="Pages_Cart" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Almost there</span>
            <h1>Your Cart</h1>
            <p>Review your flowers, adjust anything you like, then check out below.</p>
        </div>
    </section>

    <section class="section-tight">
        <div class="container">

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <!-- ===== Empty cart ===== -->
            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <div class="empty-icon">
                    <svg viewBox="0 0 24 24" width="38" height="38" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 4h2l2.4 11.2a1.5 1.5 0 0 0 1.5 1.2h8.2a1.5 1.5 0 0 0 1.5-1.100L20.5 8H6.2" /><circle cx="9.5" cy="20" r="1.2" /><circle cx="17" cy="20" r="1.2" /></svg>
                </div>
                <h2>Your cart is empty</h2>
                <p>Add a few fresh flowers or design a custom bouquet to get started.</p>
                <div class="empty-actions">
                    <a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop Flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Custom Bouquet</a>
                </div>
            </asp:Panel>

            <!-- ===== Cart with items ===== -->
            <asp:Panel ID="pnlCart" runat="server">
                <div class="cart-layout">

                    <div class="cart-main">
                        <asp:Repeater ID="rptGroups" runat="server" OnItemDataBound="rptGroups_ItemDataBound" OnItemCommand="rptGroups_ItemCommand">
                            <ItemTemplate>
                                <div class="cart-group">
                                    <div class="cart-group-head">
                                        <h3><%# ((CartGroup)Container.DataItem).IsBouquet ? "Custom Bouquet" : "Individual Flowers" %></h3>
                                        <asp:LinkButton ID="lbRemoveBouquet" runat="server" CssClass="link-danger" CommandName="removeBouquet"
                                            CausesValidation="false" Visible='<%# ((CartGroup)Container.DataItem).IsBouquet %>'
                                            CommandArgument='<%# ((CartGroup)Container.DataItem).BouquetId.ToString() %>'>Remove bouquet</asp:LinkButton>
                                    </div>

                                    <asp:Repeater ID="rptItems" runat="server" OnItemCommand="rptItems_ItemCommand">
                                        <ItemTemplate>
                                            <div class="cart-item">
                                                <img src="<%#: ResolveUrl(((CartItem)Container.DataItem).ImageUrl) %>" alt="<%#: ((CartItem)Container.DataItem).FlowerName %>" />
                                                <div>
                                                    <h4><%#: ((CartItem)Container.DataItem).FlowerName %></h4>
                                                    <p class="meta"><%#: Money.Rupees(((CartItem)Container.DataItem).UnitPrice) %> per stem</p>
                                                    <div class="cart-qty">
                                                        <label for="<%# ((System.Web.UI.WebControls.RepeaterItem)Container).FindControl("txtQty").ClientID %>">Quantity</label>
                                                        <asp:TextBox ID="txtQty" runat="server" TextMode="Number" min="1" max="50"
                                                            Text='<%# ((CartItem)Container.DataItem).Quantity %>' />
                                                        <asp:LinkButton ID="lbUpdate" runat="server" CssClass="link-button" CommandName="update"
                                                            CommandArgument='<%# ((CartItem)Container.DataItem).CartId %>' CausesValidation="false">Update</asp:LinkButton>
                                                        <asp:LinkButton ID="lbRemove" runat="server" CssClass="link-danger" CommandName="remove"
                                                            CommandArgument='<%# ((CartItem)Container.DataItem).CartId %>' CausesValidation="false">Remove</asp:LinkButton>
                                                    </div>
                                                </div>
                                                <div class="cart-line-total"><%#: Money.Rupees(((CartItem)Container.DataItem).LineTotal) %></div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <asp:PlaceHolder ID="phBouquetOptions" runat="server" Visible='<%# ((CartGroup)Container.DataItem).IsBouquet %>'>
                                        <div class="bouquet-options">
                                            <div>
                                                <label for="<%# ((System.Web.UI.WebControls.RepeaterItem)Container).FindControl("ddlWrap").ClientID %>">Wrapping</label>
                                                <asp:DropDownList ID="ddlWrap" runat="server" />
                                            </div>
                                            <div>
                                                <label for="<%# ((System.Web.UI.WebControls.RepeaterItem)Container).FindControl("ddlRibbon").ClientID %>">Ribbon</label>
                                                <asp:DropDownList ID="ddlRibbon" runat="server" />
                                            </div>
                                        </div>
                                        <asp:LinkButton ID="lbSaveOptions" runat="server" CssClass="link-button" CommandName="saveOptions"
                                            CommandArgument='<%# ((CartGroup)Container.DataItem).BouquetId.ToString() %>' CausesValidation="false">Save wrapping &amp; ribbon</asp:LinkButton>
                                        <div class="group-total" style="margin-top: 8px;">
                                            <span>Wrapping &amp; ribbon</span>
                                            <span><%#: Money.Rupees(((CartGroup)Container.DataItem).WrappingPrice + ((CartGroup)Container.DataItem).RibbonPrice) %></span>
                                        </div>
                                    </asp:PlaceHolder>

                                    <div class="group-total">
                                        <span>Subtotal</span>
                                        <strong><%#: Money.Rupees(((CartGroup)Container.DataItem).GroupTotal) %></strong>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>

                        <div class="cart-actions">
                            <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Continue Shopping</a>
                            <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Add Another Bouquet</a>
                        </div>
                    </div>

                    <!-- ===== Checkout ===== -->
                    <aside>
                        <div class="side-card checkout-card">
                            <h2>Checkout</h2>

                            <div class="totals">
                                <div class="row"><span>Subtotal</span><asp:Literal ID="litSubtotal" runat="server" /></div>
                                <div class="row"><span>Delivery fee</span><asp:Literal ID="litDelivery" runat="server" /></div>
                                <div class="row grand"><span>Final amount</span><asp:Literal ID="litTotal" runat="server" /></div>
                            </div>

                            <div class="checkout-divider"></div>

                            <div class="form-group">
                                <label for="<%= txtName.ClientID %>">Full name</label>
                                <asp:TextBox ID="txtName" runat="server" MaxLength="100" autocomplete="name" />
                            </div>
                            <div class="form-group">
                                <label for="<%= txtPhone.ClientID %>">Phone number</label>
                                <asp:TextBox ID="txtPhone" runat="server" TextMode="Phone" MaxLength="20" autocomplete="tel" />
                            </div>
                            <div class="form-group">
                                <label for="<%= txtAddress.ClientID %>">Full delivery address</label>
                                <asp:TextBox ID="txtAddress" runat="server" TextMode="MultiLine" Rows="3" MaxLength="500" />
                            </div>
                            <div class="form-group">
                                <label for="<%= txtDate.ClientID %>">Preferred delivery date</label>
                                <asp:TextBox ID="txtDate" runat="server" TextMode="Date" />
                                <div class="form-hint">Choose a date from tomorrow up to 60 days ahead.</div>
                            </div>

                            <asp:Button ID="btnPlaceOrder" runat="server" Text="Place Order" CssClass="btn btn-block" OnClick="btnPlaceOrder_Click" />
                            <p class="estimate-note">Payment is collected on delivery. Prices are confirmed by our system when you place the order.</p>
                        </div>
                    </aside>

                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
