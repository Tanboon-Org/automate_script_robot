*** Settings ***
Documentation     Cookie banner can be dismissed without accepting
...               (port of tests/atomic/home.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:home

*** Test Cases ***
TC-HOME-02 Cookie banner can be dismissed without accepting
    [Documentation]    P3 — dismiss via X, not "ยอมรับ".
    [Tags]    TC-HOME-02
    Open Home Page
    ${present}=    Run Keyword And Return Status    Element Should Be Visible    ${HOME_COOKIE_BANNER}
    Dismiss Cookie
    Assert Home Loaded
    IF    ${present}
        Wait Until Element Is Not Visible    ${HOME_COOKIE_BANNER}    ${TIMEOUTS}[DEFAULT]
    END
