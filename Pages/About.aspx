<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="About.aspx.cs" Inherits="Pages_About" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">About Bloom Space</span>
            <h1>Every Bloom Tells a Story.</h1>
            <p>A small floral boutique built on the belief that flowers are the most honest way to say what we feel.</p>
        </div>
    </section>

    <section class="section">
        <div class="container split">
            <div>
                <img src="<%= ResolveUrl("~/Images/Flowers/story-flowers.jpg") %>" alt="Flowers arranged on a table" loading="lazy" />
            </div>
            <div class="split-text">
                <span class="eyebrow">Our story</span>
                <h2>Where It All Began</h2>
                <p>Bloom Space started as a love for the small rituals around flowers: choosing stems at the market, trimming them, and tying them with a ribbon for someone special.</p>
                <p>We wanted everyone to enjoy that same joy online. So instead of fixed arrangements, we built a space where you design the bouquet yourself, from the first rose to the final bow.</p>
            </div>
        </div>
    </section>

    <section class="section bg-blush">
        <div class="container">
            <div class="section-head">
                <span class="eyebrow">Our mission</span>
                <h2>Make Every Gift Personal</h2>
                <p>Our mission is to make thoughtful, beautiful flowers easy to give &mdash; fresh, fairly priced, and as unique as the person receiving them.</p>
            </div>
            <div class="values-grid">
                <div class="value-card">
                    <h3>Freshness First</h3>
                    <p>Flowers are arranged close to delivery so they arrive at their best and last longer.</p>
                </div>
                <div class="value-card">
                    <h3>Thoughtful Design</h3>
                    <p>From paper to ribbon, every detail is chosen to look elegant and feel considered.</p>
                </div>
                <div class="value-card">
                    <h3>Honest Pricing</h3>
                    <p>Clear per-stem prices and one flat delivery fee. What you see is what you pay.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="cta-band">
        <div class="container">
            <h2>Start Your Story</h2>
            <p>Pick your favourite blooms or build a bouquet from scratch.</p>
            <a class="btn btn-light" href="<%= ResolveUrl("~/Pages/CustomBouquet.aspx") %>">Design Your Bouquet</a>
        </div>
    </section>

</asp:Content>
