*** Settings ***
Documentation     Proceed to checkout button navigates to /checkout/ (port of tests/atomic/cart.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart

*** Test Cases ***
TC-CART-03 Proceed to checkout button navigates to /checkout/
    [Documentation]    P1.
    [Tags]    TC-CART-03
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Proceed To Checkout From Cart
    Current Url Should Contain    /checkout/
