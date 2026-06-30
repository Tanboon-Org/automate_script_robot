*** Settings ***
Documentation     TC-CHK-09 — วันจัดส่งย้อนอดีตต้องเลือกไม่ได้.
...               Negative. กฎ Rules/PossibleDeliveryDateTime.php:22-26 ("ไม่สามารถย้อนเวลา
...               ไปส่งในอดีต"). ฝั่ง FE ปฏิทินจะ disable วันในอดีตทั้งหมด — ทดสอบว่าช่อง
...               "เมื่อวาน" ถูก mark react-datepicker__day--disabled (เลือกไม่ได้).
...               NOTE: tag TC-CHK-09 ตรงนี้อ้าง Final doc; ไฟล์ checkout/TC-CHK-09_out-of-
...               province ใช้ ID เดียวกันแบบ mislabel (ที่จริงคือ TC-CART-05-R) — ดู report.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout    group:checkout-rules

*** Test Cases ***
TC-CHK-09 Past delivery date cannot be selected
    [Documentation]    P1 — Negative. เปิดปฏิทินจัดส่งแล้ว วันเมื่อวานต้องเลือกไม่ได้.
    [Tags]    TC-CHK-09
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    ${yesterday}=    Aria Date Part    -1
    Assert Delivery Day Disabled    ${yesterday}
