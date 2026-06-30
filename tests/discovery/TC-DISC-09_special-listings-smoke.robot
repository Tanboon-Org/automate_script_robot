*** Settings ***
Documentation     TC-DISC-09 — หน้า listing พิเศษ render ได้: ส่งด่วน + ราคาพิเศษ.
...               Smoke. NOTE: หน้า /wreath-donate/ ถูกตัดออกชั่วคราว — render ไม่นิ่ง
...               (โชว์ "ไม่พบหน้า" ค้างเมื่อไม่มีสินค้า tag บริจาค) → finding รอ dev ยืนยัน.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:listing

*** Test Cases ***
TC-DISC-09 Express and promotion listings render with products
    [Documentation]    P3 — Smoke. ส่งด่วน + ราคาพิเศษ มีสินค้า.
    [Tags]    TC-DISC-09
    Dismiss Cookie
    ${express}=    Load Test Data    category    express
    Open Category    ${express}[url]
    Assert Category Loaded    1
    ${promo}=    Load Test Data    category    special_price
    Open Category    ${promo}[url]
    Assert Category Loaded    1
