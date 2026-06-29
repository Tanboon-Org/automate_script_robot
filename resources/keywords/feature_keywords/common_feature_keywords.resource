*** Settings ***
Documentation    Cross-cutting business actions (port of keywords/commonKeywords.ts +
...              components/CookieBanner.ts).
Resource         ../common_keywords.resource

*** Keywords ***
Dismiss Cookie
    [Documentation]    dismissCookie(page) — close the consent banner via X, NOT "ยอมรับ".
    ...    Safe no-op when the banner is not present.
    ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${HOME_COOKIE_CLOSE}
    IF    ${visible}
        Click Element    ${HOME_COOKIE_CLOSE}
        Run Keyword And Ignore Error
        ...    Wait Until Element Is Not Visible    ${HOME_COOKIE_BANNER}    ${TIMEOUTS}[ANIMATION]
    END
