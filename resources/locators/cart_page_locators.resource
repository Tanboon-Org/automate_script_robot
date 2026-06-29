*** Settings ***
Documentation    Locators for the cart page /cart/ (port of pages/CartPage.ts).

*** Variables ***
# Grand total (รวมทั้งสิ้น). Tailwind markup has no semantic class — fall back to the label parent.
${CART_GRAND_TOTAL}        xpath=(//*[contains(@class,'grand-total') or contains(@class,'total-price')] | //*[contains(text(),'รวมทั้งสิ้น')]/..)[1]
${CART_SUBTOTAL}           xpath=(//*[contains(@class,'subtotal')] | //*[contains(text(),'ยอดรวม')]/..)[1]
${CART_CHECKOUT_BUTTON}    xpath=//button[contains(.,'ซื้อทันที')] | //a[contains(.,'ซื้อทันที')]
# Quantity stepper icon-buttons (recon 2026-06-25): [−] qty [+]
${CART_QTY_DECREASE}       xpath=(//button[contains(@class,'shadow-inner-xl')])[1]
${CART_QTY_INCREASE}       xpath=(//button[contains(@class,'shadow-inner-xl')])[2]
${CART_DISCOUNT_NOTE}      xpath=(//*[contains(text(),'รหัสส่วนลด อยู่ขั้นตอนถัดไป')])[1]
${CART_EMPTY_MESSAGE}      xpath=(//*[contains(@class,'empty')] | //*[contains(text(),'ยังไม่มีสินค้าในตะกร้า') or contains(text(),'ตะกร้าว่าง') or contains(text(),'ไม่มีสินค้า')])[1]
