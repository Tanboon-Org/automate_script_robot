*** Settings ***
Documentation     TC-TRK2-04 — ค้นด้วย tracking_id ที่ไม่มีจริง → หน้า not-found และไม่ leak
...               ข้อมูลออเดอร์คนอื่น. Negative, deterministic (ไม่ต้องมี order จริง).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Tracking
Test Teardown     Close WNW Browser
Test Tags         feature:tracking    group:tracking

*** Test Cases ***
TC-TRK2-04 Invalid tracking id shows not-found without leaking data
    [Documentation]    P2 — tracking_id ปลอม → not-found branch, ไม่โชว์ข้อมูลออเดอร์จริง.
    [Tags]    TC-TRK2-04
    Track By Tracking Id    fake-tracking-id-0000
    Assert Tracking Not Found
    Assert No Leaked Order Data
