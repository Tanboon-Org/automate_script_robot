*** Settings ***
Documentation     TC-PROMO-01-R — login แล้วใส่คูปอง valid → ส่วนลดถูกหักใน order summary.
...               Positive, VALIDATE-ONLY: ยืนยันที่ขั้น apply เท่านั้น ไม่กดสั่งจริง → คูปอง
...               ไม่ถูก consume จึงรันซ้ำได้ (logic = 1 คูปอง / 1 ครั้ง ต่อ user). ถ้าต้องการ
...               end-to-end ที่กดสั่งจริง คูปองจะถูกเผาหลังรอบแรกและต้องให้ dev reset UserCoupon.
...               Evidence: validate_coupon, Controller.php:917-934.
...               BLOCKED: ขอ valid code ที่ loginUser (chamow05w) ยังไม่เคยใช้ + ช่วง min/max +
...               ชนิด/ค่าส่วนลด จาก dev (DISCOUNT10 ถูกใช้ไปแล้ว) — QA-Coupon-TestData-Request.md §1.1.
...               เมื่อได้ค่า: ตั้ง coupons.json key=valid → _status=ready + เติม expectedDiscount.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Login User
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-01-R Valid coupon applies a discount (no order placed)
    [Documentation]    P1 — ใส่คูปองถูกต้อง → ยอดรวมลดลงตามส่วนลด โดยไม่กดสั่ง (reusable).
    [Tags]    TC-PROMO-01-R
    ${coupon}=    Load Test Data    coupon    valid
    Skip If Coupon Not Ready    ${coupon}
    Apply Coupon And Assert Discount    ${coupon}
