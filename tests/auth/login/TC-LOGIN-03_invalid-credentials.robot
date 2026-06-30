*** Settings ***
Documentation     TC-LOGIN-03 — รหัสผ่านผิด → error "รหัสหรืออีเมลผู้ใช้ไม่ถูกต้อง".
...               Evidence: LoginForm.tsx (loginStatus==failed), auth.ts:127-146.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login

*** Test Cases ***
TC-LOGIN-03 Wrong password shows invalid-credentials error
    [Documentation]    P1 — Negative.
    [Tags]    TC-LOGIN-03
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    WrongPassword!9999
    Assert Login Invalid Credentials
