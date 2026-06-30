*** Settings ***
Documentation     TC-LOGIN-05 — Remember Me = ON → access_token เก็บใน localStorage (คง login).
...               Evidence: auth.ts:132 setAccessToken(token, rememberMe); storage.ts (rememberMe→localStorage).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login

*** Test Cases ***
TC-LOGIN-05 Remember Me stores token in localStorage
    [Documentation]    P2 — Functional.
    [Tags]    TC-LOGIN-05
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]    remember=${TRUE}
    Assert Login Succeeded
    Assert Access Token In Local Storage
