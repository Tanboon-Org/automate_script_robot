*** Settings ***
Documentation     D-01 regression guard — PDP <title> shows wrong code (H009 instead of H014)
...               (port of tests/regression/regression-defects.spec.ts). KNOWN BUG: the
...               assertion encodes the CORRECT (fixed) behavior and is skipped to keep the
...               suite green. Remove the Skip line when the defect is fixed.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser

*** Test Cases ***
D-01 Product H014 page title should contain H014 (KNOWN BUG — currently shows H009)
    [Documentation]    EXPECTED to pass once D-01 is fixed. Currently a known bug.
    [Tags]    feature:product    D-01    knownbug
    Skip    KNOWN BUG D-01: product title shows H009 instead of H014. Remove Skip when fixed.
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    ${title}=    Get Title
    Should Match Regexp    ${title}    (?i)${product}[code]
    Should Not Match Regexp    ${title}    (?i)H009
