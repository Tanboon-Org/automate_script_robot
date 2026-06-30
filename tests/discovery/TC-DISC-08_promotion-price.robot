*** Settings ***
Documentation     TC-DISC-08 — สินค้าที่มีโปรโมชั่นแสดงราคาโปร + ราคาเดิมแบบตัดทอน.
...               Functional. ใช้ H014 (ราคาเดิม ฿1,899 ตัดทอน).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:pdp

*** Test Cases ***
TC-DISC-08 Promotion product shows a struck regular price
    [Documentation]    P2 — Functional. เปิด PDP สินค้าที่มีโปร → มีราคาตัดทอน (line-through).
    [Tags]    TC-DISC-08
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Assert Promotion Price Shown
