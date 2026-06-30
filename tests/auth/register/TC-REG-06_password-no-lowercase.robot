*** Settings ***
Documentation     TC-REG-06 — password ไม่มีตัวพิมพ์เล็ก → "รหัสผ่านต้องมีตัวอักษรพิมพ์เล็กอย่างน้อย 1 ตัว".
...               Evidence: RegisterSchema .matches(/[a-z]/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-06 Password without lowercase is rejected
    [Documentation]    P2 — Validation.
    [Tags]    TC-REG-06
    Register With    qa-pwtest@app-bit.co.th    TEST@1234
    Assert Inline Error Contains    รหัสผ่านต้องมีตัวอักษรพิมพ์เล็กอย่างน้อย 1 ตัว
