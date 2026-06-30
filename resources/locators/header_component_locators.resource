*** Settings ***
Documentation    Reusable site-header locators (port of components/HeaderComponent.ts).
...              FIX 4: a[href="/cart/"] matches 2 elements (link + badge) — scope to
...              header and take the first to avoid strict-mode ambiguity.

*** Variables ***
${HEADER_LOGO}          xpath=(//header//img | //header//*[contains(@class,'logo')])[1]
${HEADER_CART_LINK}     css:header a[href="/cart/"]
${HEADER_CART_BADGE}    css:header a[href="/cart/"] [class*="badge"], header a[href="/cart/"] [class*="count"], header a[href="/cart/"] span
${HEADER_SEARCH}        css:header input[type="search"], header input[type="text"][class*="search"]
${HEADER_LINE_LINK}     xpath=(//*[contains(text(),'@LINE')])[1]
${HEADER_REGISTER}      xpath=(//*[contains(text(),'สมัครสมาชิก')])[1]
${HEADER_LOGIN}         xpath=(//*[contains(text(),'เข้าสู่ระบบ')])[1]
# Back-to-top: icon-only fixed button (Tailwind "fixed bottom-20 right-6"), no text/aria.
${BACK_TO_TOP_BTN}      css:button.fixed.bottom-20, button[class*="fixed"][class*="bottom-20"]
