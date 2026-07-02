*** Settings ***
Documentation     TC-CHK-03 — อีเมลผู้ซื้อรูปแบบไม่ถูกต้อง → ฟอร์มไม่ผ่าน (ปุ่มชำระเงินยัง disabled).
...               Validation. กรอกทุกฟิลด์ถูกต้อง ยกเว้น email = รูปแบบผิด.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout

*** Test Cases ***
TC-CHK-03 Invalid buyer email keeps checkout ungated
    [Documentation]    P2 — email "not-an-email" → submit ยัง disabled (FE validation กัน).
    [Tags]    TC-CHK-03
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${recipient}=    Load Test Data    recipient    qa_test
    ${customer}=    Load Test Data    customer    qa_test
    Set To Dictionary    ${customer}    email    not-an-email
    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA    layout=1    tone=w
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}
    Assert Submit Disabled
