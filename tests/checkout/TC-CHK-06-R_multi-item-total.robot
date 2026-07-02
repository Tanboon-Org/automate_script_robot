*** Settings ***
Documentation     TC-CHK-06-R — ตะกร้าหลายสินค้า (คนละรายการ) รวมยอดถูกต้อง.
...               Positive. เพิ่ม H014 (฿1,599) + H017 (฿2,899) → รวมทั้งสิ้น = ฿4,498.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:cart

*** Test Cases ***
TC-CHK-06-R Grand total sums multiple distinct items
    [Documentation]    P1 — สองสินค้าราคาต่างกัน → รวมทั้งสิ้น = ผลบวกราคาทั้งสอง.
    [Tags]    TC-CHK-06-R
    ${p1}=    Load Test Data    product    h014
    ${p2}=    Load Test Data    product    h017
    Dismiss Cookie
    Open Product By Data    ${p1}
    Add To Cart
    Open Product By Data    ${p2}
    Add To Cart
    Go To Cart
    Assert Cart Has Item    ${p1}[code]    ${p1}[price]
    Assert Cart Has Item    ${p2}[code]    ${p2}[price]
    ${expected}=    Evaluate    ${p1}[price] + ${p2}[price]
    Assert Grand Total    ${expected}
