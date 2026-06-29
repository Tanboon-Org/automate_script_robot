*** Settings ***
Documentation     Invalid order lookup shows not-found message
...               (port of tests/atomic/tracking.spec.ts).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Tracking
Test Teardown     Close WNW Browser
Test Tags         feature:tracking

*** Test Cases ***
TC-TRK-04 Invalid order lookup shows not-found message
    [Documentation]    P2 — deterministic: bogus order/phone returns not-found; no data leak.
    [Tags]    TC-TRK-04
    Track By Order Code    O-0000000000    0999999999
    Assert Tracking Not Found
    Assert No Leaked Order Data
