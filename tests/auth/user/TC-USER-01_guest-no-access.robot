*** Settings ***
Documentation     TC-USER-01 — guest เปิด /user-infos ตรง ๆ → ไม่มีฟอร์มบัญชี.
...               Security. โค้ด user-infos/page.tsx render `{isAuth && ...}` → guest เห็นหน้าว่าง
...               (ไม่มีปุ่ม Log Out, header ยังโชว์ปุ่ม login).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:user-infos

*** Test Cases ***
TC-USER-01 Guest cannot see the account form on /user-infos
    [Documentation]    P1 — Security. เปิด /user-infos แบบ guest → ไม่มีฟอร์ม/Log Out.
    [Tags]    TC-USER-01
    Open User Infos Page
    Assert User Infos Not Accessible As Guest
