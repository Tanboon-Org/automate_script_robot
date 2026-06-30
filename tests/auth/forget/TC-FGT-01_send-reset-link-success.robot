*** Settings ***
Documentation     TC-FGT-01 — ขอลิงก์รีเซ็ตรหัสผ่านด้วยอีเมลที่มีจริง → ส่งลิงก์สำเร็จ.
...               Positive. POST /web/forgot-password (forget-password/page.tsx:14-31).
...               หมายเหตุ: เคสนี้ส่งอีเมลรีเซ็ตจริงไปยังบัญชีทดสอบ (TD-30) — ลิงก์ไม่ถูกคลิก
...               จึงไม่กระทบรหัสผ่าน.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:forget-password

*** Test Cases ***
TC-FGT-01 Reset link is sent for a registered email
    [Documentation]    P1 — Positive. กรอกอีเมลที่ลงทะเบียนแล้ว → "ส่งลิงก์สำเร็จ...".
    [Tags]    TC-FGT-01
    ${user}=    Load Test Data    user    login
    Open Forget Password Page
    Request Password Reset    ${user}[email]
    Wait Until Page Contains    ${MSG_FGT_SUCCESS}    ${TIMEOUTS}[DEFAULT]
