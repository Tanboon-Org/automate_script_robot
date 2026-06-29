*** Settings ***
Documentation     Ribbon/message-card exists at checkout and persists
...               (port of tests/atomic/orderflow-checkout.spec.ts). Closes DEF-003.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:checkout

*** Test Cases ***
TC-PDP-04-R Ribbon/message-card exists at checkout and persists
    [Documentation]    Closes DEF-003: the ribbon edit button exists at checkout, accepts
    ...    input, and persists to localStorage["messageCardModal-*"].
    [Tags]    TC-PDP-04-R
    Setup Checkout
    Element Should Be Visible    ${CHK_RIBBON_EDIT_BTN}
    ${ribbon}=    Create Dictionary    line1=ด้วยรักและอาลัย    line2=บริษัท ABC จำกัด    layout=1    tone=w
    Fill Ribbon    ${ribbon}
    ${has_key}=    Local Storage Has Key Prefix    messageCardModal-
    Should Be True    ${has_key}    expected a localStorage["messageCardModal-*"] key after filling ribbon
