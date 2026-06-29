*** Settings ***
Documentation    Home page actions/assertions (port of pages/HomePage.ts).
Resource         ../common_keywords.resource
Resource         ../../locators/home_page_locators.resource

*** Keywords ***
Open Home Page
    [Documentation]    HomePage.open() — navigate to '/'.
    Go To Route    ${ROUTES}[HOME]

Assert Home Loaded
    [Documentation]    HomePage.assertLoaded() — header present and a cart link attached.
    Wait For Page Settle
    Wait Until Element Is Visible    ${HOME_HEADER}    ${TIMEOUTS}[DEFAULT]
    Element Should Be Attached    ${HOME_CART_LINK_ANY}

Get Home Cart Count
    [Documentation]    HomePage.getCartCount().
    ${count}=    Read Cart Count
    RETURN    ${count}

Dismiss Home Cookie Banner
    [Documentation]    HomePage.dismissCookieBanner() — close via X, NOT "ยอมรับ".
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${HOME_COOKIE_CLOSE}
    IF    ${visible}
        Click Element    ${HOME_COOKIE_CLOSE}
        Run Keyword And Ignore Error
        ...    Wait Until Element Is Not Visible    ${HOME_COOKIE_BANNER}    ${TIMEOUTS}[DEFAULT]
    END

Assert Nav Links Visible
    [Documentation]    HomePage.assertNavLinksVisible() — top-level nav triggers present,
    ...    submenu expansion is best-effort.
    Wait Until Element Is Visible    ${HOME_NAV_TRIGGER_BTN}    ${TIMEOUTS}[DEFAULT]
    FOR    ${label}    IN    พวงหรีดดอกไม้สด    ติดตามสถานะ    ช่วยเหลือ
        Wait Until Page Contains Element    xpath=//nav//*[contains(text(),'${label}')]    ${TIMEOUTS}[DEFAULT]
    END
    Run Keyword And Ignore Error    Click Element    ${HOME_NAV_TRACKING_BTN}

Click Best Seller Nav Link
    [Documentation]    Click the "สินค้าขายดี" navigation link.
    Click Element    ${HOME_BEST_SELLER_NAV}

Click Fresh Flower Nav
    [Documentation]    Click the "พวงหรีดดอกไม้สด" top-level nav item.
    Click Element    ${HOME_NAV_FRESH_FLOWER}
