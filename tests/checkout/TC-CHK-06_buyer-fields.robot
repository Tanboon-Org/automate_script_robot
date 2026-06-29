*** Settings ***
Documentation     Buyer fields accept valid data
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-06 Buyer fields accept valid data
    [Documentation]    P1 — N-1: real fill() events; privacy checkbox checked.
    [Tags]    TC-CHK-06
    Setup Checkout
    ${customer}=    Load Test Data    customer    qa_test
    Fill Buyer    ${customer}
    ${email}=    Get Buyer Email Value
    Should Be Equal    ${email}    ${customer}[email]
    Assert Privacy Checkbox Checked
