*** Settings ***
Documentation    Checkout business actions (port of keywords/checkoutKeywords.ts +
...              flows/checkoutFlow.ts). Composed from page keywords only.
Resource         ../common_keywords.resource
Resource         ../page_keywords/cart_page_keywords.resource
Resource         ../page_keywords/checkout_page_keywords.resource

*** Keywords ***
Login
    [Documentation]    checkoutKeywords.login — no-op: WNW supports guest checkout.
    No Operation

Go To Checkout From Cart
    [Documentation]    checkoutKeywords.checkout(cartPage, page) — proceed cart -> checkout.
    Proceed To Checkout From Cart

Select Temple With Hall
    [Documentation]    checkoutKeywords.selectTemple(checkoutPage, temple) — temple + hall.
    [Arguments]    ${temple}
    Select Temple    ${temple}
    Fill Temple Hall    ${temple}[hall]

Select Payment By Data
    [Documentation]    checkoutKeywords.selectPayment(checkoutPage, payment).
    [Arguments]    ${payment}
    Select Payment Method    ${payment}[method]

Place Order And Get Hash
    [Documentation]    checkoutKeywords.placeOrder(checkoutPage) — returns the order hash.
    ${hash}=    Place Order
    RETURN    ${hash}

Fill Delivery And Buyer
    [Documentation]    flows/checkoutFlow.fillDeliveryAndBuyer(checkoutPage, opts) — drives
    ...    the shared delivery + buyer fill sequence (no assertions):
    ...      1 temple+hall · 2 deceased name · 3 delivery phone ·
    ...      4 soonest date WITH a free time slot · 5 ribbon · 6 buyer+consent
    [Arguments]    ${temple}    ${recipient}    ${customer}    ${ribbon}
    Select Temple With Hall    ${temple}
    Fill Deceased Name    ${recipient}[deceasedName]
    Fill Delivery Phone    ${recipient}[phone]
    Pick Delivery Date And Time
    Fill Ribbon    ${ribbon}
    Fill Buyer    ${customer}
