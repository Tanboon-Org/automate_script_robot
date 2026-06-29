*** Settings ***
Documentation    Locators for the 2C2P hosted card-entry page (port of pages/Card2C2PPage.ts).
...              Two URL variants on staging: same-domain /payment/2c2p/<hex>/ and
...              cross-domain t.2c2p.com. Expiry is a SINGLE combined "MM / YY" field.
...              Production caveat: prod domain/selectors may differ — re-verify.

*** Variables ***
${C2P_CARD_NUMBER}      css:input[name="cardNumber"], input[placeholder="0000-0000-0000-0000"]
${C2P_EXPIRY}           css:input[placeholder="MM / YY"]
${C2P_CVV}              css:input[placeholder=". . ."]
${C2P_CARDHOLDER}       xpath=//input[contains(@aria-label,'cardholder') or contains(@placeholder,'cardholder') or contains(@name,'holder')]
${C2P_EMAIL}            css:input[name="email"]
${C2P_CONTINUE}         xpath=//button[contains(translate(., 'CONTINUEPAYMENT', 'continuepayment'),'continue payment')]
${C2P_CANCEL}           xpath=//button[translate(normalize-space(.), 'CANCEL', 'cancel')='cancel']
${C2P_MODAL_CLOSE}      css:.modal-close-button
# Charge amount shown on the hosted page — class-based or currency-text fallback.
${C2P_CHARGE_AMOUNT}    xpath=(//*[(contains(@class,'amount') or contains(@class,'total') or contains(@class,'price')) and (contains(.,'.') or contains(.,','))] | //*[contains(text(),'THB') or contains(text(),'฿')])[1]
