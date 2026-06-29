*** Settings ***
Documentation     Add to cart increments cart badge
...               (port of tests/atomic/product.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:product

*** Test Cases ***
TC-PDP-04 Add to cart increments cart badge
    [Documentation]    P1.
    [Tags]    TC-PDP-04
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    ${count}=    Get PDP Cart Count
    Should Be True    ${count} >= 1
