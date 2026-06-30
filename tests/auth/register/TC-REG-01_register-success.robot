*** Settings ***
Documentation     TC-REG-01 — สมัครด้วย email ใหม่ + password ผ่านกฎ + ติ๊ก privacy →
...               "ลงทะเบียนสำเร็จ / กรุณาตรวจสอบอีเมลเพื่อยืนยันตัวตน" (ไม่ auto-login).
...               Evidence: RegisterForm.tsx:46-55 (useEffect succeeded → openSuccessModal).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register

*** Test Cases ***
TC-REG-01 Register succeeds and prompts email verification
    [Documentation]    P1 — Positive. อีเมล gen ใหม่ทุกรัน เพื่อกันชนของเดิม.
    [Tags]    TC-REG-01
    ${data}=    Load Test Data    user    new_register
    ${email}=    Generate Unique Email    ${data}[emailPrefix]    ${data}[emailDomain]
    Register With    ${email}    ${data}[password]
    Assert Register Succeeded
