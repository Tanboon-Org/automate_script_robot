*** Settings ***
Documentation     TC-LOGIN-04 — login ด้วย user ที่ยังไม่ยืนยันอีเมล → error
...               "อีเมลผู้ใช้ ยังไม่ได้ยืนยันตัวตน". Evidence: LoginForm.tsx useEffect (failed +
...               loginError=='Your account is not confirmed yet...'). ต้องใช้ TD-31 (ขอจาก dev).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login    blocked:testdata

*** Test Cases ***
TC-LOGIN-04 Unverified email shows confirmation-required error
    [Documentation]    P1 — Negative. BLOCKED จนกว่าจะได้ user unverified จาก dev (TD-31).
    [Tags]    TC-LOGIN-04
    ${user}=    Load Test Data    user    unverified
    Skip If    '${user}[email]'.startswith('<<')    TD-31 unverified user ยังไม่พร้อม — ขอจาก dev
    Login With    ${user}[email]    ${user}[password]
    Assert Login Unverified Email
