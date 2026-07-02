*** Settings ***
Documentation     TC-PROMO-05 — ยอดตะกร้าต่ำกว่า discount_min → คูปองไม่ถูกนำมาหัก.
...               Negative, VALIDATE-ONLY (ไม่กดสั่ง → reusable). Precondition: login + คูปอง
...               MINMAXTEST (min ฿2000). Setup ใส่ 1×H014 = ฿1599 < min. Evidence: Controller.php:917-934.
...               หลักฐานที่ทน = ยอดรวมไม่ลด (ไม่ผูกกับข้อความ WM21 ที่อาจต่างตาม build).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Coupon Checkout As Login User
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:promo

*** Test Cases ***
TC-PROMO-05 Coupon below minimum subtotal is not applied
    [Documentation]    P1 — ตะกร้า ฿1599 < min ฿2000 → ใส่คูปอง MINMAXTEST แล้วยอดต้องไม่ลด.
    [Tags]    TC-PROMO-05
    ${coupon}=    Load Test Data    coupon    withMinMax
    Skip If Coupon Not Ready    ${coupon}
    Apply Coupon And Assert No Discount    ${coupon}[code]
