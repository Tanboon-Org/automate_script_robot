*** Settings ***
Documentation     Track by tracking ID — requires issued ID
...               (port of tests/atomic/tracking.spec.ts).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Tracking
Test Teardown     Close WNW Browser
Test Tags         feature:tracking

*** Test Cases ***
TC-TRK-02 Track by tracking ID — requires issued ID
    [Documentation]    P2 — no Tracking ID is issued for unpaid test orders.
    [Tags]    TC-TRK-02
    Skip    Requires an issued Tracking ID (only after order fulfillment). Phase 2.
