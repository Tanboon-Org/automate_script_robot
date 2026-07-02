*** Settings ***
Documentation    Locators for product detail pages / PDP (port of pages/ProductPage.ts).
...              Route pattern: /พวงหรีด/<slug>/

*** Variables ***
${PDP_HEADING}             xpath=(//h1)[1]
# FIX 2: real DOM uses div.font-prompt-bold for the main price; scope to the ฿ price.
${PDP_PRICE}               xpath=(//div[contains(@class,'font-prompt-bold')][contains(.,'฿')])[1]
${PDP_FREE_SHIPPING}       xpath=//*[contains(text(),'ส่งฟรี')]
# FIX 1: main add-to-cart CTA is :not(.w-full); recommended-product CTAs are w-full.
${PDP_ADD_TO_CART}         xpath=(//button[not(contains(@class,'w-full'))][contains(.,'เพิ่มลงตะกร้า')])[1]
${PDP_BUY_NOW}             xpath=(//button[contains(.,'ซื้อทันที')])[1]
# Non-orderable products (allow_add_to_cart=false): the buy CTA is replaced by a LINE
# contact link in the product action area (ProductButton.tsx:131-150). Verified live on d040:
# <a href=".../line/">สั่งสินค้า พื้นที่ต่างจังหวัดกดแอดไลน์</a>. Match by that distinctive
# text so it does NOT collide with the site-wide @LINE link in the header/footer.
${PDP_LINE_CONTACT}        xpath=//a[contains(@href,'/line/')][contains(.,'กดแอดไลน์') or contains(.,'ต่างจังหวัด')]
${PDP_CART_BADGE}          css:header a[href="/cart/"]
# All cart links (mobile + desktop) — read MAX numeric badge across them.
${PDP_CART_LINK_ANY}       css:a[href="/cart/"]
${PDP_QTY_INCREMENT}       xpath=(//button[normalize-space(.)='+'] | //*[contains(@class,'qty') or contains(@class,'stepper')]//button[last()])[1]
${PDP_QTY_DECREMENT}       xpath=(//button[normalize-space(.)='-'] | //*[contains(@class,'qty') or contains(@class,'stepper')]//button[1])[1]
${PDP_QTY_INPUT}           xpath=(//input[@type='number'][contains(@class,'qty')] | //*[contains(@class,'stepper')]//input)[1]
