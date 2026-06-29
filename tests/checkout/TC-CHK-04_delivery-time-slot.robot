*** Settings ***
Documentation     Delivery time slot can be selected
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-04 Delivery time slot can be selected
    [Documentation]    P2 — native <select>. Picks the soonest date that actually has a
    ...    free time slot (advances day-by-day) then verifies the slot is selected.
    [Tags]    TC-CHK-04
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    ${picked}=    Pick Delivery Date And Time
    Should Not Be Empty    ${picked}[time]
    ${selected}=    Get Selected List Value    ${CHK_DELIVERY_TIME}
    Should Be Equal    ${selected}    ${picked}[time]
