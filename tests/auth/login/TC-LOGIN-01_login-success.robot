*** Settings ***
Documentation     TC-LOGIN-01 — login ด้วย credential ถูกต้อง → modal สำเร็จ + redirect /user-infos.
...               Evidence: LoginForm.tsx:62-81 (onSubmit + useEffect succeeded).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login

*** Test Cases ***
TC-LOGIN-01 Login succeeds with valid credentials
    [Documentation]    P1 — Positive. ต้องมี user ที่ยืนยันอีเมลแล้ว (TD-30).
    [Tags]    TC-LOGIN-01
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]
    Assert Login Succeeded
