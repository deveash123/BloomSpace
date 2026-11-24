<%@ Page Title="Custom Bouquet Builder | Bloom Space" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="CustomBouquet.aspx.cs" Inherits="BloomSpace.Pages.CustomBouquetPage" %>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero page-hero-builder">
        <div class="container page-hero-inner">
            <div>
                <span class="eyebrow">The bouquet studio</span>
                <h1>Build something <em>entirely yours.</em></h1>
                <p>
                    Choose your stems, wrapping and ribbon. Your live estimate updates as you
                    design, and our florists hand-tie every stem to order.
                </p>
            </div>
            <div class="builder-steps" aria-label="Bouquet builder steps">
                <span><b>01</b> Flowers</span>
                <span><b>02</b> Wrapping</span>
                <span><b>03</b> Ribbon</span>
            </div>
        </div>
    </section>

    <section class="section builder-section">
        <div class="container">

            <asp:Panel ID="pnlPageError" runat="server" Visible="false" CssClass="alert alert-error">
                <asp:Literal ID="litPageError" runat="server" />
            </asp:Panel>

            <asp:Panel ID="pnlGuestNote" runat="server" Visible="false" CssClass="builder-guest-note">
                <span>You can design freely. <a href="<%= ResolveUrl("~/Account/Login.aspx") %>?returnUrl=%2FPages%2FCustomBouquet.aspx">Sign in</a> when you are ready to add your bouquet to the bag.</span>
            </asp:Panel>

            <div class="builder-layout">

                <div class="builder-main">

                    <!-- STEP 01 : FLOWERS -->
                    <div class="builder-block" id="stepFlowers">
                        <div class="builder-heading">
                            <span class="step-number">01</span>
                            <div>
                                <h2>Choose your flowers</h2>
                                <p>Select as many varieties as you like, then set the number of stems for each.</p>
                            </div>
                        </div>

                        <div class="flower-options">
                            <asp:Repeater ID="rptFlowers" runat="server">
                                <ItemTemplate>
                                    <article class="flower-option"
                                             data-flower-id='<%# Eval("FlowerId") %>'
                                             data-price='<%# Eval("PriceRaw") %>'
                                             data-name='<%#: Eval("Name") %>'>
                                        <label class="flower-check" title='<%#: "Include " + Eval("Name") %>'>
                                            <input type="checkbox"
                                                   class="flower-toggle"
                                                   name='chk_<%# Eval("FlowerId") %>'
                                                   value="1"
                                                   aria-label='<%#: "Include " + Eval("Name") %>' />
                                            <span class="check-ui" aria-hidden="true"></span>
                                        </label>

                                        <div class="flower-thumb">
                                            <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Name") %>' loading="lazy" />
                                        </div>

                                        <div class="flower-meta">
                                            <span class="flower-category"><%#: Eval("Category") %></span>
                                            <h3><%#: Eval("Name") %></h3>
                                            <span class="flower-price"><%#: Eval("PriceText") %> <small>/ stem</small></span>
                                        </div>

                                        <div class="qty-stepper" data-qty-for='<%# Eval("FlowerId") %>'>
                                            <button type="button" class="qty-btn" data-step="-1" aria-label='<%#: "Decrease " + Eval("Name") + " quantity" %>'>&minus;</button>
                                            <input type="number"
                                                   class="qty-input"
                                                   name='qty_<%# Eval("FlowerId") %>'
                                                   value="0"
                                                   min="0"
                                                   max="50"
                                                   inputmode="numeric"
                                                   aria-label='<%#: Eval("Name") + " quantity" %>' />
                                            <button type="button" class="qty-btn" data-step="1" aria-label='<%#: "Increase " + Eval("Name") + " quantity" %>'>+</button>
                                        </div>
                                    </article>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <!-- STEP 02 : WRAPPING -->
                    <div class="builder-block" id="stepWrapping">
                        <div class="builder-heading">
                            <span class="step-number">02</span>
                            <div>
                                <h2>Choose your wrapping</h2>
                                <p>Every bouquet is wrapped by hand. Pick the paper that suits your moment.</p>
                            </div>
                        </div>

                        <div class="option-grid">
                            <asp:Repeater ID="rptWrapping" runat="server">
                                <ItemTemplate>
                                    <label class="option-card">
                                        <input type="radio"
                                               name="wrappingId"
                                               value='<%# Eval("WrappingId") %>'
                                               data-price='<%# Eval("PriceRaw") %>'
                                               data-name='<%#: Eval("Name") %>'
                                               data-color='<%# Eval("PreviewColor") %>'
                                               <%# Container.ItemIndex == 0 ? "checked=\"checked\"" : "" %> />
                                        <span class="option-media">
                                            <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Name") %>' loading="lazy" />
                                        </span>
                                        <span class="option-body">
                                            <span class="option-title"><%#: Eval("Name") %></span>
                                            <span class="option-desc"><%#: Eval("Description") %></span>
                                            <span class="option-price"><%#: Eval("PriceText") %></span>
                                        </span>
                                        <span class="option-tick" aria-hidden="true"></span>
                                    </label>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <!-- STEP 03 : RIBBON -->
                    <div class="builder-block" id="stepRibbon">
                        <div class="builder-heading">
                            <span class="step-number">03</span>
                            <div>
                                <h2>Finish with a ribbon</h2>
                                <p>The final detail. Choose the colour that ties the whole bouquet together.</p>
                            </div>
                        </div>

                        <div class="option-grid option-grid-ribbon">
                            <asp:Repeater ID="rptRibbon" runat="server">
                                <ItemTemplate>
                                    <label class="option-card option-card-ribbon">
                                        <input type="radio"
                                               name="ribbonId"
                                               value='<%# Eval("RibbonId") %>'
                                               data-price='<%# Eval("PriceRaw") %>'
                                               data-name='<%#: Eval("Name") %>'
                                               data-color='<%# Eval("ColorHex") %>'
                                               <%# Container.ItemIndex == 0 ? "checked=\"checked\"" : "" %> />
                                        <span class="option-media">
                                            <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt='<%#: Eval("Name") %>' loading="lazy" />
                                        </span>
                                        <span class="option-body">
                                            <span class="option-title"><%#: Eval("Name") %></span>
                                            <span class="option-desc"><%#: Eval("Description") %></span>
                                            <span class="option-price"><%#: Eval("PriceText") %></span>
                                        </span>
                                        <span class="option-tick" aria-hidden="true"></span>
                                    </label>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                </div>

                <!-- LIVE PREVIEW + SUMMARY -->
                <aside class="builder-aside">
                    <div class="builder-sticky">

                        <div class="preview-card">
                            <div class="preview-stage" id="bouquetPreview">
                                <span class="preview-label">Live preview</span>
                                <div class="preview-glow" aria-hidden="true"></div>
                                <div class="preview-wrap" id="previewWrap" aria-hidden="true"></div>

                                <div class="preview-blooms">
                                    <asp:Repeater ID="rptPreview" runat="server">
                                        <ItemTemplate>
                                            <div class="preview-bloom" data-preview-id='<%# Eval("FlowerId") %>'>
                                                <img src='<%# ResolveUrl((string)Eval("ImagePath")) %>' alt="" />
                                                <span class="preview-qty"></span>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>

                                <div class="preview-bow" id="previewBow" aria-hidden="true">
                                    <span class="bow-loop bow-loop-left"></span>
                                    <span class="bow-loop bow-loop-right"></span>
                                    <span class="bow-knot"></span>
                                    <span class="bow-tail bow-tail-left"></span>
                                    <span class="bow-tail bow-tail-right"></span>
                                </div>

                                <p class="preview-empty" id="previewEmpty">Your bouquet starts with a single stem.</p>
                            </div>
                            <div class="preview-caption">
                                <span id="previewCaption">Nothing selected yet</span>
                                <span>Made by you</span>
                            </div>
                        </div>

                        <div class="summary-card">
                            <div class="summary-head">
                                <div>
                                    <span class="eyebrow">Your bouquet</span>
                                    <h2>Live estimate</h2>
                                </div>
                                <span class="summary-stems" id="summaryStems">0 stems</span>
                            </div>

                            <ul class="summary-lines" id="summaryFlowers">
                                <li class="summary-empty" id="summaryEmpty">No flowers selected yet.</li>
                            </ul>

                            <dl class="summary-totals">
                                <div><dt>Flowers</dt><dd id="sumFlowers">&#8377;0</dd></div>
                                <div><dt>Wrapping</dt><dd id="sumWrapping">&mdash;</dd></div>
                                <div><dt>Ribbon</dt><dd id="sumRibbon">&mdash;</dd></div>
                                <div><dt>Delivery</dt><dd id="sumDelivery">&#8377;149</dd></div>
                                <div class="summary-grand"><dt>Estimated total</dt><dd id="sumGrand">&#8377;149</dd></div>
                            </dl>

                            <p class="summary-note" id="deliveryNote">Add &#8377;2,000 of flowers for complimentary delivery.</p>

                            <asp:Panel ID="pnlBuilderError" runat="server" Visible="false" CssClass="form-error">
                                <asp:Literal ID="litBuilderError" runat="server" />
                            </asp:Panel>

                            <asp:Button ID="btnAddBouquet" runat="server"
                                        CssClass="btn btn-primary btn-block"
                                        Text="Add bouquet to bag"
                                        OnClick="btnAddBouquet_Click" />

                            <p class="summary-fineprint">
                                Your final price is recalculated securely on our server before checkout.
                            </p>
                        </div>

                    </div>
                </aside>

            </div>
        </div>
    </section>

</asp:Content>
