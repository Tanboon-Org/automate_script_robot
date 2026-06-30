*** Settings ***
Documentation     TC-PROMO-07 — login แล้วใส่คูปองที่ user คนนี้เคยใช้แล้ว → ใช้ซ้ำไม่ได้.
...               Negative. Precondition: loginUser (inoobeam) มี record ใน UserCoupon ของ
...               code นี้แล้ว (TD-09). Evidence: validate_coupon:1426-1438 →
...               "ท่านได้ใช้รหัสส่วนลด ... ไปแล้วค่ะ".
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Login User
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-07 Reusing an already-used coupon is rejected
    [Documentation]    P1 — ใส่คูปองเดิมที่เคยใช้ → error ใช้ซ้ำ.
    [Tags]    TC-PROMO-07
    ${coupon}=    Load Test Data    coupon    used
    Apply Coupon And Expect Error    ${coupon}[code]    ${MSG_COUPON_ALREADY_USED}
