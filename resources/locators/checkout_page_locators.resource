*** Settings ***
Documentation    Locators for the checkout page /checkout/ (port of pages/CheckoutPage.ts).
...              Fields with a name attribute use name selectors; the rest use
...              placeholder/role/text. Notes N-1..N-4 are honoured in the keywords.

*** Variables ***
# ── Temple / delivery ─────────────────────────────────────────────────────────
${CHK_TEMPLE_INPUT}        xpath=//input[contains(@placeholder,'ชื่อวัด')]
${CHK_TEMPLE_ID_HIDDEN}    css:input[name="wat[id]"]
${CHK_TEMPLE_HALL}         xpath=//input[@name='temple_hall'] | //input[contains(@placeholder,'ศาลา')]
${CHK_DECEASED_NAME}       xpath=//input[@name='deceased_name'] | //input[contains(@placeholder,'ชื่อผู้เสีย')]
${CHK_DELIVERY_PHONE}      xpath=(//input[@name='phone_number'] | //input[contains(@placeholder,'เบอร์ติดต่อ')])[1]
${CHK_DELIVERY_DATE}       xpath=//input[@name='delivery_date'] | //input[contains(@placeholder,'วันจัดส่ง') or contains(@placeholder,'เลือกวัน')]
${CHK_DELIVERY_TIME}       xpath=//select[.//option[contains(.,'17:00') or contains(.,'18:00') or contains(.,'19:00')]]
# Open-calendar day cells that are NOT disabled (react-datepicker).
${CHK_DAY_CELL_ENABLED}    xpath=//div[@role='option' and not(@aria-disabled='true') and not(contains(@class,'react-datepicker__day--disabled'))]

# ── Ribbon (ข้อความป้าย) modal ─────────────────────────────────────────────────
${CHK_RIBBON_EDIT_BTN}     xpath=//button[contains(.,'แก้ไขข้อความป้าย')]
${CHK_RIBBON_MODAL}        xpath=(//*[contains(text(),'เพิ่มข้อความป้าย')])[1]
${CHK_RIBBON_LINE1}        xpath=//input[contains(@placeholder,'บรรทัดที่ 1')]
${CHK_RIBBON_LINE2}        xpath=//input[contains(@placeholder,'บรรทัดที่ 2')]
${CHK_RIBBON_TONE_WHITE}   css:input[value="w"]
${CHK_RIBBON_TONE_BLACK}   css:input[value="b"]
${CHK_RIBBON_CONFIRM}      xpath=(//button[contains(.,'ตกลง')])[last()]

# ── Buyer ─────────────────────────────────────────────────────────────────────
${CHK_BUYER_NAME}          xpath=(//input[@name='name'] | //input[contains(@placeholder,'ชื่อ-สกุล') or contains(@placeholder,'ชื่อผู้ซื้อ')])[1]
${CHK_BUYER_EMAIL}         xpath=(//input[@name='email'] | //input[contains(@placeholder,'อีเมล')])[1]
${CHK_BUYER_PHONE}         xpath=(//input[@name='customer_phone_number'] | //input[@name='phone'] | //input[contains(@placeholder,'เบอร์โทร')])[1]
${CHK_DISCOUNT_INPUT}      xpath=//input[@name='discount_code'] | //input[contains(@placeholder,'รหัสส่วนลด')]
${CHK_DISCOUNT_CONFIRM}    xpath=//button[contains(.,'ยืนยัน')]
# Coupon apply result — assert by stable Thai fragment (verified live on staging).
# Guest sees a static FE hint (not the backend's "ต้องล๊อคอิน..." text); a guest can't even
# enter a code. The rest render after clicking ยืนยัน while logged in.
${MSG_COUPON_LOGIN_REQUIRED}    ล็อกอินเพื่อใส่รหัสส่วนลด
${MSG_COUPON_NOT_FOUND}         ไม่พบรหัสส่วนลด
${MSG_COUPON_EMPTY}             กรุณากรอกรหัสส่วนลด
${MSG_COUPON_ALREADY_USED}      ได้ใช้รหัสส่วนลด
# Message-card validation (validateMessageCards) — shown in the checkout checklist when a
# wreath's card is not filled. Used by TC-CHK-13 / TC-CARD-05.
${MSG_CARD_INCOMPLETE}          กรุณากรอกข้อความป้ายให้ครบทุกพวงหรีด
# Ribbon/message-card modal: line 1 required (save disabled until filled). Used by TC-CARD-03.
${MSG_CARD_LINE1_REQUIRED}      กรุณาระบุ "ข้อความบรรทัดที่ 1"
${CHK_ADD_NEW_USER}        css:input[name="add_to_new_user"]
${CHK_PRIVACY_CHECKBOX}    css:input[name="privacy_policy_accepted"]
${CHK_EDM_CHECKBOX}        css:input[name="accept_for_edm"]

# ── Payment ───────────────────────────────────────────────────────────────────
# Radios are sr-only (visually hidden) but carry stable, unique ids — prefer id over the
# value attribute so the locator stays specific across React re-renders.
${CHK_PAYMENT_QR_RADIO}    id:payment-qr
${CHK_PAYMENT_CARD_RADIO}    id:payment-card
${CHK_PAYMENT_QR_LABEL}    xpath=//*[contains(text(),'ชำระผ่าน QR PromptPay')]
${CHK_PAYMENT_CARD_LABEL}    xpath=//*[contains(text(),'ชำระผ่านบัตรเครดิตและเดบิต')]
${CHK_CARD_FEE_NOTE}       xpath=(//*[contains(text(),'+3%') or contains(text(),'ค่าธรรม')])[1]
${CHK_FREE_SHIPPING}       xpath=//*[contains(text(),'ฟรี') or contains(text(),'฿0')]
# Grand total (รวมทั้งสิ้น) — span.text-lg.text-brown (unique on staging), label sibling fallback.
${CHK_ORDER_TOTAL}         xpath=(//span[contains(@class,'text-lg') and contains(@class,'text-brown')] | //*[contains(text(),'รวมทั้งสิ้น')]/following-sibling::span[1])[1]

# ── Submit ────────────────────────────────────────────────────────────────────
${CHK_SUBMIT_BUTTON}       xpath=//button[contains(.,'ชำระเงิน')]
