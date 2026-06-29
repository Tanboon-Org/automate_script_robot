*** Settings ***
Documentation     Cart shows correct item name, price, and total (port of tests/atomic/cart.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:cart

*** Test Cases ***
TC-CART-01 Cart shows correct item name, price, and total
    [Documentation]    P1 — add H014, navigate to /cart/, assert item/total + discount note.
    [Tags]    TC-CART-01
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Assert Cart Has Item    ${product}[code]    ${product}[price]
    Assert Grand Total    ${product}[price]
    Assert Discount Code Note Visible
