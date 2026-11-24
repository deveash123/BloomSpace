<%@ Page Title="Bloom Space — Every Bloom Tells a Story" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="Home.aspx.cs" Inherits="BloomSpace.Pages.HomePage" %>
<%@ Import Namespace="System.Web" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <asp:Panel ID="pnlGlobalError" runat="server" Visible="false" CssClass="container">
        <div class="alert alert-error">
            Something unexpected happened. Please try again, or contact us if the problem continues.
        </div>
    </asp:Panel>

    <asp:Panel ID="pnlWelcome" runat="server" Visible="false" CssClass="container">
        <div class="alert alert-success">
            Welcome to Bloom Space, <asp:Literal ID="litWelcomeName" runat="server" />.
            Your account is ready and your first bloom awaits.
        </div>
    </asp:Panel>

    <!-- ================= HERO ================= -->
    <section class="hero">
        <div class="container hero-grid">
            <div class="hero-copy">
                <span class="eyebrow">The art of giving flowers</span>
                <h1>Flowers,<br />thoughtfully<br /><em>arranged.</em></h1>
                <p class="hero-lede">
                    Nature's finest expressions, carefully curated into unforgettable
                    arrangements for life's most meaningful moments.
                </p>
                <div class="hero-actions">
                    <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">
                        Shop flowers <span class="btn-arrow" aria-hidden="true">&rarr;</span>
                    </a>
                    <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">
                        Create your bouquet
                    </a>
                </div>
                <div class="hero-note">
                    <span class="hero-note-line" aria-hidden="true"></span>
                    Fresh flowers. Timeless feelings.
                </div>
            </div>

            <div class="hero-visual">
                <div class="hero-frame">
                    <img src="<%= ResolveUrl("~/Images/Flowers/hero-bouquet.svg") %>"
                         alt="A signature Bloom Space bouquet arranged in a ceramic vase" />
                </div>
                <div class="hero-caption">
                    <span>01 / Signature collection</span>
                    <span>The beauty of simplicity</span>
                </div>
                <div class="hero-seal" aria-hidden="true">
                    <span>Hand-tied</span>
                    <strong>Bloom Space</strong>
                    <span>Chennai</span>
                </div>
            </div>
        </div>
    </section>

    <!-- ================= TRUST STRIP ================= -->
    <section class="trust-strip" aria-label="Why Bloom Space">
        <div class="container trust-grid">
            <div class="trust-item"><span class="trust-mark" aria-hidden="true"></span>Handpicked flowers</div>
            <div class="trust-item"><span class="trust-mark" aria-hidden="true"></span>Thoughtful arrangements</div>
            <div class="trust-item"><span class="trust-mark" aria-hidden="true"></span>Delivered with care</div>
            <div class="trust-item"><span class="trust-mark" aria-hidden="true"></span>Made for your moments</div>
        </div>
    </section>

    <!-- ================= CATEGORIES ================= -->
    <section class="section categories">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="eyebrow">Discover Bloom Space</span>
                    <h2>Find your <em>perfect bloom.</em></h2>
                </div>
                <a class="text-link" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">View all flowers <span aria-hidden="true">&rarr;</span></a>
            </div>

            <div class="category-grid">
                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Roses">
                    <img src="<%= ResolveUrl("~/Images/Flowers/rose.svg") %>" alt="Rose bouquets" loading="lazy" />
                    <span class="category-index">01</span>
                    <span class="category-body">
                        <span class="category-name">Roses</span>
                        <span class="category-link">Explore the collection <span aria-hidden="true">&rarr;</span></span>
                    </span>
                </a>

                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Tulips">
                    <img src="<%= ResolveUrl("~/Images/Flowers/tulip.svg") %>" alt="Tulip bouquets" loading="lazy" />
                    <span class="category-index">02</span>
                    <span class="category-body">
                        <span class="category-name">Tulips</span>
                        <span class="category-link">Explore the collection <span aria-hidden="true">&rarr;</span></span>
                    </span>
                </a>

                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Lilies">
                    <img src="<%= ResolveUrl("~/Images/Flowers/lily.svg") %>" alt="Lily bouquets" loading="lazy" />
                    <span class="category-index">03</span>
                    <span class="category-body">
                        <span class="category-name">Lilies</span>
                        <span class="category-link">Explore the collection <span aria-hidden="true">&rarr;</span></span>
                    </span>
                </a>

                <a class="category-card" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>?category=Sunflowers">
                    <img src="<%= ResolveUrl("~/Images/Flowers/sunflower.svg") %>" alt="Sunflower bouquets" loading="lazy" />
                    <span class="category-index">04</span>
                    <span class="category-body">
                        <span class="category-name">Sunflowers</span>
                        <span class="category-link">Explore the collection <span aria-hidden="true">&rarr;</span></span>
                    </span>
                </a>
            </div>
        </div>
    </section>

    <!-- ================= FEATURED ================= -->
    <section class="section featured">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="eyebrow">Curated with love</span>
                    <h2>The signature <em>collection.</em></h2>
                </div>
                <span class="section-note">Flowers that speak without words.</span>
            </div>

            <asp:Panel ID="pnlFeaturedError" runat="server" Visible="false" CssClass="alert alert-error">
                <asp:Literal ID="litFeaturedError" runat="server" />
            </asp:Panel>

            <div class="product-grid">
                <asp:Repeater ID="rptFeatured" runat="server">
                    <ItemTemplate>
                        <article class="product-card">
                            <div class="product-media">
                                <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Name") %>' loading="lazy" />
                                <span class="product-badge" runat="server" visible='<%# Eval("HasBadge") %>'><%#: Eval("Badge") %></span>
                            </div>
                            <div class="product-info">
                                <span class="product-category"><%#: Eval("Category") %></span>
                                <h3><%#: Eval("Name") %></h3>
                                <p><%#: Eval("Description") %></p>
                                <div class="product-foot">
                                    <span class="product-price"><%#: Eval("PriceText") %></span>
                                    <a class="text-link" href='<%# ResolveUrl("~/Pages/Shop.aspx") + "?category=" + HttpUtility.UrlEncode(Convert.ToString(Eval("Category"))) %>'>View collection <span aria-hidden="true">&rarr;</span></a>
                                </div>
                            </div>
                        </article>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <div class="center-action">
                <a class="btn btn-outline" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Discover all flowers</a>
            </div>
        </div>
    </section>

    <!-- ================= CUSTOM TEASER ================= -->
    <section class="custom-teaser">
        <div class="custom-teaser-media">
            <img src="<%= ResolveUrl("~/Images/Flowers/custom-bouquet.svg") %>" alt="A custom bouquet wrapped in kraft paper" loading="lazy" />
        </div>
        <div class="custom-teaser-copy">
            <span class="eyebrow">A personal touch</span>
            <h2>Not just a bouquet.<br /><em>Your bouquet.</em></h2>
            <p>
                Choose your favourite flowers, select your wrapping and finish it
                with a ribbon that feels just right. Create something uniquely yours.
            </p>
            <a class="btn btn-light" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">
                Design your bouquet <span class="btn-arrow" aria-hidden="true">&rarr;</span>
            </a>
            <span class="custom-number">01 &mdash; Made by you</span>
        </div>
    </section>

    <!-- ================= STORY ================= -->
    <section class="section story">
        <div class="container story-inner">
            <span class="eyebrow">A little about us</span>
            <h2>More than flowers.<br /><em>Moments that bloom.</em></h2>
            <p>
                We believe flowers have a language of their own. At Bloom Space,
                every arrangement is thoughtfully designed to turn everyday
                moments into lasting memories.
            </p>
            <a class="text-link" href="<%= ResolveUrl("~/Pages/About.aspx") %>">Our story <span aria-hidden="true">&rarr;</span></a>
        </div>
    </section>

    <!-- ================= TRUST CARDS ================= -->
    <section class="section trust-section">
        <div class="container trust-cards">
            <article class="trust-card">
                <span class="trust-card-number">01</span>
                <h3>Freshly cut, always</h3>
                <p>We source our stems in small batches so every bouquet arrives looking as though it was gathered that morning.</p>
            </article>
            <article class="trust-card">
                <span class="trust-card-number">02</span>
                <h3>Delivered with care</h3>
                <p>Each order is hand-tied, wrapped and cushioned by our florists, then delivered on the date you choose.</p>
            </article>
            <article class="trust-card">
                <span class="trust-card-number">03</span>
                <h3>Made for your moment</h3>
                <p>From first anniversaries to quiet Tuesdays, we help you say the thing that flowers say best.</p>
            </article>
        </div>
    </section>

</asp:Content>
