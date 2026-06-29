*** Settings ***
Documentation    Locators for the tracking page /tracking/ (port of pages/TrackingPage.ts).
...              D-02 NOTE: the form currently submits via GET, exposing PII in the URL.
...              FIX 6: submit button scoped to the <form> to avoid the nav dropdown trigger.

*** Variables ***
${TRK_ORDER_CODE}        xpath=//input[@name='order_code'] | //input[contains(@placeholder,'เลขออเดอร์')]
${TRK_PHONE_OR_EMAIL}    xpath=//input[@name='phone_or_email_address'] | //input[contains(@placeholder,'เบอร์โทรศัพท์') or contains(@placeholder,'อีเมล')]
${TRK_TRACKING_ID}       xpath=//input[@name='tracking_id'] | //input[contains(@placeholder,'รหัสติดตาม')]
${TRK_SUBMIT_BUTTON}     xpath=//form//button[contains(.,'ติดตามสถานะ')]
# Result page is identified by the "ยอดชำระ" (amount due) line — only after a hit.
${TRK_STATUS_RESULT}     xpath=(//*[contains(text(),'ยอดชำระ')])[1]
${TRK_NOT_FOUND}         xpath=(//*[contains(@class,'error') or contains(@class,'not-found') or contains(text(),'ไม่พบ') or contains(text(),'ไม่มีข้อมูล')])[1]
