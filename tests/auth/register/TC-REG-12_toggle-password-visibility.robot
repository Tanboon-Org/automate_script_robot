*** Settings ***
Documentation     TC-REG-12 — ปุ่ม eye สลับ password ↔ text. Evidence: RegisterForm.tsx showPassword state.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register

*** Test Cases ***
TC-REG-12 Eye icon toggles password visibility
    [Documentation]    P3 — Functional.
    [Tags]    TC-REG-12
    Open Auth Modal
    Switch To Register Tab
    Input Text Reliably    ${AUTH_PASSWORD}    Test@1234
    Assert Password Field Type    password
    Toggle Password Visibility
    Assert Password Field Type    text
    Toggle Password Visibility
    Assert Password Field Type    password
