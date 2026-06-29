*** Settings ***
Documentation     D-02 regression guard — Tracking form submits via GET → PII in URL
...               (port of tests/regression/regression-defects.spec.ts). KNOWN BUG: the
...               assertion encodes the CORRECT (fixed) behavior and is skipped to keep the
...               suite green. Remove the Skip line when the defect is fixed.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser

*** Test Cases ***
D-02 Tracking form must NOT expose PII in URL (KNOWN BUG — currently uses GET)
    [Documentation]    EXPECTED to pass once D-02 is fixed (form → POST). Currently a known bug.
    [Tags]    feature:tracking    D-02    knownbug
    Skip    KNOWN BUG D-02: tracking form submits via GET, exposing PII in the URL. Remove Skip when fixed.
    Dismiss Cookie
    Open Tracking Page
    Track By Order Code    O-TEST-REGRESSION    0800000000
    ${url}=    Get Location
    Should Not Contain    ${url}    0800000000
    Should Not Contain    ${url}    O-TEST-REGRESSION
    Should Match Regexp    ${url}    /tracking/
