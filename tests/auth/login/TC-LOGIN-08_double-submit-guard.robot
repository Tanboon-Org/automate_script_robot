*** Settings ***
Documentation     TC-LOGIN-08 — กดปุ่มเข้าสู่ระบบรัว → ปุ่ม disable ระหว่าง loading, login สำเร็จครั้งเดียว.
...               Evidence: LoginForm.tsx (loginStatus==='loading' → ปุ่มแสดง "กำลังเข้าสู่ระบบ").
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login    needs:review

*** Test Cases ***
TC-LOGIN-08 Rapid double-submit does not break login
    [Documentation]    P3 — Race (best-effort). คลิก submit 2 ครั้งติด แล้วต้อง login สำเร็จปกติ.
    [Tags]    TC-LOGIN-08
    ${user}=    Load Test Data    user    login
    Open Auth Modal
    Switch To Login Tab
    Fill Login Form    ${user}[email]    ${user}[password]
    Submit Auth Form
    Run Keyword And Ignore Error    Submit Auth Form
    Assert Login Succeeded
