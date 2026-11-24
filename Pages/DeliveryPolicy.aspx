<%@ Page Title="Delivery Policy" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="DeliveryPolicy.aspx.cs" Inherits="Pages_DeliveryPolicy" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Shipping &amp; delivery</span>
            <h1>Delivery Policy</h1>
            <p>Everything you need to know about how your flowers reach you.</p>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="prose">

                <h2 style="margin-top: 0;">Delivery process</h2>
                <ol class="steps">
                    <li>Place your order and choose your preferred delivery date at checkout.</li>
                    <li>We arrange your flowers fresh on the day of delivery.</li>
                    <li>Your bouquet is carefully packed and sent out with a delivery partner.</li>
                    <li>Your recipient receives their flowers. Payment is collected on delivery.</li>
                </ol>

                <h2>Delivery charges</h2>
                <table class="info-table">
                    <tr><th>Item</th><th>Charge</th></tr>
                    <tr><td>Delivery fee (per order)</td><td><asp:Literal ID="litFee" runat="server" /></td></tr>
                    <tr><td>Multiple bouquets in one order</td><td>One delivery fee for the whole order</td></tr>
                </table>

                <h2>Delivery dates</h2>
                <ul>
                    <li>You can choose any delivery date from tomorrow up to 60 days ahead.</li>
                    <li>Orders are delivered during the day on your chosen date.</li>
                    <li>For occasions such as birthdays and anniversaries, we recommend ordering at least two days early.</li>
                </ul>

                <h2>Delivery conditions</h2>
                <ul>
                    <li>Please give a complete address and a working phone number so our partner can reach you.</li>
                    <li>If no one is available to receive the flowers, we will try to contact you to arrange another time.</li>
                    <li>Flowers are natural products, so slight variations in shade and size can occur.</li>
                    <li>If your flowers arrive damaged, please contact us the same day through the <a href="<%= ResolveUrl("~/Pages/Contact.aspx") %>">Contact page</a>.</li>
                </ul>

            </div>
        </div>
    </section>

</asp:Content>
