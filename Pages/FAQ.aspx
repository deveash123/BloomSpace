<%@ Page Title="FAQs | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-compact">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">Good to know</span>
                <h1>Questions, <em>answered.</em></h1>
                <p>Everything you might want to know before sending flowers with Bloom Space.</p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number">10</span>
                <span class="page-hero-label">Common<br />questions</span>
            </div>
        </div>
    </section>

    <section class="section faq-section">
        <div class="container faq-layout">

            <aside class="faq-aside">
                <span class="eyebrow">On this page</span>
                <nav class="faq-nav" aria-label="FAQ sections">
                    <a href="#ordering">Ordering</a>
                    <a href="#delivery">Delivery</a>
                    <a href="#flowers">Flowers &amp; care</a>
                    <a href="#custom">Custom bouquets</a>
                </nav>
                <div class="faq-help">
                    <h3>Still wondering?</h3>
                    <p>Our florists are happy to help with a specific date, flower or message.</p>
                    <a class="text-link" href="<%= ResolveUrl("~/Pages/Contact.aspx") %>">Contact us <span aria-hidden="true">&rarr;</span></a>
                </div>
            </aside>

            <div class="faq-content">

                <section class="faq-group" id="ordering">
                    <div class="faq-group-heading">
                        <span class="faq-group-number">01</span>
                        <h2>Ordering</h2>
                    </div>

                    <details class="faq-item" open>
                        <summary>Do I need an account to place an order?</summary>
                        <div class="faq-answer">
                            <p>Yes. An account lets us keep your bag, save your delivery details and show you your order confirmation later. Creating one takes less than a minute, and your password is stored using salted PBKDF2 hashing.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>How far in advance should I order?</summary>
                        <div class="faq-answer">
                            <p>We ask for at least one day's notice so our florists can source and arrange your stems. You can choose any delivery date from tomorrow up to 30 days ahead at checkout.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>Can I change my order after placing it?</summary>
                        <div class="faq-answer">
                            <p>If your delivery date is still at least two days away, contact us with your order number and we will do our best to help. Once a bouquet has been tied for delivery, changes may not be possible.</p>
                        </div>
                    </details>
                </section>

                <section class="faq-group" id="delivery">
                    <div class="faq-group-heading">
                        <span class="faq-group-number">02</span>
                        <h2>Delivery</h2>
                    </div>

                    <details class="faq-item">
                        <summary>Where do you deliver?</summary>
                        <div class="faq-answer">
                            <p>We currently deliver across Chennai and to selected pincodes in Tamil Nadu. If you are unsure whether we reach your area, send us a message with the pincode before ordering.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>How much is delivery?</summary>
                        <div class="faq-answer">
                            <p>Delivery is &#8377;149 per order. Orders above &#8377;2,000 receive complimentary delivery. The exact fee is always shown in your bag and at checkout before you confirm.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>What happens if nobody is home?</summary>
                        <div class="faq-answer">
                            <p>Our courier will call the phone number on your order. If there is no answer, we will wait briefly and then contact you to arrange a safe handover or a redelivery where possible.</p>
                        </div>
                    </details>
                </section>

                <section class="faq-group" id="flowers">
                    <div class="faq-group-heading">
                        <span class="faq-group-number">03</span>
                        <h2>Flowers &amp; care</h2>
                    </div>

                    <details class="faq-item">
                        <summary>How should I care for my bouquet?</summary>
                        <div class="faq-answer">
                            <p>Trim the stems at an angle, change the water every two days, and keep the bouquet away from direct sunlight and ripening fruit. A little cool water and a clean vase make a noticeable difference.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>Will my flowers look exactly like the illustration?</summary>
                        <div class="faq-answer">
                            <p>Our illustrations show the style, palette and mood of each arrangement. Because flowers are natural, individual stems may vary slightly in shape and shade. We always match the overall look and quality.</p>
                        </div>
                    </details>
                </section>

                <section class="faq-group" id="custom">
                    <div class="faq-group-heading">
                        <span class="faq-group-number">04</span>
                        <h2>Custom bouquets</h2>
                    </div>

                    <details class="faq-item">
                        <summary>How does the custom bouquet builder work?</summary>
                        <div class="faq-answer">
                            <p>Choose your flowers and quantities, select a wrapping paper and finish with a ribbon. The live estimate updates as you design. When you add the bouquet to your bag, our server recalculates the price from the live catalogue before checkout.</p>
                        </div>
                    </details>

                    <details class="faq-item">
                        <summary>Can I mix more than one flower type?</summary>
                        <div class="faq-answer">
                            <p>Absolutely. You can combine roses, tulips, lilies and sunflowers in one bouquet, up to 100 stems in total and up to 50 stems of any single flower.</p>
                        </div>
                    </details>

                </section>

            </div>
        </div>
    </section>

</asp:Content>
