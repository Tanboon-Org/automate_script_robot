*** Settings ***
Documentation     Product detail displays correct info — data-driven across products.json
...               (port of tests/atomic/product.spec.ts).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:product

*** Test Cases ***
TC-PDP-01 Product detail displays correct info
    [Documentation]    P1 — data-driven across every product in products.json.
    [Tags]    TC-PDP-01
    [Template]    Product Detail Should Display Correct Info
    h014
    h017
    h015
    h065

*** Keywords ***
Product Detail Should Display Correct Info
    [Arguments]    ${product_key}
    ${product}=    Load Test Data    product    ${product_key}
    Dismiss Cookie
    Open Product By Data    ${product}
    Assert Product Info    ${product}
