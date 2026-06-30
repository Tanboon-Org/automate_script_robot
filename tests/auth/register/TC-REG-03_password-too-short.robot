*** Settings ***
Documentation     TC-REG-03 — password < 8 ตัว → "รหัสผ่านต้องมีความยาวเกิน 8 ตัวอักษร".
...               Evidence: RegisterSchema .min(8). Client-side only (ไม่ยิง API).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-03 Password shorter than 8 chars is rejected
    [Documentation]    P1 — Boundary.
    [Tags]    TC-REG-03
    Register With    qa-pwtest@app-bit.co.th    Test@12
    Assert Inline Error Contains    รหัสผ่านต้องมีความยาวเกิน 8 ตัวอักษร
