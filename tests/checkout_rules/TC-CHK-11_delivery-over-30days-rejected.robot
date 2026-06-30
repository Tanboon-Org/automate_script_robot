*** Settings ***
Documentation     TC-CHK-11 — วันจัดส่งล่วงหน้าได้ ≤30 วัน (boundary strict).
...               Boundary. กฎ Rules/PossibleDeliveryDateTime.php:38-44 (">30 วัน reject").
...               ปฏิทิน FE: วันที่ today+30 ต้องเลือกได้, today+31 ต้องเลือกไม่ได้.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout-rules

*** Test Cases ***
TC-CHK-11 Delivery date is allowed at +30 days but rejected at +31
    [Documentation]    P2 — Boundary. ขอบ 30 วันแบบ inclusive: +30 เลือกได้, +31 เลือกไม่ได้.
    [Tags]    TC-CHK-11
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    ${day30}=    Aria Date Part    30
    ${day31}=    Aria Date Part    31
    Assert Delivery Day Enabled    ${day30}
    Assert Delivery Day Disabled    ${day31}
