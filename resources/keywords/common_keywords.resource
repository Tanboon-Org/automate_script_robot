*** Settings ***
Documentation    Common base keywords shared by all page/feature layers.
...              Ports pages/BasePage.ts (navigation + settle), helpers/waitHelpers.ts
...              (waitForPageSettle / waitForInputNonEmpty / retry) and the browser
...              lifecycle that fixtures/test.ts + config/playwright.base.ts provided.
...              NO page-specific raw selectors live here.
Library          SeleniumLibrary
Library          Collections
Library          String
Library          custom_library.py
Library          db_library.py
Variables        ../variables/routes.yaml
Variables        ../variables/timeouts.yaml
Variables        ../variables/messages.yaml
Resource         ../locators/home_page_locators.resource

*** Variables ***
# Defaults — overridden by an env_*.yaml variable file at run time.
${BASE_URL}            https://wnw2025-frontend.dev-app-bit.com
${BROWSER}             chrome
${HEADLESS}            ${TRUE}
${ENV}                 staging
# PROD safety gates (default-off). Set true on the command line for a deliberate prod run.
${ALLOW_PROD_ORDER}    ${FALSE}
${ALLOW_PROD_2C2P}     ${FALSE}

*** Keywords ***
Open WNW Browser
    [Documentation]    Open the browser at the site root. Mirrors config/playwright.base.ts:
    ...    th-TH locale, Asia/Bangkok timezone, 1920x1080, headless by default.
    ${options}=    Build Browser Options
    Open Browser    ${BASE_URL}/    browser=${BROWSER}    options=${options}
    Set Selenium Timeout    ${TIMEOUTS}[DEFAULT]
    Set Selenium Implicit Wait    0
    # Don't screenshot on every caught failure — Wait Until Keyword Succeeds retries would
    # otherwise spam dozens of PNGs. Real failures are still in the Robot log.
    Register Keyword To Run On Failure    NONE
    Wait For Page Settle

Build Browser Options
    [Documentation]    Assemble the Selenium options string (headless + locale + window).
    ${opts}=    Set Variable    add_argument("--lang=th-TH");add_argument("--window-size=1920,1080");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")
    IF    ${HEADLESS}
        ${opts}=    Set Variable    ${opts};add_argument("--headless=new")
    END
    RETURN    ${opts}

Close WNW Browser
    Close All Browsers

Go To Route
    [Documentation]    Navigate to a path relative to BASE_URL, then wait for settle.
    [Arguments]    ${path}
    Go To    ${BASE_URL}${path}
    Wait For Page Settle

Go To Absolute
    [Documentation]    Navigate to an absolute URL (used for 404 / arbitrary paths).
    [Arguments]    ${url}
    Go To    ${url}
    Wait For Page Settle

Wait For Page Settle
    [Documentation]    Port of waitHelpers.waitForPageSettle — wait for the DOM to be
    ...    interactive/complete (equivalent to Playwright 'domcontentloaded').
    Wait For Condition    return document.readyState == 'interactive' || document.readyState == 'complete'
    ...    timeout=${TIMEOUTS}[NAVIGATION]

Wait Until Url Contains Fragment
    [Documentation]    Wait until the (decoded) current URL contains a fragment.
    [Arguments]    ${fragment}    ${timeout}=${TIMEOUTS}[NAVIGATION]
    Wait Until Keyword Succeeds    ${timeout}s    0.5s    Current Url Should Contain    ${fragment}

Current Url Should Contain
    [Arguments]    ${fragment}
    ${url}=    Get Location
    ${decoded}=    Decode Url    ${url}
    Should Contain    ${decoded}    ${fragment}

Wait For Input Non Empty
    [Documentation]    Port of waitHelpers.waitForInputNonEmpty — poll until an input's
    ...    value is non-empty (e.g. hidden wat[id] after temple autocomplete).
    [Arguments]    ${locator}    ${timeout}=${TIMEOUTS}[AUTOCOMPLETE]
    Wait Until Keyword Succeeds    ${timeout}s    0.2s    Input Value Should Not Be Empty    ${locator}

Input Value Should Not Be Empty
    [Arguments]    ${locator}
    ${value}=    Get Value    ${locator}
    Should Not Be Empty    ${value}

Get Input Value Safe
    [Documentation]    Return an input's value, or empty string if not found.
    [Arguments]    ${locator}
    ${value}=    Run Keyword And Return Status    Element Should Be Visible    ${locator}
    ${result}=    Run Keyword If    ${value}    Get Value    ${locator}    ELSE    Set Variable    ${EMPTY}
    RETURN    ${result}

Read Cart Count
    [Documentation]    Port of ProductPage._readCartCount / HeaderComponent.getCartCount.
    ...    Two cart links exist (mobile + desktop); return the MAX numeric badge value.
    ${count}=    Execute JavaScript
    ...    return Math.max(0, ...Array.from(document.querySelectorAll('a[href="/cart/"]')).map(l => parseInt((l.textContent||'').replace(/\\D/g,'')||'0',10)));
    RETURN    ${count}

Element Should Be Attached
    [Documentation]    Presence in the DOM regardless of visibility (Playwright toBeAttached).
    [Arguments]    ${locator}
    Page Should Contain Element    ${locator}

Get Session Storage Item
    [Arguments]    ${key}
    ${value}=    Execute JavaScript    return window.sessionStorage.getItem(arguments[0]);    ARGUMENTS    ${key}
    RETURN    ${value}

Local Storage Has Key Prefix
    [Documentation]    True if any localStorage key starts with the given prefix.
    [Arguments]    ${prefix}
    ${result}=    Execute JavaScript
    ...    return Object.keys(window.localStorage).some(k => k.startsWith(arguments[0]));    ARGUMENTS    ${prefix}
    RETURN    ${result}

Wait Until Any Element Visible
    [Documentation]    Wait until AT LEAST ONE element matched by the locator is visible.
    ...    Mirrors Playwright getByText(...).first().isVisible() intent better than
    ...    SeleniumLibrary's first-match-only wait when a locator matches hidden + visible
    ...    nodes (e.g. the "ส่งฟรี" banner / 404 text appear as several nodes, some empty).
    [Arguments]    ${locator}    ${timeout}=${TIMEOUTS}[DEFAULT]
    Wait Until Keyword Succeeds    ${timeout}s    0.5s    Some Matched Element Is Visible    ${locator}

Some Matched Element Is Visible
    [Arguments]    ${locator}
    ${elements}=    Get WebElements    ${locator}
    FOR    ${el}    IN    @{elements}
        ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${el}
        IF    ${visible}    RETURN
    END
    Fail    No visible element matched ${locator}

Input Text Reliably
    [Documentation]    Type into a field and verify the value landed exactly. Retries the
    ...    real keystroke path (Clear + Input Text) up to 3x to survive dropped keystrokes
    ...    on React inputs; only as a last resort sets the value via JS and fires
    ...    input/change/blur so React Hook Form still validates (honours N-1 intent).
    [Arguments]    ${locator}    ${text}
    FOR    ${attempt}    IN RANGE    3
        Run Keyword And Ignore Error    Clear Element Text    ${locator}
        Input Text    ${locator}    ${text}
        ${value}=    Get Value    ${locator}
        IF    '${value}' == '${text}'    RETURN
    END
    ${el}=    Get WebElement    ${locator}
    Execute JavaScript
    ...    arguments[0].value=arguments[1]; arguments[0].dispatchEvent(new Event('input',{bubbles:true})); arguments[0].dispatchEvent(new Event('change',{bubbles:true})); arguments[0].dispatchEvent(new Event('blur',{bubbles:true}));
    ...    ARGUMENTS    ${el}    ${text}

Click Element Safe
    [Documentation]    Click via Selenium; fall back to a JS click for visually-hidden
    ...    custom controls (1x1 radios/checkboxes the WNW site uses).
    [Arguments]    ${locator}
    ${ok}=    Run Keyword And Return Status    Click Element    ${locator}
    IF    not ${ok}
        Js Click Element    ${locator}
    END

Js Click Element
    [Documentation]    Dispatch a native click directly on the element via JavaScript.
    ...    Required for the 1x1 hidden payment radios: a Selenium native click scrolls
    ...    and hits the overlaying label <div> (intercepted / navigates), which unmounts
    ...    the radios. A JS click on the input itself selects it and fires React onChange.
    [Arguments]    ${locator}
    ${el}=    Get WebElement    ${locator}
    Execute JavaScript    arguments[0].click();    ARGUMENTS    ${el}

Format Two Decimals
    [Documentation]    Format a number to exactly two decimal places (JS toFixed(2)).
    [Arguments]    ${value}
    ${formatted}=    Evaluate    f"{float(${value}):.2f}"
    RETURN    ${formatted}

Amounts Should Be Close
    [Documentation]    Assert two numeric amounts are within tolerance (Playwright toBeCloseTo).
    [Arguments]    ${actual}    ${expected}    ${tolerance}=0.01    ${message}=Amounts differ
    Should Be True    abs(float(${actual}) - float(${expected})) <= ${tolerance}
    ...    ${message}: actual=${actual} expected=${expected} tol=${tolerance}
