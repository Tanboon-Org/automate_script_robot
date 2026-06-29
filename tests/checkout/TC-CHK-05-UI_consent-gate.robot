*** Settings ***
Documentation     Submitting without privacy consent is blocked (no order) — KNOWN DEFECT
...               (port of tests/atomic/orderflow-checkout.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-CHK-05-UI Submitting without privacy consent is blocked (no order)
    [Documentation]    KNOWN DEFECT RSK-01/TC-SEC-01: the order API is called even without
    ...    privacy consent (kept green, mirroring test.fail in the source). Additionally,
    ...    the original test relied on Playwright route interception to abort api/order as a
    ...    safety net — SeleniumLibrary cannot intercept/abort network requests, so this
    ...    negative order-creation path is NOT executed under Selenium. Re-enable with a proxy
    ...    or Browser Library once consent is enforced (FE block + BE rule).
    [Tags]    TC-CHK-05-UI    knownbug    RSK-01
    Skip    KNOWN DEFECT RSK-01: api/order is called without consent + Selenium cannot abort the request. See docstring.
