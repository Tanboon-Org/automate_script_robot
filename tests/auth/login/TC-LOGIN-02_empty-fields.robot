*** Settings ***
Documentation     TC-LOGIN-02 — submit ฟอร์ม login ว่าง → error "กรุณาระบุอีเมลและรหัสผ่าน", ไม่ยิง API.
...               Evidence: LoginForm.tsx (errors.email||errors.password), LoginSchema.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login

*** Test Cases ***
TC-LOGIN-02 Empty login fields show required error
    [Documentation]    P2 — Validation (client-side only).
    [Tags]    TC-LOGIN-02
    Open Auth Modal
    Switch To Login Tab
    Submit Auth Form
    Assert Login Required Error
