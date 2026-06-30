*** Settings ***
Documentation     TC-REG-11 — ไม่ติ๊กยอมรับนโยบาย → "กรุณายอมรับนโยบายความเป็นส่วนตัว".
...               Evidence: RegisterSchema privacy_policy_accepted .oneOf([true]).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register    type:validation

*** Test Cases ***
TC-REG-11 Submitting without accepting privacy policy is rejected
    [Documentation]    P1 — Validation.
    [Tags]    TC-REG-11
    ${email}=    Generate Unique Email    qa-noconsent    app-bit.co.th
    Register With    ${email}    Test@1234    accept_privacy=${FALSE}
    Assert Inline Error Contains    กรุณายอมรับนโยบายความเป็นส่วนตัว
