*** Settings ***
Documentation    Locators for the WNW home page (/). Port of pages/HomePage.ts +
...              components/HeaderComponent / CookieBanner home-page selectors.
...              All raw home-page selectors live HERE only (POM discipline).

*** Variables ***
# ── Header / hero ─────────────────────────────────────────────────────────────
${HOME_LOGO}                css:header a[href="/"] img, header img[alt]
${HOME_HEADER}              css:header
${HOME_CART_LINK}           css:header a[href="/cart/"]
# Presence (attached) check — both mobile + desktop cart links.
${HOME_CART_LINK_ANY}       css:a[href="/cart/"]
${HOME_BEST_SELLER_BANNER}    xpath=//*[contains(text(),'สินค้าขายดี คลิก')]
${HOME_LOGIN_LINK}          xpath=//*[contains(text(),'เข้าสู่ระบบ')]
${HOME_REGISTER_LINK}       xpath=//*[contains(text(),'สมัครสมาชิก')]
${HOME_LINE_LINK}           xpath=//*[contains(text(),'@LINE')]

# ── Cookie consent banner (dismiss WITHOUT accepting — TC-HOME-02) ─────────────
${HOME_COOKIE_BANNER}       css:[class*="cookie"], [id*="cookie"], [class*="consent"], [class*="gdpr"]
${HOME_COOKIE_CLOSE}        xpath=//*[contains(@class,'cookie') or contains(@id,'cookie') or contains(@class,'consent')]//button[contains(translate(., 'CLOSE', 'close'), 'close') or contains(., 'ปิด') or normalize-space(.)='x' or normalize-space(.)='X']

# ── Primary navigation ────────────────────────────────────────────────────────
${HOME_NAV}                 xpath=//nav
${HOME_NAV_TRIGGER_BTN}     xpath=(//nav//button)[1]
${HOME_NAV_FRESH_FLOWER}    xpath=(//nav//*[contains(text(),'พวงหรีดดอกไม้สด')])[1]
${HOME_NAV_TRACKING}        xpath=(//nav//*[contains(text(),'ติดตามสถานะ')])[1]
${HOME_NAV_TRACKING_BTN}    xpath=//nav//button[contains(.,'ติดตามสถานะ')]
${HOME_NAV_HOWTO_LINK}      xpath=//a[contains(.,'วิธีสั่งซื้อ')]
${HOME_BEST_SELLER_NAV}     xpath=(//a[contains(.,'สินค้าขายดี')])[1]
