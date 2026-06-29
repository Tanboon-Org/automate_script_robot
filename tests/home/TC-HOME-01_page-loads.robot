*** Settings ***
Documentation     Home page loads with header/nav/cart elements
...               (port of tests/atomic/home.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:home

*** Test Cases ***
TC-HOME-01 Home page loads with header/nav/cart elements
    [Documentation]    P2 smoke. Header/cart present; cart badge starts at 0.
    [Tags]    TC-HOME-01    smoke
    Open Home Page
    Assert Home Loaded
    Assert Header Visible
    ${count}=    Get Home Cart Count
    Should Be Equal As Integers    ${count}    0
