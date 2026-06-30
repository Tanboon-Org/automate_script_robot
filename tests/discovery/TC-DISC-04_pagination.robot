*** Settings ***
Documentation     TC-DISC-04 — listing pagination: 15 ชิ้น/หน้า และคงสถานะหน้าใน URL.
...               Functional. หน้า 1 = 15 cards; กด "ถัดไป" → ?page=2 + ยังมีสินค้า.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:listing

*** Test Cases ***
TC-DISC-04 Listing paginates at 15 per page and keeps page in URL
    [Documentation]    P2 — Functional. ใช้หมวดดอกไม้สด (มี >15 ชิ้น).
    [Tags]    TC-DISC-04
    ${category}=    Load Test Data    category    fresh_flower
    Dismiss Cookie
    Open Category    ${category}[url]
    Assert Category Loaded    1
    ${page1}=    Get Listing Card Count
    Should Be Equal As Integers    ${page1}    15    หน้าแรกต้องมี 15 ชิ้นพอดี (cap 15/หน้า)
    Go To Next Listing Page
    Current Url Should Contain    page=2
    Assert Category Loaded    1
