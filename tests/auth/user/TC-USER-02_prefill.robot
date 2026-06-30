*** Settings ***
Documentation     TC-USER-02 — หลัง login ฟอร์ม /user-infos prefill ข้อมูลจาก user.
...               Positive. ตรวจช่องอีเมลถูก prefill ด้วยอีเมลผู้ใช้ที่ล็อกอิน.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:user-infos

*** Test Cases ***
TC-USER-02 Account form is prefilled after login
    [Documentation]    P2 — Positive. ช่องอีเมลต้องเป็นอีเมลของผู้ใช้.
    [Tags]    TC-USER-02
    ${user}=    Login As Test User
    Assert User Email Prefilled    ${user}[email]
