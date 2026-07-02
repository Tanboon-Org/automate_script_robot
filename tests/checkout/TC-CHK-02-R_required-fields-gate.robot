*** Settings ***
Documentation     TC-CHK-02-R — ปุ่ม "ชำระเงิน" ต้อง disabled จนกว่าจะกรอกฟิลด์บังคับครบ.
...               Negative/gate. Verified live 2026-07-02: ฟอร์มเปล่า → submit disabled.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout

*** Test Cases ***
TC-CHK-02-R Submit stays disabled until required fields are filled
    [Documentation]    P1 — เข้า checkout โดยยังไม่กรอกอะไร → ปุ่มชำระเงิน disabled.
    [Tags]    TC-CHK-02-R
    Setup Checkout
    Assert Submit Disabled
