*** Settings ***
Documentation     TC-PROMO-03-R — login แล้วกด ยืนยัน โดยไม่กรอกรหัส → "กรุณากรอกรหัสส่วนลด".
...               Validation. Evidence: validate_coupon:1360.
...               NOTE: ส่วน "พิมพ์เล็ก→ใหญ่ (strtoupper)" ของเคสนี้ยัง BLOCKED รอ valid code
...               ที่ loginUser ยังไม่เคยใช้ (coupons.json key=valid, _status=todo).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Login User
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-03-R Empty discount code is rejected
    [Documentation]    P2 — กดยืนยันโดยไม่กรอกรหัส → ข้อความให้กรอกรหัส.
    [Tags]    TC-PROMO-03-R
    Apply Coupon And Expect Error    ${EMPTY}    ${MSG_COUPON_EMPTY}
