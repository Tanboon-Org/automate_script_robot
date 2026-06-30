*** Settings ***
Documentation     TC-CARD-03 — ข้อความป้ายบรรทัดที่ 1 จำเป็น: เว้นว่าง → ปุ่มบันทึก disable.
...               Validation. เปิด modal ป้าย (ยังไม่กรอก) → ปุ่ม "ตกลง" disabled +
...               ขึ้น 'กรุณาระบุ "ข้อความบรรทัดที่ 1"' (shouldDisableButton).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:messagecard    group:ribbon

*** Test Cases ***
TC-CARD-03 Save is blocked until line 1 is filled
    [Documentation]    P1 — Validation. modal ป้ายเปิดมาโดยบรรทัด 1 ว่าง → บันทึกไม่ได้.
    [Tags]    TC-CARD-03
    Setup Checkout
    Open Ribbon Modal
    Assert Ribbon Save Disabled
