*** Settings ***
Documentation     Delivery date can be picked from calendar
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-03 Delivery date can be picked from calendar
    [Documentation]    P1 — N-3: soonest orderable date from the live calendar DOM.
    [Tags]    TC-CHK-03
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    ${label}=    Pick Soonest Delivery Date
    Should Not Be Empty    ${label}
    ${date_value}=    Get Element Attribute    ${CHK_DELIVERY_DATE}    value
    Should Not Be Empty    ${date_value}
