<%@ Page Title="FAQ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="FAQ.aspx.cs" Inherits="Pages_FAQ" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Help centre</span>
            <h1>Frequently Asked Questions</h1>
            <p>Quick answers to the things customers ask us most.</p>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="faq-list">
                <details open>
                    <summary>Do I need an account to order?</summary>
                    <p>Yes. You can browse freely, but you need a free account to add flowers to your cart and place an order. It only takes a minute to register.</p>
                </details>
                <details>
                    <summary>How does the custom bouquet builder work?</summary>
                    <p>Choose any mix of roses, tulips, lilies and sunflowers, set how many stems of each you want, then pick a wrapping paper and a ribbon. The price updates instantly as you design.</p>
                </details>
                <details>
                    <summary>Is the price shown in the builder final?</summary>
                    <p>The builder shows a live estimate. When you add the bouquet to your cart, we confirm every price from our catalogue, so your cart and order always show the correct amounts.</p>
                </details>
                <details>
                    <summary>How much is delivery?</summary>
                    <p>We charge one flat delivery fee per order, shown in the banner at the top of every page and added to your total at checkout.</p>
                </details>
                <details>
                    <summary>Can I choose my delivery date?</summary>
                    <p>Yes. At checkout you can choose any date from tomorrow up to 60 days ahead.</p>
                </details>
                <details>
                    <summary>Can I change my cart after adding items?</summary>
                    <p>Of course. In your cart you can change quantities, remove items, and switch the wrapping and ribbon of any custom bouquet before you check out.</p>
                </details>
                <details>
                    <summary>How do I pay?</summary>
                    <p>Payment is collected on delivery. Your confirmation page shows the exact amount due.</p>
                </details>
                <details>
                    <summary>How do I keep my flowers fresh?</summary>
                    <p>Trim the stems at an angle, place them in clean water, keep them away from direct sun and heat, and change the water every day or two.</p>
                </details>
                <details>
                    <summary>I have a question that is not listed here.</summary>
                    <p>We would love to help. Send us a message from the <a href="<%= ResolveUrl("~/Pages/Contact.aspx") %>">Contact page</a>.</p>
                </details>
            </div>
        </div>
    </section>

</asp:Content>
