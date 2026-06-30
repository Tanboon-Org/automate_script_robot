*** Settings ***
Documentation     TC-REG-13 — ลิงก์นโยบายเปิดแท็บใหม่ (target=_blank, href=/นโยบายความเป็นส่วนตัว/).
...               Evidence: RegisterForm.tsx <a href="/นโยบายความเป็นส่วนตัว/" target="_blank">.
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:register

*** Test Cases ***
TC-REG-13 Privacy policy link opens in a new tab
    [Documentation]    P3 — Functional.
    [Tags]    TC-REG-13
    Open Auth Modal
    Switch To Register Tab
    ${target}=    Get Element Attribute    ${AUTH_PRIVACY_LINK}    target
    Should Be Equal    ${target}    _blank
    ${href}=    Get Element Attribute    ${AUTH_PRIVACY_LINK}    href
    Should Contain    ${href}    นโยบายความเป็นส่วนตัว
