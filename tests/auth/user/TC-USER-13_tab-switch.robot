*** Settings ***
Documentation     TC-USER-13 — สลับแท็บ "ข้อมูลส่วนตัว" ↔ "รายการสั่งซื้อ" ใน /user-infos.
...               Functional. แต่ละแท็บต้อง render เนื้อหาของตัวเองถูกต้อง.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:user-infos

*** Test Cases ***
TC-USER-13 Switching tabs renders the right section
    [Documentation]    P3 — Functional. แท็บข้อมูลส่วนตัว = ฟอร์มอีเมล, แท็บรายการสั่งซื้อ = ออเดอร์.
    [Tags]    TC-USER-13
    Login As Test User
    # แท็บเริ่มต้น = ข้อมูลส่วนตัว → ฟอร์มอีเมลต้อง render
    Get First Visible Element    ${USER_EMAIL_INPUT}
    # สลับไปแท็บรายการสั่งซื้อ → ออเดอร์ section ต้องโผล่
    Open Orders Tab
    Wait Until Any Element Visible    ${USER_ORDERS_EMPTY}    ${TIMEOUTS}[DEFAULT]
    # สลับกลับแท็บข้อมูลส่วนตัว → ฟอร์มอีเมลกลับมา
    Open Personal Info Tab
    Get First Visible Element    ${USER_EMAIL_INPUT}
