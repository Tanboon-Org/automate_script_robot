*** Settings ***
Documentation    2C2P hosted card-entry page actions/assertions (port of pages/Card2C2PPage.ts).
...              Safe by design: only the 2C2P sandbox declined card is ever used, so no
...              funds move. Expiry is a SINGLE combined "MM / YY" field.
Resource         ../common_keywords.resource
Resource         ../../locators/card2c2p_page_locators.resource

*** Keywords ***
Wait For Card Page
    [Documentation]    Card2C2PPage.waitForCardPage() — accept either URL variant,
    ...    dismiss the info modal, and wait for the card-number field.
    Wait Until Keyword Succeeds    ${TIMEOUTS}[NAVIGATION]s    0.5s    Card Page Url Ready
    Run Keyword And Ignore Error    Click Element    ${C2P_MODAL_CLOSE}
    Wait Until Element Is Visible    ${C2P_CARD_NUMBER}    ${TIMEOUTS}[DEFAULT]

Card Page Url Ready
    ${url}=    Get Location
    Should Match Regexp    ${url}    /payment/2c2p/|2c2p\\.com

Get Card Charge Amount
    [Documentation]    Card2C2PPage.getChargeAmount() — numeric amount on the hosted page,
    ...    or None if not visible.
    ${vis}=    Run Keyword And Return Status    Element Should Be Visible    ${C2P_CHARGE_AMOUNT}
    IF    not ${vis}    RETURN    ${NONE}
    ${text}=    Get Text    ${C2P_CHARGE_AMOUNT}
    ${amount}=    Parse Amount    ${text}
    RETURN    ${amount}

Fill Card
    [Documentation]    Card2C2PPage.fillCard(card, email) — card number first (reveals the
    ...    rest), then expiry/CVV/name/email.
    [Arguments]    ${card}    ${email}
    Input Text    ${C2P_CARD_NUMBER}    ${card}[pan]
    Wait Until Element Is Visible    ${C2P_EXPIRY}    ${TIMEOUTS}[DEFAULT]
    Wait Until Element Is Visible    ${C2P_CVV}    ${TIMEOUTS}[DEFAULT]
    Input Text    ${C2P_EXPIRY}    ${card}[expCombined]
    Input Text    ${C2P_CVV}    ${card}[cvv]
    Run Keyword And Ignore Error    Input Text    ${C2P_CARDHOLDER}    QA TEST
    Input Text    ${C2P_EMAIL}    ${email}

Submit Card
    [Documentation]    Card2C2PPage.submit() — click "Continue payment".
    Click Element    ${C2P_CONTINUE}

Cancel Card
    Click Element    ${C2P_CANCEL}

Assert Card Declined
    [Documentation]    Card2C2PPage.assertDeclined(urlPattern, textPattern) — wait for the
    ...    decline URL fragment and the visible decline text.
    [Arguments]    ${url_fragment}    ${expected_text}
    Wait Until Url Contains Fragment    ${url_fragment}    ${TIMEOUTS}[NAVIGATION]
    Wait Until Element Is Visible    xpath=//*[contains(text(),'${expected_text}')]    ${TIMEOUTS}[DEFAULT]
