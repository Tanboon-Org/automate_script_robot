*** Settings ***
Documentation     TC-DISC-05 — หน้า "แนะนำเฉพาะคุณ" (products-special) render รายการสินค้า.
...               Smoke. NOTE: ส่วนที่ match ตาม cookie wizard_answers (key_1..4) ยังไม่ได้
...               assert — ต้องรู้ mapping คำตอบ→tag (TD-37) จาก dev ก่อน. เคสนี้คุมแค่หน้า
...               wizard listing โหลดและมีสินค้า.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:listing

*** Test Cases ***
TC-DISC-05 Wizard listing (products-special) renders products
    [Documentation]    P3 — Smoke. เปิด /products-special/ → มีสินค้าแสดง.
    [Tags]    TC-DISC-05
    Dismiss Cookie
    ${category}=    Load Test Data    category    wizard_special
    Open Category    ${category}[url]
    Assert Category Loaded    1
