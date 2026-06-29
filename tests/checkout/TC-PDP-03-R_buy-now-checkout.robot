*** Settings ***
Documentation     Buy Now goes straight to checkout and stores product
...               (port of tests/atomic/orderflow-ready.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:orderflow

*** Test Cases ***
TC-PDP-03-R Buy Now goes straight to checkout and stores product
    [Tags]    TC-PDP-03-R
    ${product}=    Load Test Data    product    h015
    Dismiss Cookie
    Open Product By Data    ${product}
    Buy Now
    Current Url Should Contain    /checkout
    ${stored}=    Get Session Storage Item    checkoutProduct
    Should Not Be Empty    ${stored}
    Should Contain    ${stored}    ${product}[slug]
