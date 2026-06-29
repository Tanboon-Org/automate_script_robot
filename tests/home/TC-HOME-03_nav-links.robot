*** Settings ***
Documentation     Navigation links resolve to correct routes
...               (port of tests/atomic/home.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:home

*** Test Cases ***
TC-HOME-03 Navigation links resolve to correct routes
    [Documentation]    P2 — primary nav triggers present; submenu best-effort.
    [Tags]    TC-HOME-03
    Open Home Page
    Assert Nav Links Visible
