*** Settings ***
Documentation     Increase/decrease quantity updates grand total
...               (port of tests/atomic/orderflow-cart.spec.ts). Uses H014 (1,599) as price base.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart

*** Test Cases ***
TC-CART-02-R Increase/decrease quantity updates grand total
    [Tags]    TC-CART-02-R
    ${product}=    Open H014 In Cart
    Assert Grand Total    ${product}[price]
    Increase Cart Quantity    1
    ${double}=    Evaluate    ${product}[price] * 2
    Assert Grand Total    ${double}
    Decrease Cart Quantity    1
    Assert Grand Total    ${product}[price]
