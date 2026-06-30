*** Settings ***
Documentation     TC-REG-04 — password > 16 ตัว → "รหัสผ่านมีความยาวเกิน 16 ตัวอักษร".
...               Evidence: RegisterSchema .max(16).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-04 Password longer than 16 chars is rejected
    [Documentation]    P2 — Boundary (17 ตัวอักษร).
    [Tags]    TC-REG-04
    Register With    qa-pwtest@app-bit.co.th    Test@1234567890ab
    Assert Inline Error Contains    รหัสผ่านมีความยาวเกิน 16 ตัวอักษร
