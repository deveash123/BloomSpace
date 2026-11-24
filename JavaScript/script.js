/* =====================================================================
   BLOOM SPACE - script.js
   1) Mobile navigation toggle
   2) Custom bouquet builder (live price, summary and preview)

   IMPORTANT: prices calculated here are for DISPLAY ONLY.
   The C# code re-reads every price from SQL Server before saving anything.
   ===================================================================== */
(function () {
    'use strict';

    /* ---------------------------------------------------------------
       1. Mobile navigation
       --------------------------------------------------------------- */
    var toggle = document.querySelector('.nav-toggle');
    var nav = document.getElementById('siteNav');

    if (toggle && nav) {
        toggle.addEventListener('click', function () {
            var open = nav.classList.toggle('is-open');
            toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
        });

        // Close the menu after choosing a link, or when Escape is pressed.
        nav.addEventListener('click', function (e) {
            if (e.target.tagName === 'A') {
                nav.classList.remove('is-open');
                toggle.setAttribute('aria-expanded', 'false');
            }
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && nav.classList.contains('is-open')) {
                nav.classList.remove('is-open');
                toggle.setAttribute('aria-expanded', 'false');
                toggle.focus();
            }
        });
    }

    /* ---------------------------------------------------------------
       2. Password show/hide visibility toggle
       --------------------------------------------------------------- */
    document.addEventListener('click', function (e) {
        var btn = e.target.closest ? e.target.closest('.password-toggle') : null;
        if (!btn) { return; }

        var wrap = btn.closest('.password-field-wrap');
        if (!wrap) { return; }

        var input = wrap.querySelector('input');
        if (!input) { return; }

        var isPassword = input.type === 'password';
        input.type = isPassword ? 'text' : 'password';

        var eyeOpen = btn.querySelector('.eye-open');
        var eyeClosed = btn.querySelector('.eye-closed');
        if (eyeOpen && eyeClosed) {
            eyeOpen.style.display = isPassword ? 'none' : 'block';
            eyeClosed.style.display = isPassword ? 'block' : 'none';
        }
        btn.setAttribute('aria-label', isPassword ? 'Hide password' : 'Show password');
    });

    /* ---------------------------------------------------------------
       3. Custom bouquet builder
       --------------------------------------------------------------- */
    var builder = document.getElementById('bouquetBuilder');
    if (!builder) { return; }

    var MAX_PER_FLOWER = 50;       // same limit as the server
    var MAX_PREVIEW_HEADS = 15;    // how many flower heads the preview draws

    var deliveryFee = parseFloat(builder.getAttribute('data-delivery')) || 0;
    var money = new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', minimumFractionDigits: 2 });

    var flowerCards = builder.querySelectorAll('.flower-card');
    var wrapInputs = builder.querySelectorAll('input[name="wrapping"]');
    var ribbonInputs = builder.querySelectorAll('input[name="ribbon"]');

    var summaryList = document.getElementById('summaryList');
    var elFlowerCost = document.getElementById('totFlowers');
    var elWrap = document.getElementById('totWrapping');
    var elRibbon = document.getElementById('totRibbon');
    var elSubtotal = document.getElementById('totSubtotal');
    var elDelivery = document.getElementById('totDelivery');
    var elGrand = document.getElementById('totGrand');
    var elHint = document.getElementById('builderHint');
    var addButton = document.getElementById('btnAddBouquet');

    var previewFlowers = document.getElementById('previewFlowers');
    var previewEmpty = document.getElementById('previewEmpty');
    var previewGreenery = document.getElementById('previewGreenery');
    var paperShapes = builder.querySelectorAll('.bp-paper');
    var ribbonShapes = builder.querySelectorAll('.bp-ribbon');

    function num(value) {
        var n = parseFloat(value);
        return isNaN(n) ? 0 : n;
    }

    function getQty(card) {
        return parseInt(card.querySelector('.qty-input').value, 10) || 0;
    }

    function setQty(card, qty) {
        qty = Math.max(0, Math.min(MAX_PER_FLOWER, qty));
        card.querySelector('.qty-input').value = qty;
        card.querySelector('.qty-value').textContent = qty;
        card.classList.toggle('is-selected', qty > 0);
        card.querySelector('.qty-minus').disabled = qty <= 0;
        card.querySelector('.qty-plus').disabled = qty >= MAX_PER_FLOWER;
    }

    function selectedOption(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            if (inputs[i].checked) { return inputs[i].closest('.option-card'); }
        }
        return null;
    }

    function markSelectedOptions(inputs) {
        for (var i = 0; i < inputs.length; i++) {
            inputs[i].closest('.option-card').classList.toggle('is-selected', inputs[i].checked);
        }
    }

    function addSummaryRow(label, amount) {
        var li = document.createElement('li');
        var l = document.createElement('span');
        var a = document.createElement('span');
        l.className = 's-label';
        a.className = 's-amount';
        l.textContent = label;
        a.textContent = amount;
        li.appendChild(l);
        li.appendChild(a);
        summaryList.appendChild(li);
    }

    /* Draws the flowers in a lush, artistic bouquet arrangement */
    function drawPreview(heads) {
        previewFlowers.innerHTML = '';
        var hasFlowers = heads.length > 0;
        previewEmpty.style.display = hasFlowers ? 'none' : 'block';
        if (previewGreenery) {
            previewGreenery.style.display = hasFlowers ? 'block' : 'none';
        }
        if (!hasFlowers) { return; }

        var width = previewFlowers.clientWidth || 340;
        var height = previewFlowers.clientHeight || 380;
        var n = heads.length;
        var centerX = width / 2;
        var baseY = height - 150;     // neckline where flowers emerge from the wrap

        var size = n === 1 ? 98 : (n <= 3 ? 88 : (n <= 7 ? 80 : 72));

        if (n === 1) {
            // Single centerpiece bloom
            placeFlower(heads[0], centerX - size / 2, baseY - 85, 0, 10, size);
        } else if (n === 2) {
            // Two nested companion blooms
            placeFlower(heads[0], centerX - size * 0.9, baseY - 78, -8, 8, size);
            placeFlower(heads[1], centerX - size * 0.1, baseY - 78, 8, 9, size);
        } else if (n === 3) {
            // Classic florist triad: hero flower elevated in center, two flanking
            placeFlower(heads[0], centerX - size * 1.05, baseY - 62, -14, 7, size);
            placeFlower(heads[1], centerX - size / 2,     baseY - 95,   0, 10, size);
            placeFlower(heads[2], centerX + size * 0.05, baseY - 62,  14, 8, size);
        } else {
            // Tiered florist dome arrangement
            var backCount = Math.floor(n * 0.42);
            var frontCount = n - backCount;

            // Back tier (raised higher, nestled in center)
            for (var b = 0; b < backCount; b++) {
                var tb = backCount === 1 ? 0.5 : b / (backCount - 1);
                var angleB = (-36 + tb * 72) * Math.PI / 180;
                var radiusB = 85;
                var xB = centerX + Math.sin(angleB) * radiusB * 1.25 - size / 2;
                var yB = (baseY - 75) - Math.cos(angleB) * radiusB * 0.6 - size / 2;
                var rotB = -20 + tb * 40;
                placeFlower(heads[b], xB, yB, rotB, 6 + b, size);
            }

            // Front tier (lower, gracefully framing neckline)
            for (var f = 0; f < frontCount; f++) {
                var tf = frontCount === 1 ? 0.5 : f / (frontCount - 1);
                var angleF = (-52 + tf * 104) * Math.PI / 180;
                var radiusF = 58;
                var xF = centerX + Math.sin(angleF) * radiusF * 1.55 - size / 2;
                var yF = (baseY - 42) - Math.cos(angleF) * radiusF * 0.65 - size / 2;
                var rotF = -30 + tf * 60;
                placeFlower(heads[backCount + f], xF, yF, rotF, 12 + f, size);
            }
        }
    }

    function placeFlower(head, x, y, rotation, zIndex, size) {
        var img = document.createElement('img');
        img.className = 'bp-flower';
        img.src = head.img;
        img.alt = head.name || '';
        img.title = head.name || '';
        img.style.width = Math.round(size) + 'px';
        img.style.height = Math.round(size) + 'px';
        img.style.left = Math.round(x) + 'px';
        img.style.top = Math.round(Math.max(15, y)) + 'px';
        img.style.transform = 'rotate(' + Math.round(rotation) + 'deg)';
        img.style.zIndex = String(zIndex);
        previewFlowers.appendChild(img);
    }

    function update() {
        var flowerCost = 0;
        var stems = 0;
        var heads = [];
        var picked = [];

        summaryList.innerHTML = '';

        for (var i = 0; i < flowerCards.length; i++) {
            var card = flowerCards[i];
            var qty = getQty(card);
            if (qty > 0) {
                var price = num(card.getAttribute('data-price'));
                var name = card.getAttribute('data-name');
                var img = card.getAttribute('data-img');
                flowerCost += price * qty;
                stems += qty;
                picked.push({ name: name, qty: qty, price: price, img: img });
                addSummaryRow(qty + ' × ' + name, money.format(price * qty));
            }
        }

        var wrapCard = selectedOption(wrapInputs);
        var ribbonCard = selectedOption(ribbonInputs);
        var wrapPrice = wrapCard ? num(wrapCard.getAttribute('data-price')) : 0;
        var ribbonPrice = ribbonCard ? num(ribbonCard.getAttribute('data-price')) : 0;

        if (!picked.length) {
            var empty = document.createElement('li');
            empty.className = 'summary-empty';
            empty.textContent = 'No flowers chosen yet';
            summaryList.appendChild(empty);
        }
        if (wrapCard && picked.length) { addSummaryRow(wrapCard.getAttribute('data-name'), money.format(wrapPrice)); }
        if (ribbonCard && picked.length) { addSummaryRow(ribbonCard.getAttribute('data-name') + ' ribbon', money.format(ribbonPrice)); }

        /* Price formula (display only):
           Subtotal    = Flower Cost + Wrapping Price + Ribbon Price
           Grand Total = Subtotal + Delivery Fee */
        var subtotal = flowerCost + wrapPrice + ribbonPrice;
        var grand = subtotal + deliveryFee;

        elFlowerCost.textContent = money.format(flowerCost);
        elWrap.textContent = money.format(wrapPrice);
        elRibbon.textContent = money.format(ribbonPrice);
        elSubtotal.textContent = money.format(subtotal);
        elDelivery.textContent = money.format(deliveryFee);
        elGrand.textContent = money.format(grand);

        /* Preview: spread the heads across the chosen flowers in proportion to quantity. */
        if (stems > 0) {
            var count = Math.min(stems, MAX_PREVIEW_HEADS);
            var expanded = [];
            for (var p = 0; p < picked.length; p++) {
                for (var q = 0; q < picked[p].qty; q++) { expanded.push(picked[p]); }
            }
            for (var h = 0; h < count; h++) {
                heads.push(expanded[Math.floor(h * expanded.length / count)]);
            }
        }
        drawPreview(heads);

        if (wrapCard) {
            var wrapColor = wrapCard.getAttribute('data-color');
            for (var w = 0; w < paperShapes.length; w++) {
                paperShapes[w].setAttribute('fill', wrapColor);
            }
        }
        if (ribbonCard) {
            var ribColor = ribbonCard.getAttribute('data-color');
            for (var r = 0; r < ribbonShapes.length; r++) {
                ribbonShapes[r].setAttribute('fill', ribColor);
            }
        }

        markSelectedOptions(wrapInputs);
        markSelectedOptions(ribbonInputs);

        var ready = stems > 0 && !!wrapCard && !!ribbonCard;
        if (addButton) { addButton.disabled = !ready; }
        if (elHint) {
            elHint.textContent = ready
                ? stems + (stems === 1 ? ' stem' : ' stems') + ' selected. Ready to add to your cart.'
                : 'Choose at least one flower, a wrapping paper and a ribbon.';
        }
    }

    /* Quantity buttons (event delegation) */
    builder.addEventListener('click', function (e) {
        var btn = e.target.closest ? e.target.closest('.qty-btn') : null;
        if (!btn) { return; }
        var card = btn.closest('.flower-card');
        if (!card) { return; }
        setQty(card, getQty(card) + (btn.classList.contains('qty-plus') ? 1 : -1));
        update();
    });

    /* Wrapping / ribbon selection */
    builder.addEventListener('change', function (e) {
        if (e.target && (e.target.name === 'wrapping' || e.target.name === 'ribbon')) { update(); }
    });

    /* Start: apply any quantities the server sent back (for example after a validation message). */
    for (var c = 0; c < flowerCards.length; c++) { setQty(flowerCards[c], getQty(flowerCards[c])); }
    update();

    /* Redraw the fan if the screen is resized or rotated. */
    var resizeTimer = null;
    window.addEventListener('resize', function () {
        clearTimeout(resizeTimer);
        resizeTimer = setTimeout(update, 150);
    });
})();
