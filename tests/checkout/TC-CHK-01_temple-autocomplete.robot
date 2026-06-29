*** Settings ***
Documentation     Temple autocomplete registers selection and shows free shipping
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-01 Temple autocomplete registers selection and shows free shipping
    [Documentation]    P1 — N-2: click the option element; Bangkok temple → free shipping.
    [Tags]    TC-CHK-01
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    ${hidden}=    Get Element Attribute    ${CHK_TEMPLE_ID_HIDDEN}    value
    Should Not Be Empty    ${hidden}
    IF    ${temple}[freeShipping]    Assert Free Shipping On Checkout
