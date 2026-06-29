*** Settings ***
Documentation    Cart page actions/assertions (port of pages/CartPage.ts).
Resource         ../common_keywords.resource
Resource         ../../locators/cart_page_locators.resource

*** Keywords ***
Open Cart Page
    [Documentation]    CartPage.open() — navigate to /cart/.
    Go To Route    ${ROUTES}[CART]

Assert Cart Has Item
    [Documentation]    CartPage.assertHasItem(name, price) — assert by visible text
    ...    (Tailwind markup has no semantic line-item class).
    [Arguments]    ${product_name}    ${price}
    Wait Until Page Contains    ${product_name}    ${TIMEOUTS}[DEFAULT]
    ${formatted}=    Thai Number Format    ${price}
    Wait Until Page Contains    ${formatted}    ${TIMEOUTS}[DEFAULT]
    Wait Until Page Contains    รวมทั้งสิ้น    ${TIMEOUTS}[DEFAULT]

Assert Grand Total
    [Documentation]    CartPage.assertGrandTotal(amount).
    [Arguments]    ${amount}
    ${formatted}=    Thai Number Format    ${amount}
    Wait Until Element Contains    ${CART_GRAND_TOTAL}    ${formatted}    ${TIMEOUTS}[DEFAULT]

Get Grand Total Amount
    [Documentation]    CartPage.getGrandTotalAmount() — numeric รวมทั้งสิ้น.
    ${text}=    Get Text    ${CART_GRAND_TOTAL}
    ${amount}=    Parse Amount    ${text}
    RETURN    ${amount}

Proceed To Checkout From Cart
    [Documentation]    CartPage.proceedToCheckout() — click "ซื้อทันที", wait for /checkout.
    Click Element    ${CART_CHECKOUT_BUTTON}
    Wait Until Url Contains Fragment    /checkout    ${TIMEOUTS}[NAVIGATION]

Assert Cart Empty
    [Documentation]    CartPage.assertEmpty() — "ยังไม่มีสินค้าในตะกร้า".
    Wait Until Element Is Visible    ${CART_EMPTY_MESSAGE}    ${TIMEOUTS}[DEFAULT]

Assert Discount Code Note Visible
    Wait Until Element Is Visible    ${CART_DISCOUNT_NOTE}    ${TIMEOUTS}[DEFAULT]

Increase Cart Quantity
    [Documentation]    CartPage.increaseQty(times) — click [+] N times.
    [Arguments]    ${times}=1
    FOR    ${i}    IN RANGE    ${times}
        Click Element    ${CART_QTY_INCREASE}
        Sleep    ${TIMEOUTS}[ANIMATION]s
    END

Decrease Cart Quantity
    [Documentation]    CartPage.decreaseQty(times) — click [−] N times.
    [Arguments]    ${times}=1
    FOR    ${i}    IN RANGE    ${times}
        Click Element    ${CART_QTY_DECREASE}
        Sleep    ${TIMEOUTS}[ANIMATION]s
    END

Click Cart Quantity Increase Best Effort
    [Documentation]    TC-CART-06 — click [+] once, ignore failure (modal may overlay).
    Run Keyword And Ignore Error    Click Element    ${CART_QTY_INCREASE}

Grand Total Should Not Reach
    [Documentation]    Assert a forbidden (over-limit) total amount does NOT appear on the page.
    [Arguments]    ${amount}
    ${formatted}=    Thai Number Format    ${amount}
    Page Should Not Contain    ${formatted}
