*** Settings ***
Documentation     TC-FGT-03 — ไม่มี client validation: อีเมลที่ไม่มีในระบบถูกส่งตรงไป backend
...               แล้ว BE ตอบ error. ครอบ error path ของ TC-FGT-02 ด้วย (ไม่ต้อง mock).
...               Negative. → "เกิดข้อผิดพลาดในการส่งลิงก์ กรุณาลองใหม่อีกครั้ง".
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:forget-password

*** Test Cases ***
TC-FGT-03 Unknown email returns the backend error (no client validation)
    [Documentation]    P2 — Negative. อีเมลไม่มีจริง → error จาก backend.
    [Tags]    TC-FGT-03
    Open Forget Password Page
    Request Password Reset    qa-noreply+nonexistent@example.com
    Wait Until Page Contains    ${MSG_FGT_ERROR}    ${TIMEOUTS}[DEFAULT]
