*** Settings ***
Documentation     TC-REG-10 — email รูปแบบผิด → "กรุณากรอกอีเมลที่ถูกต้อง".
...               Evidence: RegisterSchema email .matches(/^[^\s@]+@[^\s@]+\.[^\s@]+$/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-10 Invalid email format is rejected
    [Documentation]    P2 — Validation.
    [Tags]    TC-REG-10
    Register With    abc    Test@1234
    Assert Inline Error Contains    กรุณากรอกอีเมลที่ถูกต้อง
