*** Settings ***
Documentation     Clicking a product card opens PDP in a new tab
...               (port of tests/atomic/category.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:category

*** Test Cases ***
TC-CAT-04 Clicking a product card opens PDP in a new tab
    [Documentation]    P1 — products open in a NEW TAB; the new URL contains "-wnw-".
    [Tags]    TC-CAT-04
    Dismiss Cookie
    ${category}=    Load Test Data    category    best_sellers
    Select Category    ${category}
    Open First Product In New Tab
    ${url}=    Get Location
    Should Match Regexp    ${url}    -wnw-
    Close Window
    Switch Window    MAIN
