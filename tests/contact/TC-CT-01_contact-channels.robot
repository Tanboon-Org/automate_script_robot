*** Settings ***
Documentation     TC-CT-01 — หน้า /ติดต่อเรา แสดงช่องทางติดต่อครบ (LINE / โทร / อีเมล).
...               Functional-smoke: ยืนยันว่าหน้าโหลด + มีลิงก์ LINE(→/line/) + tel: + ข้อความอีเมล.
...               (reveal-on-click ระดับ interaction เก็บเป็น smoke — ตรวจปลายทางลิงก์ที่ต้องเผย)
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:contact    group:contact

*** Variables ***
${CONTACT_PATH}    /ติดต่อเรา/

*** Test Cases ***
TC-CT-01 Contact page exposes LINE, phone and email channels
    [Documentation]    P3 — เปิดหน้าติดต่อเรา → มีช่องทาง LINE / โทร / อีเมล.
    [Tags]    TC-CT-01
    Assert Content Page Loads    ${CONTACT_PATH}
    Page Should Have Link To    /line/
    Page Should Have Link To    tel:
    Wait Until Page Contains    อีเมล    ${TIMEOUTS}[DEFAULT]
