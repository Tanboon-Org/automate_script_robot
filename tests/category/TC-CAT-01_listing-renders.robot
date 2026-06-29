*** Settings ***
Documentation     Category listing renders with products — data-driven across all categories
...               (port of tests/atomic/category.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:category

*** Test Cases ***
TC-CAT-01 Category listing renders with products
    [Documentation]    P1 — data-driven across every category in categories.json.
    [Tags]    TC-CAT-01
    [Template]    Category Should Render With Products
    best_sellers
    express
    fresh_flower
    special_price

*** Keywords ***
Category Should Render With Products
    [Arguments]    ${category_key}
    Dismiss Cookie
    ${category}=    Load Test Data    category    ${category_key}
    Select Category    ${category}
    Assert Category Loaded    ${category}[minExpectedItems]
    Assert Filters Visible
