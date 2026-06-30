*** Settings ***
Documentation     TC-REG-02 — สมัครด้วย email ที่มีในระบบแล้ว → reject (registerError ใต้ฟอร์ม,
...               ไม่ขึ้น modal "ลงทะเบียนสำเร็จ"). Evidence: auth.ts:41-56 (errors.email[0]).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register

*** Test Cases ***
TC-REG-02 Duplicate email is rejected
    [Documentation]    P1 — Negative. ใช้ email ที่ลงทะเบียนแล้ว (TD-02c).
    [Tags]    TC-REG-02
    ${dup}=    Load Test Data    user    duplicate_email
    Register With    ${dup}[email]    Test@1234
    Wait Until Element Is Visible    ${AUTH_INLINE_ERROR}    ${TIMEOUTS}[NAVIGATION]
    Page Should Not Contain    ${MSG_REGISTER_SUCCESS}
