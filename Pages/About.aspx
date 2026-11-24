<%@ Page Title="Our Story | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">Our story</span>
                <h1>Flowers, with a little <em>more meaning.</em></h1>
                <p>
                    Bloom Space began with a simple belief: a bouquet should feel like
                    it was made for one person, on one day, for one reason.
                </p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number">2026</span>
                <span class="page-hero-label">Hand-tied<br />in Chennai</span>
            </div>
        </div>
    </section>

    <section class="section story-split-section">
        <div class="container story-split">
            <div class="story-media">
                <img src="<%= ResolveUrl("~/Images/Flowers/custom-bouquet.svg") %>" alt="A hand-tied Bloom Space bouquet in kraft paper" loading="lazy" />
                <span class="story-media-caption">01 &mdash; The studio, Anna Nagar</span>
            </div>

            <div class="story-copy">
                <span class="eyebrow">Where it began</span>
                <h2>A small studio,<br /><em>a large idea.</em></h2>
                <p>
                    Bloom Space started as a corner of a Chennai flower market, a pair of
                    scissors and a notebook of colour combinations. We wanted to make
                    flowers feel less like a last-minute purchase and more like a
                    considered gesture.
                </p>
                <p>
                    Today, every bouquet is still tied by hand. We work in small batches,
                    choose stems that are in season, and wrap each arrangement in paper
                    we would be happy to give someone ourselves.
                </p>
                <div class="story-signature">
                    <span class="signature-line" aria-hidden="true"></span>
                    <span>The Bloom Space florists</span>
                </div>
            </div>
        </div>
    </section>

    <section class="section mission-section">
        <div class="container mission-inner">
            <span class="eyebrow">Our mission</span>
            <h2>To make giving flowers feel <em>personal again.</em></h2>
            <p>
                We believe the best bouquets are not the biggest ones. They are the ones
                that notice a favourite colour, a remembered flower, a quiet inside joke.
                That is why we offer a signature collection for the moments that need
                no explanation, and a custom studio for the ones that do.
            </p>
        </div>
    </section>

    <section class="section values-section">
        <div class="container">
            <div class="section-heading">
                <div>
                    <span class="eyebrow">What we care about</span>
                    <h2>Three things, <em>always.</em></h2>
                </div>
            </div>

            <div class="values-grid">
                <article class="value-card">
                    <span class="value-number">01</span>
                    <h3>Thoughtful sourcing</h3>
                    <p>We buy in small batches from growers we know, choosing stems for scent, texture and the way they open over time.</p>
                </article>
                <article class="value-card">
                    <span class="value-number">02</span>
                    <h3>Hand-tied artistry</h3>
                    <p>No two bouquets leave the studio looking exactly the same. Each one is arranged by hand, with an eye for balance and movement.</p>
                </article>
                <article class="value-card">
                    <span class="value-number">03</span>
                    <h3>Delivered with care</h3>
                    <p>Our couriers carry every order upright, cushioned and on time, because the journey matters as much as the arrival.</p>
                </article>
            </div>
        </div>
    </section>

    <section class="section quote-section">
        <div class="container quote-inner">
            <span class="quote-mark" aria-hidden="true">&ldquo;</span>
            <blockquote>
                Every bloom tells a story. Our job is simply to help you tell yours.
            </blockquote>
            <span class="quote-credit">The Bloom Space studio</span>
        </div>
    </section>

    <section class="cta-band">
        <div class="container cta-band-inner">
            <div>
                <span class="eyebrow">Find your flowers</span>
                <h2>Ready to send something <em>beautiful?</em></h2>
            </div>
            <div class="cta-band-actions">
                <a class="btn btn-light" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop the collection</a>
                <a class="btn btn-outline-light" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design your own</a>
            </div>
        </div>
    </section>

</asp:Content>
