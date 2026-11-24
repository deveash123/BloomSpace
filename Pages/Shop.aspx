<%@ Page Title="Shop Flowers" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Shop.aspx.cs" Inherits="Pages_Shop" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">The flower shop</span>
            <h1>Shop Flowers</h1>
            <p>Fresh stems, priced per stem in Indian Rupees. Add a few to your cart, or build a full bouquet of your own.</p>
        </div>
    </section>

    <section class="section-tight">
        <div class="container">

            <nav class="filter-bar" aria-label="Flower categories">
                <a class="filter-pill <%= Tab(null) %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">All</a>
                <a class="filter-pill <%= Tab("Roses") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Roses") %>">Roses</a>
                <a class="filter-pill <%= Tab("Tulips") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Tulips") %>">Tulips</a>
                <a class="filter-pill <%= Tab("Lilies") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Lilies") %>">Lilies</a>
                <a class="filter-pill <%= Tab("Sunflowers") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Sunflowers") %>">Sunflowers</a>
            </nav>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success" role="status">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <asp:Panel ID="pnlProducts" runat="server">
                <div class="product-grid">
                    <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                        <ItemTemplate>
                            <article class="product-card">
                                <div class="product-media">
                                    <img src="<%#: ResolveUrl((string)Eval("ImageUrl")) %>" alt="<%#: Eval("Name") %>" loading="lazy" />
                                </div>
                                <div class="product-body">
                                    <span class="product-cat"><%#: Eval("Category") %></span>
                                    <h3><%#: Eval("Name") %></h3>
                                    <p class="product-desc"><%#: Eval("Description") %></p>
                                    <div class="product-foot">
                                        <span class="price">&#8377;<%#: ((decimal)Eval("UnitPrice")).ToString("N2", new System.Globalization.CultureInfo("en-IN")) %> <small>/ stem</small></span>
                                        <asp:Button ID="btnAdd" runat="server" Text="Add to Cart" CssClass="btn btn-small"
                                            CommandName="add" CommandArgument='<%# Eval("FlowerId") %>' CausesValidation="false" />
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <div class="empty-icon">
                    <svg viewBox="0 0 24 24" width="38" height="38" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 21V11" /><path d="M12 11c0-4 2.5-6.5 6.500-6.5 0 4-2.5 6.500-6.500 6.500z" /><path d="M12 14c0-3-2-5-5-5 0 3 2 5 5 5z" /></svg>
                </div>
                <h2>No flowers here yet</h2>
                <p>We could not find any flowers in this category right now. Please check back soon or browse everything we have.</p>
                <div class="empty-actions">
                    <a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">View All Flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Custom Bouquet</a>
                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
