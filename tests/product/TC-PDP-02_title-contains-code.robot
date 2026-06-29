*** Settings ***
Documentation     Page title contains product code H014 — KNOWN BUG D-01
...               (port of tests/atomic/product.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:product

*** Test Cases ***
TC-PDP-02 Page title contains product code H014
    [Documentation]    P2. KNOWN BUG D-01: PDP <title> shows "H009". Skipped to keep the
    ...    suite green (mirrors test.fail in the source). Remove Skip when D-01 is fixed.
    [Tags]    TC-PDP-02    knownbug    D-01
    Skip    KNOWN BUG D-01: PDP <title> shows "H009" instead of the real code. Remove Skip when fixed.
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Assert Title Contains Code    ${product}[code]
