*** Settings ***
Documentation     TC-DISC-10 — หน้า "พวงหรีดใกล้ฉัน" (wreath-nearme) render รายการสินค้า.
...               Smoke. location-based listing.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:listing

*** Test Cases ***
TC-DISC-10 Near-me listing renders products
    [Documentation]    P3 — Smoke. เปิด /wreath-nearme/ → มีสินค้าแสดง.
    [Tags]    TC-DISC-10
    Dismiss Cookie
    ${nearme}=    Load Test Data    category    near_me
    Open Category    ${nearme}[url]
    Assert Category Loaded    1
