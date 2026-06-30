*** Settings ***
Documentation     TC-CHK-13 — จำนวนป้ายต้องครบทุกพวงหรีด.
...               Validation. สั่ง 2 พวง แต่กรอกข้อความป้ายแค่พวงเดียว → ปุ่มชำระต้อง disabled
...               + ขึ้น "กรุณากรอกข้อความป้ายให้ครบทุกพวงหรีด" (validateMessageCards ฝั่ง FE,
...               ตรงกับ OrderController:store cart.* closure ฝั่ง BE).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Checkout Two Pwang
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout-rules

*** Test Cases ***
TC-CHK-13 Filling fewer cards than wreaths blocks submit
    [Documentation]    P1 — Validation. กรอกฟิลด์อื่นครบ + ป้ายพวงที่ 1 (เว้นพวงที่ 2)
    ...    → submit ยัง disabled และมีข้อความให้กรอกป้ายให้ครบทุกพวง.
    [Tags]    TC-CHK-13
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${recipient}=    Load Test Data    recipient    qa_test
    ${customer}=    Load Test Data    customer    qa_test
    ${ribbon}=    Create Dictionary    line1=ด้วยรักและอาลัย    line2=ทีม QA
    # Fill Delivery And Buyer กรอกป้ายให้พวงแรกพวงเดียว (คลิกปุ่มแก้ป้ายตัวแรก) — พวงที่ 2 ค้างว่าง
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}
    Select Payment Method    qr
    Assert Submit Disabled
    Wait Until Page Contains    ${MSG_CARD_INCOMPLETE}    ${TIMEOUTS}[DEFAULT]
