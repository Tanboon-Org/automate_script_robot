*** Settings ***
Documentation     TC-CART-03-R — ตะกร้าของ guest คงอยู่หลัง reload หน้า (persist).
...               Positive. เพิ่ม H014 → reload /cart/ → สินค้ายังอยู่ + ยอดเท่าเดิม.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart    group:cart

*** Test Cases ***
TC-CART-03-R Guest cart persists across a page reload
    [Documentation]    P2 — guest เพิ่มสินค้า → reload → ตะกร้ายังมีสินค้า/ยอดเดิม.
    [Tags]    TC-CART-03-R
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Assert Cart Has Item    ${product}[code]    ${product}[price]
    Reload Page
    Wait For Page Settle
    Assert Cart Has Item    ${product}[code]    ${product}[price]
    Assert Grand Total    ${product}[price]
