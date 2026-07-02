*** Settings ***
Documentation     TC-PDP-05 — สินค้า allow_add_to_cart=false: PDP ต้องซ่อนปุ่มซื้อ + แสดงลิงก์ LINE.
...               Negative. TD-04 (dev: slug d040-wnw-ดอนญ่ารำลึก). Evidence: ProductButton.tsx:131-150.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:product    group:pdp

*** Test Cases ***
TC-PDP-05 Non-orderable product hides buy buttons and shows LINE
    [Documentation]    P2 — เปิด PDP สินค้าที่สั่งไม่ได้ → ไม่มีปุ่ม เพิ่มลงตะกร้า/ซื้อทันที + มี LINE.
    [Tags]    TC-PDP-05
    ${product}=    Load Test Data    product    notOrderable
    Dismiss Cookie
    Open Product By Data    ${product}
    Assert Product Not Orderable
