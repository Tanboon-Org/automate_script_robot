*** Settings ***
Documentation     TC-REG-09 — password มีช่องว่าง → "รหัสผ่านต้องไม่มีช่องว่าง".
...               Evidence: RegisterSchema .matches(/^\S*$/).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-09 Password containing a space is rejected
    [Documentation]    P2 — Validation. (ครบทุกกฎอื่น เหลือแค่ช่องว่าง)
    [Tags]    TC-REG-09
    Register With    qa-pwtest@app-bit.co.th    Test@12 3
    Assert Inline Error Contains    รหัสผ่านต้องไม่มีช่องว่าง
