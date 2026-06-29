*** Settings ***
Documentation     Empty cart shows empty-state message
...               (port of tests/atomic/orderflow-ready.spec.ts). Starts from a clean state.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:orderflow

*** Test Cases ***
TC-CART-01 Empty cart shows empty-state message
    [Tags]    TC-CART-01
    Open Cart Page
    Dismiss Cookie
    Assert Cart Empty
