*** Settings ***
Documentation     TC-PROMO-02-R — login แล้วใส่คูปองผิด → error ตรงกรณีจริง.
...               Negative (parameterized). Evidence: validate_coupon, Controller.php:917-934.
...               - INVALIDXXXX (ไม่มีจริง) → "ไม่พบรหัสส่วนลด"
...               - WD12 (หมดอายุจริงบน staging) → reject
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Login User
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-02-R Unknown coupon code is rejected
    [Documentation]    P1 — รหัสที่ไม่มีจริง → "ไม่พบรหัสส่วนลด".
    [Tags]    TC-PROMO-02-R
    ${coupon}=    Load Test Data    coupon    invalid
    Apply Coupon And Expect Error    ${coupon}[code]    ${MSG_COUPON_NOT_FOUND}

TC-PROMO-02-R Expired coupon code is rejected
    [Documentation]    P1 — คูปองหมดอายุ → ควรถูก reject. BLOCKED: code WD12 ใน test data
    ...    ไม่ให้ feedback ใด ๆ บน staging (ส่วนลด ฿0, ไม่มี error) — ไม่ใช่ expired code จริง.
    ...    รอ dev ยืนยัน "รหัสคูปองที่หมดอายุแล้วจริง" (QA-Coupon-TestData-Request.md §1.2).
    [Tags]    TC-PROMO-02-R    fixme
    Skip    BLOCKED: WD12 ไม่ใช่ expired code ที่ reject จริง — ขอ codeExpired ที่ยืนยันแล้วจาก dev
