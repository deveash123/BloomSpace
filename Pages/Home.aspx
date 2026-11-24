<%@ Page Title="Every Bloom Tells a Story" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Home.aspx.cs" Inherits="Pages_Home" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ===== Hero ===== -->
    <section class="hero">
        <div class="hero-overlay"></div>
        <div class="hero-inner">
            <div class="hero-copy">
                <span class="eyebrow">Fresh flowers &middot; Custom bouquets</span>
                <h1>Every Bloom <em>Tells a Story.</em></h1>
                <p class="hero-text">Hand-picked stems and bouquets designed by you, wrapped with care and delivered to the people who matter most.</p>
                <div class="hero-actions">
                    <a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop Flowers</a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Custom Bouquet</a>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== Categories ===== -->
    <section class="section">
        <div class="container">
            <div class="section-head">
                <span class="eyebrow">Browse by flower</span>
                <h2>Choose Your Favourite</h2>
                <p>Four beloved blooms, each with its own character and meaning.</p>
            </div>
            <div class="category-grid">
                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Roses") %>">
                    <img src="<%= ResolveUrl("~/Images/Flowers/rose-red.jpg") %>" alt="Roses" loading="lazy" />
                    <h3>Roses</h3><span>SHOP ROSES</span>
                </a>
                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Tulips") %>">
                    <img src="<%= ResolveUrl("~/Images/Flowers/tulip-pink.jpg") %>" alt="Tulips" loading="lazy" />
                    <h3>Tulips</h3><span>SHOP TULIPS</span>
                </a>
                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Lilies") %>">
                    <img src="<%= ResolveUrl("~/Images/Flowers/lily-white.jpg") %>" alt="Lilies" loading="lazy" />
                    <h3>Lilies</h3><span>SHOP LILIES</span>
                </a>
                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx?category=Sunflowers") %>">
                    <img src="<%= ResolveUrl("~/Images/Flowers/sunflower.jpg") %>" alt="Sunflowers" loading="lazy" />
                    <h3>Sunflowers</h3><span>SHOP SUNFLOWERS</span>
                </a>
            </div>
        </div>
    </section>

    <!-- ===== Featured flowers (from SQL Server) ===== -->
    <section class="section bg-white">
        <div class="container">
            <div class="section-head">
                <span class="eyebrow">Featured</span>
                <h2>Fresh From the Studio</h2>
                <p>A few of our favourite stems this season.</p>
            </div>

            <asp:Panel ID="pnlFeatured" runat="server">
                <div class="product-grid">
                    <asp:Repeater ID="rptFeatured" runat="server">
                        <ItemTemplate>
                            <article class="product-card">
                                <a class="product-media" href="<%# ResolveUrl("~/Pages/Shop.aspx?category=" + Eval("Category")) %>">
                                    <img src="<%#: ResolveUrl((string)Eval("ImageUrl")) %>" alt="<%#: Eval("Name") %>" loading="lazy" />
                                </a>
                                <div class="product-body">
                                    <span class="product-cat"><%#: Eval("Category") %></span>
                                    <h3><%#: Eval("Name") %></h3>
                                    <div class="product-foot">
                                        <span class="price">&#8377;<%#: ((decimal)Eval("UnitPrice")).ToString("N2", new System.Globalization.CultureInfo("en-IN")) %> <small>/ stem</small></span>
                                        <a class="btn btn-small btn-outline" href="<%# ResolveUrl("~/Pages/Shop.aspx?category=" + Eval("Category")) %>">View</a>
                                    </div>
                                </div>
                            </article>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>
            <asp:Panel ID="pnlFeaturedEmpty" runat="server" Visible="false" CssClass="center">
                <p class="muted">Our featured flowers are being arranged. Please check back soon.</p>
            </asp:Panel>

            <div class="center" style="margin-top: 40px;">
                <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">View All Flowers</a>
            </div>
        </div>
    </section>

    <!-- ===== Brand story ===== -->
    <section class="section">
        <div class="container split">
            <div class="split-media">
                <img src="<%= ResolveUrl("~/Images/Flowers/story-flowers.jpg") %>" alt="Flowers laid out on a table" loading="lazy" />
            </div>
            <div class="split-text">
                <span class="eyebrow">Our story</span>
                <h2>Flowers That Say What Words Can&rsquo;t</h2>
                <p>Bloom Space began with a simple belief: a bouquet is never just a bouquet. It is a birthday remembered, an apology softened, a celebration shared.</p>
                <p>That is why we let you design your own &mdash; choose every stem, the wrapping and the ribbon &mdash; so each gift feels as personal as the story behind it.</p>
                <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/About.aspx") %>">Read Our Story</a>
            </div>
        </div>
    </section>

    <!-- ===== Trust section ===== -->
    <section class="section bg-blush">
        <div class="container">
            <div class="section-head">
                <span class="eyebrow">Why Bloom Space</span>
                <h2>Made With Care, Delivered With Love</h2>
            </div>
            <div class="trust-grid">
                <div class="trust-item">
                    <div class="trust-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 21V11" /><path d="M12 11c0-4 2.5-6.5 6.5-6.5 0 4-2.5 6.5-6.5 6.5z" /><path d="M12 14c0-3-2-5-5-5 0 3 2 5 5 5z" /></svg>
                    </div>
                    <h4>Fresh Flowers</h4>
                    <p>Sourced and arranged on the day of delivery.</p>
                </div>
                <div class="trust-item">
                    <div class="trust-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M3 7h11v9H3z" /><path d="M14 10h4l3 3v3h-7" /><circle cx="7" cy="17.5" r="1.6" /><circle cx="17" cy="17.5" r="1.6" /></svg>
                    </div>
                    <h4>Careful Delivery</h4>
                    <p>Pick your preferred date. One simple flat fee.</p>
                </div>
                <div class="trust-item">
                    <div class="trust-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 3l7 3v5c0 4.5-3 8-7 10-4-2-7-5.5-7-10V6z" /><path d="M9 12l2.2 2.2L15.5 10" /></svg>
                    </div>
                    <h4>Secure Accounts</h4>
                    <p>Passwords are encrypted and never stored in plain text.</p>
                </div>
                <div class="trust-item">
                    <div class="trust-icon">
                        <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 20.5s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10.5c0 5.600-7 10-7 10z" /></svg>
                    </div>
                    <h4>Made Personal</h4>
                    <p>Design your own bouquet, stem by stem.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- ===== Call to action ===== -->
    <section class="cta-band">
        <div class="container">
            <h2>Ready to Create Something Beautiful?</h2>
            <p>Build a bouquet that is unmistakably yours, with live pricing as you design.</p>
            <a class="btn btn-light" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design Your Bouquet</a>
        </div>
    </section>

</asp:Content>
