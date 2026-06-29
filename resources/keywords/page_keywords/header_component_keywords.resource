*** Settings ***
Documentation    Reusable header actions/assertions (port of components/HeaderComponent.ts).
Resource         ../common_keywords.resource
Resource         ../../locators/header_component_locators.resource

*** Keywords ***
Assert Header Visible
    [Documentation]    HeaderComponent.assertVisible() — cart link attached + login/register visible.
    Element Should Be Attached    ${HEADER_CART_LINK}
    ${login}=    Run Keyword And Return Status    Element Should Be Visible    ${HEADER_LOGIN}
    ${register}=    Run Keyword And Return Status    Element Should Be Visible    ${HEADER_REGISTER}
    Should Be True    ${login} or ${register}    Expected a login or register link to be visible in the header

Get Header Cart Count
    [Documentation]    HeaderComponent.getCartCount().
    ${count}=    Read Cart Count
    RETURN    ${count}

Navigate To Cart Via Header
    [Documentation]    HeaderComponent.navigateToCart().
    Click Element    ${HEADER_CART_LINK}
    Wait Until Url Contains Fragment    /cart/    ${TIMEOUTS}[NAVIGATION]
