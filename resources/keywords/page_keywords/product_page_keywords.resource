*** Settings ***
Documentation    Product detail page (PDP) actions/assertions (port of pages/ProductPage.ts).
Resource         ../common_keywords.resource
Resource         ../../locators/product_page_locators.resource

*** Keywords ***
Open Product
    [Documentation]    ProductPage.open(slug) — navigate directly to /พวงหรีด/<slug>/.
    [Arguments]    ${slug}
    Go To Route    ${ROUTES}[PRODUCT_PREFIX]${slug}/

Assert Product Info
    [Documentation]    ProductPage.assertProductInfo(product). Exact price for known
    ...    products; for price=0 fixtures assert a live price > 0.
    [Arguments]    ${product}
    Wait Until Element Is Visible    ${PDP_HEADING}    ${TIMEOUTS}[DEFAULT]
    Element Should Contain    ${PDP_HEADING}    ${product}[code]
    Wait Until Element Is Visible    ${PDP_PRICE}    ${TIMEOUTS}[DEFAULT]
    IF    ${product}[price] > 0
        ${formatted}=    Thai Number Format    ${product}[price]
        Element Should Contain    ${PDP_PRICE}    ${formatted}
    ELSE
        ${live}=    Get PDP Price
        Should Be True    ${live} > 0    Expected live price > 0 for ${product}[code] but got ${live}
    END
    IF    ${product}[freeShipping]
        Wait Until Any Element Visible    ${PDP_FREE_SHIPPING}    ${TIMEOUTS}[DEFAULT]
    END

Get PDP Price
    [Documentation]    ProductPage.getPrice() — first numeric group of the price text.
    ${text}=    Get Text    ${PDP_PRICE}
    ${price}=    Parse Int Amount    ${text}
    RETURN    ${price}

Get PDP Cart Count
    [Documentation]    ProductPage.getCartCount().
    ${count}=    Read Cart Count
    RETURN    ${count}

Add Product To Cart
    [Documentation]    ProductPage.addToCart() — retry the click until the header cart
    ...    badge actually increments (authoritative "item added" signal), then settle.
    ${before}=    Read Cart Count
    FOR    ${attempt}    IN RANGE    3
        Run Keyword And Ignore Error    Click Element    ${PDP_ADD_TO_CART}
        ${ok}=    Run Keyword And Return Status
        ...    Wait Until Keyword Succeeds    ${TIMEOUTS}[BADGE_BESTEFFORT]s    0.3s    Cart Count Should Exceed    ${before}
        IF    ${ok}
            Sleep    ${TIMEOUTS}[CART_PERSIST]s
            RETURN
        END
    END
    Fail    addToCart: cart badge did not increment after 3 click attempts

Cart Count Should Exceed
    [Arguments]    ${before}
    ${now}=    Read Cart Count
    Should Be True    ${now} > ${before}

Buy Now
    [Documentation]    ProductPage.buyNow() — click "ซื้อทันที!" and wait for /checkout.
    Click Element    ${PDP_BUY_NOW}
    Wait Until Url Contains Fragment    /checkout    ${TIMEOUTS}[NAVIGATION]

Assert Product Not Orderable
    [Documentation]    TC-PDP-05 / TC-DISC-07 — สินค้า allow_add_to_cart=false: หน้า PDP โหลด
    ...    จริง (มี heading) แต่ปุ่มซื้อ (เพิ่มลงตะกร้า / ซื้อทันที) ต้องหายไป และมีลิงก์ LINE
    ...    ให้ติดต่อแทน (ProductButton.tsx:131-150). Hard signal = ไม่มีปุ่มซื้อ.
    Wait Until Element Is Visible    ${PDP_HEADING}    ${TIMEOUTS}[DEFAULT]
    Page Should Not Contain Element    ${PDP_ADD_TO_CART}
    ...    message=สินค้า allow_add_to_cart=false ต้องไม่มีปุ่ม "เพิ่มลงตะกร้า"
    Page Should Not Contain Element    ${PDP_BUY_NOW}
    ...    message=สินค้า allow_add_to_cart=false ต้องไม่มีปุ่ม "ซื้อทันที"
    Page Should Contain Element    ${PDP_LINE_CONTACT}
    ...    message=คาดว่าจะมีลิงก์ LINE (lin.ee/line.me) ให้ติดต่อแทนปุ่มซื้อ

Assert Title Contains Code
    [Documentation]    ProductPage.assertTitleContainsCode(code) — D-01 guard.
    [Arguments]    ${code}
    ${title}=    Get Title
    Should Match Regexp    ${title}    (?i)${code}

Assert Promotion Price Shown
    [Documentation]    TC-DISC-08 — สินค้าที่มีโปร: มีราคาตัดทอน (line-through) คู่กับราคาขาย.
    ...    ตรวจจาก computed style (text-decoration: line-through) ของ element ที่มี ฿ —
    ...    ทนต่อการเปลี่ยน class มากกว่าการ match ชื่อ class ตรง ๆ.
    ${has_struck}=    Execute Javascript
    ...    return [...document.querySelectorAll('*')].some(e=>getComputedStyle(e).textDecorationLine.includes('line-through') && /฿/.test(e.innerText));
    Should Be True    ${has_struck}    ไม่พบราคาตัดทอน (line-through) บนหน้าสินค้าที่ควรมีโปรโมชั่น
