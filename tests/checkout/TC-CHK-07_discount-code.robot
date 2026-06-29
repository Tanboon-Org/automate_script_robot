*** Settings ***
Documentation     Discount code — owner-supplied codes needed
...               (port of tests/atomic/checkout.spec.ts). BLOCKED (fixme).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-07 Discount code — owner-supplied codes needed
    [Documentation]    BLOCKED (fixme): requires owner-supplied valid/expired codes.
    [Tags]    TC-CHK-07    fixme
    Skip    BLOCKED: needs real valid/expired discount codes from the site owner (coupons.json).
