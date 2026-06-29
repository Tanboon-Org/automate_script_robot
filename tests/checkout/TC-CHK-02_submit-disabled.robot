*** Settings ***
Documentation     Submit button is disabled when required fields are empty
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-02 Submit button is disabled when required fields are empty
    [Documentation]    P1 — submit must start disabled (validation gate).
    [Tags]    TC-CHK-02
    Setup Checkout
    Assert Submit Disabled
