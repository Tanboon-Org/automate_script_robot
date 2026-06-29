*** Settings ***
Documentation     Decreasing last unit removes the item (empty cart)
...               (port of tests/atomic/orderflow-cart.spec.ts). Uses H014 (1,599) as price base.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart

*** Test Cases ***
TC-CART-02b-R Decreasing last unit removes the item (empty cart)
    [Tags]    TC-CART-02b-R
    ${product}=    Open H014 In Cart
    Assert Grand Total    ${product}[price]
    Decrease Cart Quantity    1
    Assert Cart Empty
