*** Settings ***
Documentation     TC-GBL-02 — mini-cart badge แสดงจำนวนสินค้าถูกต้องบน header.
...               Functional. เพิ่มสินค้า 1 ชิ้น → badge ตะกร้าบน header = 1.
...               NOTE: ส่วน dropdown รายการ mini-cart ไม่ได้ assert (header มี cart link ซ้ำ
...               desktop/mobile + dropdown ไม่นิ่ง) — คุมเฉพาะ badge count.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:global    group:header

*** Test Cases ***
TC-GBL-02 Cart badge reflects item count
    [Documentation]    P2 — Functional. add 1 ชิ้น → header badge = 1.
    [Tags]    TC-GBL-02
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    ${count}=    Get Header Cart Count
    Should Be Equal As Integers    ${count}    1    header cart badge ควรเป็น 1 หลังเพิ่มสินค้า
