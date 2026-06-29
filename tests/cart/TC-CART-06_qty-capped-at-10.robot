*** Settings ***
Documentation     Cart quantity is capped at 10
...               (port of tests/atomic/orderflow-cart.spec.ts). Uses H014 (1,599) as price base.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart

*** Test Cases ***
TC-CART-06 Cart quantity is capped at 10
    [Tags]    TC-CART-06
    ${product}=    Open H014 In Cart
    ${max_total}=    Evaluate    ${product}[price] * 10
    ${over_total}=    Evaluate    ${product}[price] * 11
    Increase Cart Quantity    9
    Assert Grand Total    ${max_total}
    Click Cart Quantity Increase Best Effort
    Sleep    ${TIMEOUTS}[ANIMATION]s
    ${actual}=    Get Grand Total Amount
    Should Be Equal As Numbers    ${actual}    ${max_total}
    Grand Total Should Not Reach    ${over_total}
