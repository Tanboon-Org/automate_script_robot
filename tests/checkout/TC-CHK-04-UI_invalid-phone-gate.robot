*** Settings ***
Documentation     TC-CHK-04-UI — เบอร์โทรผู้ซื้อรูปแบบไม่ถูกต้อง (FE) → ฟอร์มไม่ผ่าน
...               (ปุ่มชำระเงินยัง disabled). Validation. กรอกทุกฟิลด์ถูก ยกเว้น phone = สั้น/ผิด.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout

*** Test Cases ***
TC-CHK-04-UI Invalid buyer phone keeps checkout ungated
    [Documentation]    P2 — phone "12" (ผิดรูปแบบ) → submit ยัง disabled.
    [Tags]    TC-CHK-04-UI
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${recipient}=    Load Test Data    recipient    qa_test
    ${customer}=    Load Test Data    customer    qa_test
    Set To Dictionary    ${customer}    phone    12
    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA    layout=1    tone=w
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}
    Assert Submit Disabled
