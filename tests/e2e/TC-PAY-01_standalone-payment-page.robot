*** Settings ***
Documentation     Standalone payment page shows all required elements (known order)
...               (port of tests/e2e/purchase-loop.spec.ts). @createsOrder gating preserved.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Purchase Loop Test
Test Teardown     Close WNW Browser
Test Tags         feature:payment    createsorder

*** Test Cases ***
TC-PAY-01 standalone payment page shows all required elements (known order)
    [Documentation]    Requires a known order hash — Phase 2.
    [Tags]    TC-PAY-01
    Skip    Requires a known order hash (set KNOWN_ORDER_HASH). Phase 2.
