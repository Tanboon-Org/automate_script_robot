*** Settings ***
Documentation     TC-USER-12 — กด Log Out → เคลียร์ state + กลับสู่สถานะยังไม่ล็อกอิน.
...               Functional. handleLogOut เคลียร์ storage แล้ว redirect /. ตรวจว่าปุ่ม login
...               กลับมาแสดงและไม่มีปุ่ม Log Out แล้ว.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:user-infos

*** Test Cases ***
TC-USER-12 Logout clears the session
    [Documentation]    P1 — Functional. login → Log Out → กลับเป็น guest.
    [Tags]    TC-USER-12
    Login As Test User
    Logout
