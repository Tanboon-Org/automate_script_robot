*** Settings ***
Documentation     TC-PROMO-04 — guest ใส่คูปอง → ระบบบังคับให้ login ก่อน
...               Permission. ไม่ต้อง login. Evidence: validate_coupon:1416-1424 (token check
...               มาก่อนการ lookup code) → "ต้องล๊อคอินเข้าสู่ระบบก่อนค่ะ".
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Guest
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-04 Guest applying a coupon is told to log in first
    [Documentation]    P1 — Permission. Guest checkout, ใส่คูปองใด ๆ → error ให้ login ก่อน.
    [Tags]    TC-PROMO-04
    ${coupon}=    Load Test Data    coupon    valid
    Apply Coupon And Expect Error    ${coupon}[code]    ${MSG_COUPON_LOGIN_REQUIRED}
