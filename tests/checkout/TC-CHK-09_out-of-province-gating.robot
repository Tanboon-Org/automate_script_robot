*** Settings ***
Documentation     Out-of-province temple gating — skipped (D-03 not fixed)
...               (port of tests/atomic/checkout.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-09 Out-of-province temple gating — skipped (D-03 not fixed)
    [Documentation]    SKIPPED until D-03 gating is deterministic.
    [Tags]    TC-CHK-09    D-03
    Skip    SKIPPED until D-03 is fixed (out-of-province gating is non-deterministic).
