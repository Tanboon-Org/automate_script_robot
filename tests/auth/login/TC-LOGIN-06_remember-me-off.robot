*** Settings ***
Documentation     TC-LOGIN-06 — Remember Me = OFF → access_token เก็บใน sessionStorage เท่านั้น
...               (ไม่อยู่ใน localStorage). Evidence: storage.ts setAccessToken (rememberMe=false→sessionStorage).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login

*** Test Cases ***
TC-LOGIN-06 No Remember Me keeps token in sessionStorage only
    [Documentation]    P2 — Functional.
    [Tags]    TC-LOGIN-06
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]    remember=${FALSE}
    Assert Login Succeeded
    Assert Access Token In Session Storage Only
