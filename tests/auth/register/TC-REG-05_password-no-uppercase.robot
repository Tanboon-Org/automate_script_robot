*** Settings ***
Documentation     TC-REG-05 — password ไม่มีตัวพิมพ์ใหญ่ → "รหัสผ่านต้องมีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว".
...               Evidence: RegisterSchema .matches(/[A-Z]/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-05 Password without uppercase is rejected
    [Documentation]    P2 — Validation.
    [Tags]    TC-REG-05
    Register With    qa-pwtest@app-bit.co.th    test@1234
    Assert Inline Error Contains    รหัสผ่านต้องมีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว
