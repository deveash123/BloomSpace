/* ============================================================
   BLOOM SPACE — Front-end interactions
   Vanilla JavaScript only. No frameworks, no dependencies.
   ============================================================ */

(function () {
    "use strict";

    /* --------------------------------------------------------
       0. Helpers
       -------------------------------------------------------- */

    var toastTimer = null;

    function showToast(message) {
        var toast = document.getElementById("toast");

        if (!toast || !message) {
            return;
        }

        toast.textContent = message;
        toast.classList.add("show");

        window.clearTimeout(toastTimer);
        toastTimer = window.setTimeout(function () {
            toast.classList.remove("show");
        }, 3600);
    }

    window.bloomToast = showToast;

    function toInt(value, fallback) {
        var parsed = parseInt(value, 10);
        return isNaN(parsed) ? fallback : parsed;
    }

    function toNumber(value) {
        var parsed = parseFloat(value);
        return isNaN(parsed) ? 0 : parsed;
    }

    function formatInr(value) {
        var rounded = Math.round(value);

        try {
            return "\u20B9" + new Intl.NumberFormat("en-IN", {
                maximumFractionDigits: 0
            }).format(rounded);
        } catch (error) {
            return "\u20B9" + rounded;
        }
    }

    function localIsoDate(date) {
        var month = date.getMonth() + 1;
        var day = date.getDate();

        return date.getFullYear() + "-" +
            (month < 10 ? "0" : "") + month + "-" +
            (day < 10 ? "0" : "") + day;
    }

    /* --------------------------------------------------------
       1. Header shadow on scroll
       -------------------------------------------------------- */

    var header = document.getElementById("siteHeader");

    function updateHeader() {
        if (!header) {
            return;
        }

        header.classList.toggle("is-scrolled", window.scrollY > 8);
    }

    window.addEventListener("scroll", updateHeader, { passive: true });
    updateHeader();

    /* --------------------------------------------------------
       2. Mobile navigation
       -------------------------------------------------------- */

    var menuToggle = document.getElementById("menuToggle");
    var navLinks = document.getElementById("navLinks");

    function closeNavigation() {
        if (!menuToggle || !navLinks) {
            return;
        }

        menuToggle.classList.remove("is-open");
        menuToggle.setAttribute("aria-expanded", "false");
        menuToggle.setAttribute("aria-label", "Open menu");
        navLinks.classList.remove("open");
        document.body.classList.remove("nav-open");
    }

    function openNavigation() {
        if (!menuToggle || !navLinks) {
            return;
        }

        menuToggle.classList.add("is-open");
        menuToggle.setAttribute("aria-expanded", "true");
        menuToggle.setAttribute("aria-label", "Close menu");
        navLinks.classList.add("open");
        document.body.classList.add("nav-open");
    }

    if (menuToggle && navLinks) {
        menuToggle.addEventListener("click", function () {
            if (navLinks.classList.contains("open")) {
                closeNavigation();
            } else {
                openNavigation();
            }
        });

        navLinks.addEventListener("click", function (event) {
            var link = event.target.closest("a");

            if (link && !link.classList.contains("mobile-account-link")) {
                closeNavigation();
            }
        });

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                closeNavigation();
            }
        });

        window.addEventListener("resize", function () {
            if (window.innerWidth > 1080) {
                closeNavigation();
            }
        });
    }

    /* --------------------------------------------------------
       3. Shop search filter
       -------------------------------------------------------- */

    var shopSearch = document.getElementById("shopSearch");
    var shopGrid = document.getElementById("shopGrid");
    var shopCount = document.getElementById("shopCount");

    if (shopSearch && shopGrid) {
        var productCards = Array.prototype.slice.call(
            shopGrid.querySelectorAll(".product-card")
        );

        var noResults = document.createElement("p");
        noResults.className = "shop-no-results";
        noResults.textContent = "No bouquets match that search. Try another flower or name.";
        noResults.hidden = true;
        shopGrid.parentNode.insertBefore(noResults, shopGrid.nextSibling);

        var applyShopFilter = function () {
            var query = (shopSearch.value || "").trim().toLowerCase();
            var visible = 0;

            productCards.forEach(function (card) {
                var haystack = (
                    (card.getAttribute("data-name") || "") + " " +
                    (card.getAttribute("data-category") || "")
                ).toLowerCase();

                var matches = query === "" || haystack.indexOf(query) !== -1;
                card.hidden = !matches;

                if (matches) {
                    visible += 1;
                }
            });

            if (shopCount) {
                shopCount.textContent = visible + (visible === 1 ? " bouquet" : " bouquets");
            }

            noResults.hidden = visible !== 0;
        };

        var searchTimer = null;

        shopSearch.addEventListener("input", function () {
            window.clearTimeout(searchTimer);
            searchTimer = window.setTimeout(applyShopFilter, 80);
        });

        shopSearch.addEventListener("search", applyShopFilter);
    }

    /* --------------------------------------------------------
       4. Quantity steppers (builder + cart)
       -------------------------------------------------------- */

    document.addEventListener("click", function (event) {
        var button = event.target.closest(".qty-btn");

        if (!button) {
            return;
        }

        var stepper = button.closest(".qty-stepper");
        var input = stepper ? stepper.querySelector(".qty-input") : null;

        if (!input) {
            return;
        }

        event.preventDefault();

        var min = toInt(input.getAttribute("min"), 0);
        var max = toInt(input.getAttribute("max"), 99);
        var step = toInt(button.getAttribute("data-step"), 0);
        var current = toInt(input.value, min);

        input.value = Math.min(max, Math.max(min, current + step));
        input.dispatchEvent(new Event("input", { bubbles: true }));
    });

    /* --------------------------------------------------------
       5. Custom bouquet builder
       -------------------------------------------------------- */

    var builder = document.querySelector(".builder-layout");

    if (builder) {
        var stage = document.getElementById("bouquetPreview");
        var previewWrap = document.getElementById("previewWrap");
        var previewBow = document.getElementById("previewBow");
        var previewEmpty = document.getElementById("previewEmpty");
        var previewCaption = document.getElementById("previewCaption");

        var summaryFlowers = document.getElementById("summaryFlowers");
        var summaryStems = document.getElementById("summaryStems");
        var sumFlowers = document.getElementById("sumFlowers");
        var sumWrapping = document.getElementById("sumWrapping");
        var sumRibbon = document.getElementById("sumRibbon");
        var sumDelivery = document.getElementById("sumDelivery");
        var sumGrand = document.getElementById("sumGrand");
        var deliveryNote = document.getElementById("deliveryNote");

        var flowerOptions = Array.prototype.slice.call(
            document.querySelectorAll(".flower-option")
        );

        var freeDeliveryThreshold = 2000;
        var deliveryFee = 149;
        var maxStems = 100;

        function selectedWrapping() {
            return document.querySelector('input[name="wrappingId"]:checked');
        }

        function selectedRibbon() {
            return document.querySelector('input[name="ribbonId"]:checked');
        }

        function updateFlowerState(option, input, checkbox) {
            if (!input) {
                return;
            }

            var quantity = toInt(input.value, 0);

            if (quantity < 0) {
                quantity = 0;
            }

            option.classList.toggle("is-selected", quantity > 0);

            if (checkbox) {
                checkbox.checked = quantity > 0;
            }
        }

        function clampBouquet(input) {
            var quantity = Math.max(0, Math.min(50, toInt(input.value, 0)));
            var otherStems = 0;

            flowerOptions.forEach(function (option) {
                var otherInput = option.querySelector(".qty-input");

                if (otherInput && otherInput !== input) {
                    otherStems += Math.max(0, toInt(otherInput.value, 0));
                }
            });

            if (otherStems + quantity > maxStems) {
                quantity = Math.max(0, maxStems - otherStems);
                showToast("A bouquet can hold up to " + maxStems + " stems.");
            }

            input.value = quantity;
            return quantity;
        }

        function recalculate() {
            var flowersTotal = 0;
            var stems = 0;
            var names = [];
            var lines = document.createDocumentFragment();

            flowerOptions.forEach(function (option) {
                var input = option.querySelector(".qty-input");
                var checkbox = option.querySelector(".flower-toggle");
                var quantity = Math.max(0, toInt(input ? input.value : 0, 0));
                var price = toNumber(option.getAttribute("data-price"));
                var flowerId = option.getAttribute("data-flower-id");
                var name = option.getAttribute("data-name") || "Flowers";
                var bloom = stage
                    ? stage.querySelector('.preview-bloom[data-preview-id="' + flowerId + '"]')
                    : null;

                updateFlowerState(option, input, checkbox);

                if (quantity > 0) {
                    var lineTotal = price * quantity;
                    flowersTotal += lineTotal;
                    stems += quantity;
                    names.push(quantity + " \u00D7 " + name);

                    var row = document.createElement("li");
                    var label = document.createElement("span");
                    var amount = document.createElement("strong");

                    label.textContent = name + " \u00D7 " + quantity;
                    amount.textContent = formatInr(lineTotal);
                    row.appendChild(label);
                    row.appendChild(amount);
                    lines.appendChild(row);

                    if (bloom) {
                        bloom.classList.add("is-active");

                        var badge = bloom.querySelector(".preview-qty");

                        if (badge) {
                            badge.textContent = quantity;
                        }
                    }
                } else if (bloom) {
                    bloom.classList.remove("is-active");
                }
            });

            if (summaryFlowers) {
                summaryFlowers.innerHTML = "";

                if (stems === 0) {
                    var empty = document.createElement("li");
                    empty.className = "summary-empty";
                    empty.id = "summaryEmpty";
                    empty.textContent = "No flowers selected yet.";
                    summaryFlowers.appendChild(empty);
                } else {
                    summaryFlowers.appendChild(lines);
                }
            }

            var wrapping = selectedWrapping();
            var ribbon = selectedRibbon();
            var wrappingPrice = wrapping ? toNumber(wrapping.getAttribute("data-price")) : 0;
            var ribbonPrice = ribbon ? toNumber(ribbon.getAttribute("data-price")) : 0;
            var subtotal = flowersTotal + wrappingPrice + ribbonPrice;
            var delivery = subtotal >= freeDeliveryThreshold ? 0 : deliveryFee;

            if (previewWrap) {
                var wrapColor = wrapping ? wrapping.getAttribute("data-color") : "";

                if (wrapColor) {
                    previewWrap.style.setProperty("--wrap-color", wrapColor);
                }
            }

            if (previewBow && ribbon) {
                var bowColor = ribbon.getAttribute("data-color");

                if (bowColor) {
                    previewBow.style.setProperty("--bow-color", bowColor);
                }
            }

            if (stage) {
                stage.classList.toggle("is-empty", stems === 0);
                stage.classList.toggle("has-flowers", stems > 0);
            }

            if (previewEmpty) {
                previewEmpty.textContent = stems === 0
                    ? "Your bouquet starts with a single stem."
                    : "Hand-tied on the morning of delivery.";
            }

            if (previewCaption) {
                previewCaption.textContent = names.length > 0
                    ? names.join(" \u00B7 ")
                    : "Nothing selected yet";
            }

            if (summaryStems) {
                summaryStems.textContent = stems + (stems === 1 ? " stem" : " stems");
            }

            if (sumFlowers) {
                sumFlowers.textContent = formatInr(flowersTotal);
            }

            if (sumWrapping) {
                sumWrapping.textContent = wrapping
                    ? (wrappingPrice > 0 ? formatInr(wrappingPrice) : "Included")
                    : "\u2014";
            }

            if (sumRibbon) {
                sumRibbon.textContent = ribbon
                    ? (ribbonPrice > 0 ? formatInr(ribbonPrice) : "Included")
                    : "\u2014";
            }

            if (sumDelivery) {
                sumDelivery.textContent = stems === 0 ? "\u2014" : (delivery === 0 ? "Complimentary" : formatInr(delivery));
            }

            if (sumGrand) {
                sumGrand.textContent = stems === 0 ? formatInr(0) : formatInr(subtotal + delivery);
            }

            if (deliveryNote) {
                if (stems === 0) {
                    deliveryNote.textContent = "Select flowers to see your estimated total.";
                } else if (subtotal >= freeDeliveryThreshold) {
                    deliveryNote.textContent = "Complimentary delivery unlocked \u2014 beautifully done.";
                } else {
                    var remaining = freeDeliveryThreshold - subtotal;
                    deliveryNote.textContent = "Add " + formatInr(remaining) +
                        " more for complimentary delivery.";
                }
            }
        }

        flowerOptions.forEach(function (option) {
            var checkbox = option.querySelector(".flower-toggle");
            var input = option.querySelector(".qty-input");

            if (!input) {
                return;
            }

            if (checkbox) {
                checkbox.addEventListener("change", function () {
                    if (checkbox.checked) {
                        if (toInt(input.value, 0) <= 0) {
                            input.value = 1;
                        }
                    } else {
                        input.value = 0;
                    }

                    recalculate();
                });
            }

            input.addEventListener("input", function () {
                clampBouquet(input);
                recalculate();
            });

            input.addEventListener("change", function () {
                clampBouquet(input);
                recalculate();
            });
        });

        Array.prototype.slice
            .call(document.querySelectorAll('input[name="wrappingId"], input[name="ribbonId"]'))
            .forEach(function (radio) {
                radio.addEventListener("change", recalculate);
            });

        recalculate();
    }

    /* --------------------------------------------------------
       6. Delivery date limits (tomorrow through 30 days)
       -------------------------------------------------------- */

    var dateInput = document.querySelector('input[type="date"]');

    if (dateInput) {
        var today = new Date();
        var earliest = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 1);
        var latest = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 30);

        dateInput.setAttribute("min", localIsoDate(earliest));
        dateInput.setAttribute("max", localIsoDate(latest));
    }

})();
