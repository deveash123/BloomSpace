<%@ Page Title="Shop Flowers | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Shop.aspx.cs" Inherits="BloomSpace.Pages.ShopPage" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-compact">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">The collection</span>
                <h1>Flowers for <em>every feeling.</em></h1>
                <p>Ready-made bouquets, hand-tied by our florists and delivered across India.</p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number">08</span>
                <span class="page-hero-label">Seasonal<br />bouquets</span>
            </div>
        </div>
    </section>

    <section class="section shop-section">
        <div class="container">

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-success">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <div class="shop-toolbar">
                <div class="filter-buttons" role="group" aria-label="Filter bouquets by flower">
                    <a class="<%= FilterClass("") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">All flowers</a>
                    <a class="<%= FilterClass("Roses") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Roses">Roses</a>
                    <a class="<%= FilterClass("Tulips") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Tulips">Tulips</a>
                    <a class="<%= FilterClass("Lilies") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Lilies">Lilies</a>
                    <a class="<%= FilterClass("Sunflowers") %>" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Sunflowers">Sunflowers</a>
                </div>

                <label class="shop-search">
                    <svg viewBox="0 0 24 24" aria-hidden="true">
                        <circle cx="11" cy="11" r="6.5" />
                        <path d="m16 16 4.5 4.5" />
                    </svg>
                    <input type="search" id="shopSearch" placeholder="Search this collection..." autocomplete="off" aria-label="Search this collection" />
                </label>
            </div>

            <div class="shop-meta">
                <span class="shop-meta-title"><asp:Literal ID="litCategoryLabel" runat="server" /></span>
                <span class="result-count" id="shopCount"><asp:Literal ID="litResultCount" runat="server" /></span>
            </div>

            <div class="product-grid product-grid-shop" id="shopGrid">
                <asp:Repeater ID="rptProducts" runat="server">
                    <ItemTemplate>
                        <article class="product-card" data-name='<%#: Eval("Name") %>' data-category='<%#: Eval("Category") %>'>
                            <div class="product-media">
                                <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Name") %>' loading="lazy" />
                                <span class="product-badge" runat="server" visible='<%# Eval("HasBadge") %>'><%#: Eval("Badge") %></span>
                                <asp:LinkButton ID="lnkAdd" runat="server"
                                    CssClass="quick-add"
                                    CommandArgument='<%# Eval("FlowerId") %>'
                                    CausesValidation="false"
                                    OnCommand="rptProducts_Add">
                                    Add to bag <span aria-hidden="true">+</span>
                                </asp:LinkButton>
                            </div>
                            <div class="product-info">
                                <span class="product-category"><%#: Eval("Category") %></span>
                                <h3><%#: Eval("Name") %></h3>
                                <p><%#: Eval("Description") %></p>
                                <div class="product-foot">
                                    <span class="product-price"><%#: Eval("PriceText") %></span>
                                    <span class="product-note">Hand-tied</span>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state">
                <span class="empty-mark" aria-hidden="true"></span>
                <h2>No blooms here just yet.</h2>
                <p>This collection is resting. Explore all of our flowers, or design a bouquet that is entirely your own.</p>
                <div class="empty-actions">
                    <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">View all flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Build a bouquet</a>
                </div>
            </asp:Panel>

            <div class="shop-note">
                <span>Complimentary delivery on orders above &#8377;2,000.</span>
                <span>Every bouquet is hand-tied on the morning of delivery.</span>
            </div>

        </div>
    </section>

</asp:Content>
