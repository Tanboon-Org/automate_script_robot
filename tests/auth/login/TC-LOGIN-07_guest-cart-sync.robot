*** Settings ***
Documentation     TC-LOGIN-07 — guest มีของในตะกร้า → login → cart ไม่หาย (synUserCart).
...               Evidence: LoginForm.tsx:64-66 dispatch(synUserCart(user.cart)).
Resource          ../../../resources/keywords/suite_helpers.resource
Test Setup        Setup Auth Test
Test Teardown     Close WNW Browser
Test Tags         feature:auth    group:login    needs:review

*** Test Cases ***
TC-LOGIN-07 Guest cart is preserved after login
    [Documentation]    P2 — Integration. เพิ่มของแบบ guest ก่อน แล้วจึง login.
    [Tags]    TC-LOGIN-07
    Open H014 In Cart
    ${before}=    Read Cart Count
    Should Be True    ${before} >= 1    ต้องมีของในตะกร้าก่อน login
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]
    Assert Login Succeeded
    ${after}=    Read Cart Count
    Should Be True    ${after} >= 1    cart ของ guest ต้องไม่หายหลัง login (merge)
