<%@ Page Title="Delivery Policy | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-compact">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">Delivery policy</span>
                <h1>From our studio <em>to your door.</em></h1>
                <p>How we prepare, wrap and deliver your flowers, and what you can expect on the day.</p>
            </div>
            <div class="page-hero-aside">
                <span class="page-hero-number">24h</span>
                <span class="page-hero-label">Minimum<br />notice</span>
            </div>
        </div>
    </section>

    <section class="section policy-section">
        <div class="container policy-layout">

            <div class="policy-main">

                <section class="policy-block">
                    <span class="policy-number">01</span>
                    <h2>How delivery works</h2>
                    <p>Every order follows the same careful path:</p>
                    <ol class="policy-steps">
                        <li><strong>We source your stems.</strong> Flowers are selected in the early morning, close to your delivery date.</li>
                        <li><strong>We hand-tie your bouquet.</strong> Your arrangement is built, wrapped and finished with your chosen ribbon.</li>
                        <li><strong>We cushion and carry.</strong> Bouquets travel upright in a water source, protected from heat and movement.</li>
                        <li><strong>We call before arriving.</strong> Our courier calls the phone number on your order so someone can receive the flowers.</li>
                    </ol>
                </section>

                <section class="policy-block">
                    <span class="policy-number">02</span>
                    <h2>Delivery charges</h2>
                    <p>Delivery is a flat fee per order, regardless of how many bouquets you send in that order.</p>

                    <div class="table-wrap">
                        <table class="fee-table">
                            <thead>
                                <tr>
                                    <th scope="col">Order value</th>
                                    <th scope="col">Delivery fee</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td>Below &#8377;2,000</td>
                                    <td>&#8377;149</td>
                                </tr>
                                <tr>
                                    <td>&#8377;2,000 and above</td>
                                    <td>Complimentary</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <p class="policy-small">The exact fee is calculated on the server and shown in your bag and at checkout before you confirm your order.</p>
                </section>

                <section class="policy-block">
                    <span class="policy-number">03</span>
                    <h2>Choosing a delivery date</h2>
                    <p>You can choose any date from tomorrow up to 30 days from the day you order. We require at least one day's notice so our florists can source and arrange your stems.</p>
                    <p>If you need a same-day delivery for a special reason, contact us before ordering and we will tell you honestly whether it is possible.</p>
                </section>

                <section class="policy-block">
                    <span class="policy-number">04</span>
                    <h2>Delivery areas and timings</h2>
                    <p>We currently deliver across Chennai and to selected pincodes in Tamil Nadu. Deliveries are made between 9:00 AM and 7:00 PM. We cannot guarantee an exact delivery time, but we will call ahead on the day.</p>
                    <p>For addresses outside our current area, please contact us with the pincode before placing an order.</p>
                </section>

                <section class="policy-block">
                    <span class="policy-number">05</span>
                    <h2>If nobody is available</h2>
                    <p>Our courier will call the number on your order. If there is no answer, we will wait briefly and try once more. If we still cannot hand over the flowers, we will contact you to arrange a safe alternative or a redelivery where possible.</p>
                    <p>Fresh flowers cannot wait indefinitely. Redelivery may incur an additional delivery fee.</p>
                </section>

                <section class="policy-block">
                    <span class="policy-number">06</span>
                    <h2>Flowers are natural</h2>
                    <p>Because every stem is natural, slight variations in colour, shape and opening are normal. If your bouquet arrives damaged or materially different from what you ordered, contact us within 24 hours with a photograph and your order number so we can make it right.</p>
                </section>

            </div>

            <aside class="policy-aside">
                <div class="policy-card">
                    <span class="eyebrow">At a glance</span>
                    <h2>Delivery, simply.</h2>
                    <dl class="policy-summary">
                        <div><dt>Delivery fee</dt><dd>&#8377;149</dd></div>
                        <div><dt>Free above</dt><dd>&#8377;2,000</dd></div>
                        <div><dt>Notice</dt><dd>1 day</dd></div>
                        <div><dt>Booking window</dt><dd>30 days</dd></div>
                        <div><dt>Delivery hours</dt><dd>9 AM &ndash; 7 PM</dd></div>
                    </dl>
                    <a class="btn btn-primary btn-block" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop flowers</a>
                    <p class="summary-note">Questions about a specific address? <a href="<%= ResolveUrl("~/Pages/Contact.aspx") %>">Talk to us</a>.</p>
                </div>
            </aside>

        </div>
    </section>

</asp:Content>
