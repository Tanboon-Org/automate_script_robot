*** Settings ***
Documentation     TC-DISC-07 — สินค้า allow_add_to_cart=false: เปิด PDP แล้วปุ่ม Buy Now ถูกซ่อน
...               และมีลิงก์ LINE ให้ติดต่อแทน. Negative. TD-04 (dev: slug d040-wnw-ดอนญ่ารำลึก).
...               Evidence: ProductButton.tsx:131-150.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:discovery    group:pdp

*** Test Cases ***
TC-DISC-07 Disabled-sale product shows LINE instead of buy
    [Documentation]    P2 — เปิด PDP สินค้าสั่งไม่ได้ → ซ่อน Buy Now + แสดงลิงก์ LINE.
    [Tags]    TC-DISC-07
    ${product}=    Load Test Data    product    notOrderable
    Dismiss Cookie
    Open Product By Data    ${product}
    Assert Product Not Orderable
