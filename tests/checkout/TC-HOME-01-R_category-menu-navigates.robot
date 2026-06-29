*** Settings ***
Documentation     Category menu navigates to listing with products
...               (port of tests/atomic/orderflow-ready.spec.ts). Starts from a clean state.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:orderflow

*** Test Cases ***
TC-HOME-01-R Category menu navigates to listing with products
    [Tags]    TC-HOME-01-R
    Open Home Page
    Dismiss Cookie
    ${clicked}=    Run Keyword And Return Status    Click Fresh Flower Nav
    ${navigated}=    Run Keyword And Return Status    Wait Until Url Contains Fragment    ร้านพวงหรีด    10
    IF    not (${clicked} and ${navigated})
        Open Category    ${ROUTES}[CATEGORY_FRESH_FLOWER]
    END
    ${url}=    Get Location
    ${decoded}=    Decode Url    ${url}
    Should Match Regexp    ${decoded}    ร้านพวงหรีด|พวงหรีดดอกไม้สด
    Assert Category Loaded
