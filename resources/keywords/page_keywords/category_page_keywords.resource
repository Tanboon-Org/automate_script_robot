*** Settings ***
Documentation    Category/listing actions/assertions (port of pages/CategoryPage.ts).
Resource         ../common_keywords.resource
Resource         ../../locators/category_page_locators.resource

*** Keywords ***
Open Category
    [Documentation]    CategoryPage.open(url) — navigate to a category listing path.
    [Arguments]    ${category_url}
    Go To Route    ${category_url}

Assert Category Loaded
    [Documentation]    CategoryPage.assertLoaded(minItems) — at least one product card,
    ...    and >= minItems cards (Playwright retries until cards appear).
    [Arguments]    ${min_items}=1
    Wait Until Keyword Succeeds    10s    0.5s    Product Cards Present
    ${count}=    Get Element Count    ${CAT_PRODUCT_CARDS}
    Should Be True    ${count} >= ${min_items}    Expected >= ${min_items} product cards, found ${count}

Product Cards Present
    ${count}=    Get Element Count    ${CAT_PRODUCT_CARDS}
    Should Be True    ${count} > 0

Assert Filters Visible
    [Documentation]    CategoryPage.assertFiltersVisible() — only when the filter sidebar is present.
    ${has_filter}=    Run Keyword And Return Status    Element Should Be Visible    ${CAT_FILTER}
    IF    ${has_filter}    Element Should Be Visible    ${CAT_FILTER}

Open First Product In New Tab
    [Documentation]    CategoryPage.clickFirstProduct() — products open in a NEW TAB.
    ...    Returns nothing; the driver is switched to the new tab.
    ${before}=    Get Window Handles
    Click Element    ${CAT_PRODUCT_CARDS}
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.3s    New Window Opened    ${before}
    Switch Window    NEW
    Wait For Page Settle

Open Product By Name In New Tab
    [Documentation]    CategoryPage.clickProductByName(name).
    [Arguments]    ${name}
    ${card}=    Set Variable    xpath=(//a[contains(@href,'-wnw-')][contains(., '${name}')])[1]
    ${before}=    Get Window Handles
    Click Element    ${card}
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.3s    New Window Opened    ${before}
    Switch Window    NEW
    Wait For Page Settle

New Window Opened
    [Arguments]    ${before}
    ${now}=    Get Window Handles
    Should Be True    len(${now}) > len(${before})

Get Listing Card Count
    [Documentation]    Number of product cards currently rendered on the listing.
    ${count}=    Get Element Count    ${CAT_PRODUCT_CARDS}
    RETURN    ${count}

Go To Next Listing Page
    [Documentation]    Click "ถัดไป" to advance the listing. The SPA writes ?page=N to the URL
    ...    asynchronously after the click, so wait until the page query appears.
    Click First Visible Element    ${CAT_NEXT_PAGE}
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.5s    Current Url Should Contain    page=

Assert Page Is Not 404
    [Documentation]    The current page settled to real content (no NotfoundPage marker).
    ...    Retried: a client-routed page can flash "ไม่พบหน้า" briefly before its data loads.
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.5s    Page Should Not Contain    ไม่พบหน้า

Get Product Link Href By Code
    [Documentation]    CategoryPage.findProductLinkByCode(code) — return the href of the
    ...    listing anchor for a product code, or None if it is not on the page.
    [Arguments]    ${code}
    ${lower}=    Convert To Lower Case    ${code}
    ${loc}=    Set Variable    css:a[href*="${lower}-wnw"]
    ${exists}=    Run Keyword And Return Status    Page Should Contain Element    ${loc}
    IF    not ${exists}    RETURN    ${NONE}
    ${href}=    Get Element Attribute    ${loc}    href
    RETURN    ${href}
