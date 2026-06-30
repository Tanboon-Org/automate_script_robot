*** Settings ***
Documentation     TC-REG-07 — password ไม่มีตัวเลข → "รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว".
...               Evidence: RegisterSchema .matches(/[0-9]/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-07 Password without digit is rejected
    [Documentation]    P2 — Validation.
    [Tags]    TC-REG-07
    Register With    qa-pwtest@app-bit.co.th    Test@abcd
    Assert Inline Error Contains    รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว
