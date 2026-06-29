*** Settings ***
Documentation     Payment method can be selected — data-driven across QR + card
...               (port of tests/atomic/checkout.spec.ts). Stops before placeOrder.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-08 Payment method can be selected
    [Documentation]    P1 — data-driven across QR + card (payments.json).
    [Tags]    TC-CHK-08
    [Template]    Payment Method Should Be Selectable
    qr
    card

*** Keywords ***
Payment Method Should Be Selectable
    [Arguments]    ${payment_key}
    Setup Checkout
    ${payment}=    Load Test Data    payment    ${payment_key}
    Select Payment By Data    ${payment}
    Assert Payment Radio Checked    ${payment}[method]
    IF    '${payment}[method]' == 'card'
        ${has_note}=    Evaluate    $payment['feeNote'] is not None
        IF    ${has_note}    Assert Card Fee Note Visible
    END
