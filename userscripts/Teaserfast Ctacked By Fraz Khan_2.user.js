// ==UserScript==
// @name         Teaserfast Ctacked By Fraz Khan
// @namespace    http://tampermonkey.net/
// @version      1.3
// @description  (2)
// @author       Fraz Khan
// @match        https://teaserfast.ru/check-captcha*
// @grant        GM_setValue
// @grant        GM_getValue
// @license      MIT
// @downloadURL https://update.greasyfork.org/scripts/554552/teaserfast.user.js
// @updateURL https://update.greasyfork.org/scripts/554552/teaserfast.meta.js
// ==/UserScript==

(function() {
    'use strict';

    const COOLDOWN_MS = 10000;
    const WAIT_MS = 7000;
    const STORAGE_KEY = 'lastConfirmActionTime';

    function isInCooldown() {
        const lastTime = GM_getValue(STORAGE_KEY, 0);
        return Date.now() - lastTime < COOLDOWN_MS;
    }

    function setCooldown() {
        GM_getValue(STORAGE_KEY, Date.now());
    }

    if (isInCooldown()) {
        console.log('In cooldown period (10s from last confirm). Skipping all actions.');
        return;
    }

    function findTargetDiv() {
        const divs = document.querySelectorAll('div[style*="font-size: 20px"][style*="color: #1abc9c"]');
        for (let div of divs) {
            if (div.textContent.trim() === '🎯 TARGET FOUND! ✅') {
                return div;
            }
        }
        return null;
    }

    function clickConfirm() {
        const confirmLink = document.querySelector('a.add_button_link.bl_green[style*="width:200px"][onclick*="submit_form"]');
        if (confirmLink && confirmLink.textContent.trim() === 'Подтвердить') {
            confirmLink.click();
            console.log('Confirm button clicked!');
            setCooldown();
            return true;
        } else {
            console.log('Confirm button not found or mismatched.');
            return false;
        }
    }

    function checkForTarget() {
        const targetDiv = findTargetDiv();
        if (targetDiv) {
            console.log('Target found!');
            setTimeout(() => {
                clickConfirm();
            }, WAIT_MS);
            return true;
        }
        return false;
    }

    checkForTarget();

    const observer = new MutationObserver(() => {
        if (!isInCooldown()) {
            checkForTarget();
        }
    });

    observer.observe(document.body, {
        childList: true,
        subtree: true
    });

    window.addEventListener('beforeunload', () => {
        observer.disconnect();
    });

    // 🔥 Auto refresh after 15 minutes
    setTimeout(() => {
        console.log("15 minutes passed — refreshing page...");
        location.reload();
    }, 900000);

})();
