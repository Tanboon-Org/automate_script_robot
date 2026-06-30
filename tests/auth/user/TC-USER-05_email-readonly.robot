*** Settings ***
Documentation     TC-USER-05 — ช่องอีเมลใน /user-infos แก้ไม่ได้ (disabled).
...               Functional. อีเมลเป็น identity จึง read-only.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:user-infos

*** Test Cases ***
TC-USER-05 Email field is read-only
    [Documentation]    P3 — Functional. ช่องอีเมลต้อง disabled แก้ไขไม่ได้.
    [Tags]    TC-USER-05
    Login As Test User
    Assert User Email Field Read Only
