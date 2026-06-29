*** Settings ***
Documentation     Unknown URL renders 404 page
...               (port of tests/atomic/orderflow-ready.spec.ts). Starts from a clean state.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:orderflow

*** Test Cases ***
TC-ERR-01 Unknown URL renders 404 page
    [Tags]    TC-ERR-01
    Go To Route    /this-page-does-not-exist-xyz123/
    Wait Until Any Element Visible
    ...    xpath=//*[contains(text(),'404') or contains(text(),'ไม่พบ') or contains(text(),'not found') or contains(text(),'กลับ')]
    ...    ${TIMEOUTS}[DEFAULT]
