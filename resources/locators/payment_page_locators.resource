*** Settings ***
Documentation    Locators for the payment page /payment/<hash>/ (port of pages/PaymentPage.ts).
...              IMPORTANT: automation NEVER transfers funds. Suite stops at content
...              assertion. The notify-payment form fields all carry name attributes.

*** Variables ***
# Order number "O-#########" — keyword extracts the code via regex from this element's text.
${PAY_ORDER_NUMBER}        xpath=(//*[contains(text(),'O-')])[1]
${PAY_TOTAL_AMOUNT}        xpath=(//*[contains(text(),'รวมทั้งสิ้น') or contains(text(),'ยอดชำระ')]/..)[1]
${PAY_COUNTDOWN}           css:[class*="countdown"], [class*="timer"]
${PAY_QR_SECTION}          xpath=(//*[contains(text(),'QR') or contains(text(),'PromptPay')]/..)[1]
${PAY_BANK_TRANSFER}       xpath=(//*[contains(text(),'โอนบัญชี') or contains(text(),'หรีด ณ วัด')]/..)[1]
${PAY_ACCOUNT_HOLDER}      xpath=(//*[contains(text(),'หรีด ณ วัด')])[1]
${PAY_NOTIFY_BUTTON}       xpath=//button[contains(.,'แจ้งชำระเงิน')] | //a[contains(.,'แจ้งชำระเงิน')]

# ── notify-payment / upload-slip form (all have name attributes) ───────────────
${PAY_BANK_SELECT}         css:select[name="bank_id"]
${PAY_AMOUNT_INPUT}        css:input[name="price"]
${PAY_DATE_INPUT}          css:input[name="paymentDate"]
${PAY_TRANSFER_TIME}       css:input[name="transfer_time"]
${PAY_SLIP_INPUT}          css:input[type="file"]
${PAY_NOTIFY_SUBMIT}       xpath=//button[normalize-space(.)='แจ้งชำระเงิน']
${PAY_UPLOAD_SUCCESS}      xpath=(//*[contains(text(),'อัพโหลดสำเร็จ')])[1]
${PAY_THANKYOU_TEXT}       xpath=(//*[contains(text(),'ขอบคุณสำหรับคำสั่งซื้อ')])[1]
