*** Settings ***
Documentation     Ribbon modal accepts text and layout, shows preview
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-05 Ribbon modal accepts text and layout, shows preview
    [Documentation]    P1 — N-4: renderer slowness handled in Fill Ribbon.
    [Tags]    TC-CHK-05
    Setup Checkout
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    Pick Soonest Delivery Date
    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA Regression Prod    layout=1    tone=w
    Fill Ribbon    ${ribbon}
    Assert Ribbon Preview Contains    ${ribbon}[line1]
