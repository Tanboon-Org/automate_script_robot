*** Settings ***
Documentation    Tracking page actions/assertions (port of pages/TrackingPage.ts).
...              D-02 NOTE: the form currently submits via GET, exposing PII in the URL.
Resource         ../common_keywords.resource
Resource         ../../locators/tracking_page_locators.resource

*** Keywords ***
Open Tracking Page
    [Documentation]    TrackingPage.open() — navigate to /tracking/.
    Go To Route    ${ROUTES}[TRACKING]

Track By Order Code
    [Documentation]    TrackingPage.trackByOrderCode(orderCode, phoneOrEmail).
    [Arguments]    ${order_code}    ${phone_or_email}
    Input Text    ${TRK_ORDER_CODE}    ${order_code}
    Input Text    ${TRK_PHONE_OR_EMAIL}    ${phone_or_email}
    Click Element    ${TRK_SUBMIT_BUTTON}
    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.5s    Tracking Result Or Error Appeared

Track By Tracking Id
    [Documentation]    TrackingPage.trackById(trackingId).
    [Arguments]    ${tracking_id}
    Input Text    ${TRK_TRACKING_ID}    ${tracking_id}
    Click Element    ${TRK_SUBMIT_BUTTON}
    Run Keyword And Ignore Error
    ...    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.5s    Tracking Result Or Error Appeared

Tracking Result Or Error Appeared
    ${a}=    Run Keyword And Return Status    Element Should Be Visible    ${TRK_STATUS_RESULT}
    ${b}=    Run Keyword And Return Status    Element Should Be Visible    ${TRK_NOT_FOUND}
    Should Be True    ${a} or ${b}

Assert Tracking Status Visible
    [Documentation]    TrackingPage.assertStatusVisible(expectedText).
    [Arguments]    ${expected_text}
    Wait Until Element Is Visible    ${TRK_STATUS_RESULT}    ${TIMEOUTS}[DEFAULT]
    Wait Until Page Contains    ${expected_text}    ${TIMEOUTS}[DEFAULT]

Assert Tracking Result Loaded
    [Documentation]    Confirm the status result container is present (purchase-loop step 12).
    Wait Until Element Is Visible    ${TRK_STATUS_RESULT}    ${TIMEOUTS}[DEFAULT]

Assert Tracking Not Found
    [Documentation]    TrackingPage.assertNotFound().
    Wait Until Element Is Visible    ${TRK_NOT_FOUND}    ${TIMEOUTS}[DEFAULT]

Assert No Leaked Order Data
    [Documentation]    TrackingPage.assertNoLeakedOrderData() — known real order fragments
    ...    must NOT appear for a bogus query (D-02 guard).
    FOR    ${fragment}    IN    1,599    291286
        Page Should Not Contain    ${fragment}
    END

Assert No Pii In Url
    [Documentation]    TrackingPage.assertNoPiiInUrl(piiValues) — D-02 GET-form leak guard.
    [Arguments]    @{pii_values}
    ${url}=    Get Location
    ${leaked}=    Url Contains Pii    ${url}    @{pii_values}
    Should Not Be True    ${leaked}    D-02 REGRESSION (GET form leak): URL exposes PII\nURL: ${url}
