<%@ Page Title="Custom Bouquet" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeFile="CustomBouquet.aspx.cs" Inherits="Pages_CustomBouquet" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="page-hero">
        <div class="container">
            <span class="eyebrow">Design your own</span>
            <h1>Custom Bouquet Builder</h1>
            <p>Choose your flowers, pick a wrapping and ribbon, and watch the price and preview update as you design.</p>
        </div>
    </section>

    <section class="section-tight">
        <div class="container">

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="alert alert-error" role="alert">
                <asp:Literal ID="litMessage" runat="server" />
            </asp:Panel>

            <asp:Panel ID="pnlUnavailable" runat="server" Visible="false" CssClass="empty-state">
                <h2>The studio is being restocked</h2>
                <p>The bouquet builder is not available right now. You can still browse our flowers in the shop.</p>
                <div class="empty-actions"><a class="btn" href="<%= ResolveUrl("~/Pages/Shop.aspx") %>">Shop Flowers</a></div>
            </asp:Panel>

            <asp:Panel ID="pnlBuilder" runat="server">
                <div id="bouquetBuilder" class="builder" data-delivery="<%= DeliveryFeeAttr %>">

                    <!-- ============ Left: the three design steps ============ -->
                    <div class="builder-main">

                        <div class="builder-step">
                            <div class="step-title"><span class="step-num">1</span><h2>Choose your flowers</h2></div>
                            <p class="step-hint">Mix as many types as you like. Prices are per stem.</p>
                            <asp:Literal ID="litFlowers" runat="server" />
                        </div>

                        <div class="builder-step">
                            <div class="step-title"><span class="step-num">2</span><h2>Pick your wrapping</h2></div>
                            <p class="step-hint">The paper your bouquet will be wrapped in.</p>
                            <div class="option-grid">
                                <asp:Literal ID="litWrapping" runat="server" />
                            </div>
                        </div>

                        <div class="builder-step">
                            <div class="step-title"><span class="step-num">3</span><h2>Finish with a ribbon</h2></div>
                            <p class="step-hint">The final touch that ties it all together.</p>
                            <div class="option-grid">
                                <asp:Literal ID="litRibbons" runat="server" />
                            </div>
                        </div>
                    </div>

                    <!-- ============ Right: preview, summary, total ============ -->
                    <aside class="builder-side" aria-label="Your bouquet">
                        <div class="side-card">
                            <h2>Your Bouquet</h2>
                            <p class="side-sub">A live preview of your design</p>

                            <div class="bouquet-preview" aria-hidden="true">
                                <div id="previewGreenery" class="bp-greenery" style="display:none;">
                                    <svg viewBox="0 0 340 260" xmlns="http://www.w3.org/2000/svg" width="100%" height="100%">
                                        <g fill="#7E9675" opacity="0.82">
                                            <path d="M170 210 C130 190 75 145 55 95 C65 100 80 96 84 86 C86 74 76 66 66 68 C56 72 46 84 46 98 C46 130 95 178 170 210 Z" />
                                            <ellipse cx="74" cy="92" rx="16" ry="22" transform="rotate(-35 74 92)" />
                                            <ellipse cx="96" cy="122" rx="18" ry="24" transform="rotate(-25 96 122)" />
                                            <ellipse cx="122" cy="155" rx="19" ry="25" transform="rotate(-15 122 155)" />
                                            <path d="M170 210 C210 190 265 145 285 95 C275 100 260 96 256 86 C254 74 264 66 274 68 C284 72 294 84 294 98 C294 130 245 178 170 210 Z" />
                                            <ellipse cx="266" cy="92" rx="16" ry="22" transform="rotate(35 266 92)" />
                                            <ellipse cx="244" cy="122" rx="18" ry="24" transform="rotate(25 244 122)" />
                                            <ellipse cx="218" cy="155" rx="19" ry="25" transform="rotate(15 218 155)" />
                                            <ellipse cx="148" cy="75" rx="12" ry="18" transform="rotate(-10 148 75)" opacity="0.6"/>
                                            <ellipse cx="192" cy="75" rx="12" ry="18" transform="rotate(10 192 75)" opacity="0.6"/>
                                        </g>
                                    </svg>
                                </div>
                                <div id="previewFlowers" class="bp-flowers"></div>
                                <p id="previewEmpty" class="bp-empty">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="display:block;margin:0 auto 8px;opacity:0.6;"><circle cx="12" cy="12" r="10"/><path d="M12 8v8"/><path d="M8 12h8"/></svg>
                                    Select flowers to start designing your custom bouquet.
                                </p>
                                <svg class="bp-wrap" viewBox="0 0 280 190" xmlns="http://www.w3.org/2000/svg">
                                    <defs>
                                        <filter id="bpDrop" x="-15%" y="-15%" width="130%" height="130%">
                                            <feDropShadow dx="0" dy="8" stdDeviation="10" flood-color="#4A3B39" flood-opacity="0.22"/>
                                        </filter>
                                        <linearGradient id="bpPaperShadow" x1="0" y1="0" x2="1" y2="0">
                                            <stop offset="0%" stop-color="#000" stop-opacity="0.16"/>
                                            <stop offset="35%" stop-color="#000" stop-opacity="0.0"/>
                                            <stop offset="65%" stop-color="#fff" stop-opacity="0.14"/>
                                            <stop offset="100%" stop-color="#000" stop-opacity="0.14"/>
                                        </linearGradient>
                                        <linearGradient id="bpRibbonShine" x1="0" y1="0" x2="0" y2="1">
                                            <stop offset="0%" stop-color="#fff" stop-opacity="0.3"/>
                                            <stop offset="50%" stop-color="#000" stop-opacity="0.0"/>
                                            <stop offset="100%" stop-color="#000" stop-opacity="0.22"/>
                                        </linearGradient>
                                    </defs>
                                    <g filter="url(#bpDrop)">
                                        <path class="bp-paper bp-back" fill="#F2C6D0" d="M30 35 L125 180 L140 180 L70 20 Z" opacity="0.88"/>
                                        <path class="bp-paper bp-back" fill="#F2C6D0" d="M250 35 L155 180 L140 180 L210 20 Z" opacity="0.88"/>
                                        <path id="bpPaper" class="bp-paper" fill="#F2C6D0" d="M20 40 Q140 65 260 40 L165 182 Q140 188 115 182 Z" />
                                        <path fill="url(#bpPaperShadow)" d="M20 40 Q140 65 260 40 L165 182 Q140 188 115 182 Z" />
                                        <path class="bp-paper bp-flap" fill="#F2C6D0" d="M20 40 C70 75 110 110 150 145 L135 184 L115 182 Z" />
                                        <path fill="none" stroke="rgba(0,0,0,0.12)" stroke-width="1.5" d="M20 40 C70 75 110 110 150 145" />
                                        <path class="bp-paper bp-flap" fill="#F2C6D0" d="M260 40 C200 80 155 115 125 150 L140 184 L165 182 Z" />
                                        <path fill="none" stroke="rgba(0,0,0,0.15)" stroke-width="1.5" d="M260 40 C200 80 155 115 125 150" />
                                        <path class="bp-ribbon" fill="#E39AAE" d="M102 112 Q140 118 178 112 L174 128 Q140 134 106 128 Z" />
                                        <path fill="url(#bpRibbonShine)" d="M102 112 Q140 118 178 112 L174 128 Q140 134 106 128 Z" />
                                        <path class="bp-ribbon" fill="#E39AAE" d="M136 126 C130 148 116 166 108 184 L120 180 L132 190 L140 128 Z" />
                                        <path class="bp-ribbon" fill="#E39AAE" d="M144 126 C150 148 164 166 172 184 L160 180 L148 190 L140 128 Z" />
                                        <path class="bp-ribbon" fill="#E39AAE" d="M140 120 C108 90 85 106 98 126 C110 140 134 128 140 120 Z" />
                                        <path fill="url(#bpRibbonShine)" d="M140 120 C108 90 85 106 98 126 C110 140 134 128 140 120 Z" />
                                        <path class="bp-ribbon" fill="#E39AAE" d="M140 120 C172 90 195 106 182 126 C170 140 146 128 140 120 Z" />
                                        <path fill="url(#bpRibbonShine)" d="M140 120 C172 90 195 106 182 126 C170 140 146 128 140 120 Z" />
                                        <ellipse class="bp-ribbon" cx="140" cy="120" rx="9" ry="11" fill="#E39AAE" />
                                        <ellipse cx="140" cy="120" rx="9" ry="11" fill="url(#bpRibbonShine)" />
                                    </g>
                                </svg>
                            </div>

                            <h4>Summary</h4>
                            <ul id="summaryList" class="summary-list"><li class="summary-empty">No flowers chosen yet</li></ul>

                            <div class="totals">
                                <div class="row"><span>Flower cost</span><span id="totFlowers">&#8377;0.00</span></div>
                                <div class="row"><span>Wrapping</span><span id="totWrapping">&#8377;0.00</span></div>
                                <div class="row"><span>Ribbon</span><span id="totRibbon">&#8377;0.00</span></div>
                                <div class="row"><span>Subtotal</span><span id="totSubtotal">&#8377;0.00</span></div>
                                <div class="row"><span>Delivery fee</span><span id="totDelivery">&#8377;0.00</span></div>
                                <div class="row grand"><span>Estimated total</span><span id="totGrand">&#8377;0.00</span></div>
                            </div>

                            <asp:Button ID="btnAddBouquet" runat="server" ClientIDMode="Static" Text="Add Bouquet to Cart"
                                CssClass="btn btn-block" OnClick="btnAddBouquet_Click" />
                            <p id="builderHint" class="estimate-note" role="status">Choose at least one flower, a wrapping paper and a ribbon.</p>
                            <p class="estimate-note">Estimate only. Your final price is confirmed from our catalogue when you add to cart.</p>
                        </div>
                    </aside>

                </div>
            </asp:Panel>

        </div>
    </section>

</asp:Content>
