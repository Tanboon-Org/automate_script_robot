*** Settings ***
Documentation     TC-OH-02 — ประวัติออเดอร์: empty state.
...               Positive. ผู้ใช้ที่ยังไม่มีออเดอร์ → แท็บ "รายการสั่งซื้อ" ขึ้น
...               "- ยังไม่มีรายการสั่งซื้อ -" (OrdersSection.tsx).
...               NOTE: ใช้ loginUser (inoobeam) ที่ปัจจุบันไม่มีออเดอร์. TC-OH-01/03/04
...               (มีออเดอร์/copy code/LINE) ต้องการ user ที่มีออเดอร์ (TD-39) — รอ dev.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:order-history

*** Test Cases ***
TC-OH-02 Order history shows empty state
    [Documentation]    P3 — Positive. ไม่มีออเดอร์ → ข้อความ empty state.
    [Tags]    TC-OH-02
    Login As Test User
    Assert Order History Empty
