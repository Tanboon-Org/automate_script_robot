*** Settings ***
Documentation     /checkout with empty cart does not crash
...               (port of tests/atomic/orderflow-ready.spec.ts). Starts from a clean state.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:orderflow

*** Test Cases ***
TC-EMPTY-01 /checkout with empty cart does not crash
    [Tags]    TC-EMPTY-01
    Open Checkout Page
    Dismiss Cookie
    Current Url Should Contain    /checkout
    Element Should Be Visible    css:body
    Page Should Not Contain    Application error
    Page Should Not Contain    Unhandled Runtime Error
