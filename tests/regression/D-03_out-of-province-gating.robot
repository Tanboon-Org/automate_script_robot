*** Settings ***
Documentation     D-03 regression guard — Out-of-province gating inconsistent (not automated)
...               (port of tests/regression/regression-defects.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser

*** Test Cases ***
D-03 Out-of-province gating — not automated until deterministic
    [Documentation]    Non-deterministic gating; cannot assert reliably. See TC-CHK-09.
    [Tags]    feature:checkout    D-03
    Skip    Not automated until D-03 gating is deterministic.
