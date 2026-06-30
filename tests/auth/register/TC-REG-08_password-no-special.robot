*** Settings ***
Documentation     TC-REG-08 — password ไม่มีอักขระพิเศษ → "รหัสผ่านต้องมีอักขระพิเศษอย่างน้อย 1 ตัว".
...               Evidence: RegisterSchema .matches(/[!@#$%^&*()...]/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-08 Password without special char is rejected
    [Documentation]    P2 — Validation.
    [Tags]    TC-REG-08
    Register With    qa-pwtest@app-bit.co.th    Test1234a
    Assert Inline Error Contains    รหัสผ่านต้องมีอักขระพิเศษอย่างน้อย 1 ตัว
