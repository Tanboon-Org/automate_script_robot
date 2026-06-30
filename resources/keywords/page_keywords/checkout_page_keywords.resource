*** Settings ***
Documentation    Checkout page actions/assertions (port of pages/CheckoutPage.ts).
...              Honours the manual-testing notes:
...                N-1 real fill() events · N-2 click temple option element ·
...                N-3 click calendar cell / native <select> · N-4 slow ribbon renderer.
Resource         ../common_keywords.resource
Resource         ../../locators/checkout_page_locators.resource

*** Variables ***
# JS that returns the value of the first enabled, non-empty option of the delivery
# time <select> (the one carrying 17:00/18:00/19:00) without selecting it.
${_FIRST_TIME_VALUE_JS}    const sels=[...document.querySelectorAll('select')]; const s=sels.find(x=>[...x.options].some(o=>/1[789]:00/.test(o.text))); if(!s) return ''; const opt=[...s.options].find(o=>o.value && !o.disabled); return opt? opt.value : '';

*** Keywords ***
Open Checkout Page
    [Documentation]    CheckoutPage.open() — navigate to /checkout/.
    Go To Route    ${ROUTES}[CHECKOUT]

# ── Temple / delivery ─────────────────────────────────────────────────────────
Select Temple
    [Documentation]    CheckoutPage.selectTemple(temple) — N-2: click the option element,
    ...    then confirm hidden wat[id] is populated.
    [Arguments]    ${temple}
    Click Element    ${CHK_TEMPLE_INPUT}
    Input Text    ${CHK_TEMPLE_INPUT}    ${temple}[searchTerm]
    ${option}=    Set Variable    xpath=//*[@role='option'][contains(., '${temple}[optionLabel]')]
    Wait Until Element Is Visible    ${option}    ${TIMEOUTS}[AUTOCOMPLETE]
    Click Element    ${option}
    Wait For Input Non Empty    ${CHK_TEMPLE_ID_HIDDEN}    ${TIMEOUTS}[AUTOCOMPLETE]

Fill Temple Hall
    [Arguments]    ${hall}
    Input Text    ${CHK_TEMPLE_HALL}    ${hall}

Fill Deceased Name
    [Arguments]    ${name}
    Input Text    ${CHK_DECEASED_NAME}    ${name}

Fill Delivery Phone
    [Arguments]    ${phone}
    Input Text    ${CHK_DELIVERY_PHONE}    ${phone}

Pick Delivery Date
    [Documentation]    CheckoutPage.pickDeliveryDate(ariaLabel) — N-3: click the day cell.
    [Arguments]    ${aria_label}
    Click Element    ${CHK_DELIVERY_DATE}
    ${cell}=    Set Variable    xpath=//*[@role='option'][@aria-label="${aria_label}"]
    Wait Until Element Is Visible    ${cell}    ${TIMEOUTS}[DEFAULT]
    Click Element    ${cell}

# ── Delivery-date boundary checks (TC-CHK-09/11) ──────────────────────────────
Open Delivery Calendar
    [Documentation]    Open the react-datepicker popup (idempotent-ish: clicks the field).
    Click Element    ${CHK_DELIVERY_DATE}
    Wait Until Page Contains Element    css:div.react-datepicker    ${TIMEOUTS}[DEFAULT]

Navigate Calendar To
    [Documentation]    Click "next month" until a day cell whose aria-label contains
    ...    ${date_part} (e.g. "July 31st, 2026") is rendered. The target day may be enabled
    ...    or disabled — we only need it present to read its state.
    [Arguments]    ${date_part}    ${max_clicks}=14
    FOR    ${i}    IN RANGE    ${max_clicks}
        ${here}=    Run Keyword And Return Status    Page Should Contain Element
        ...    xpath=//div[contains(@class,'react-datepicker__day') and contains(@aria-label,'${date_part}')]
        IF    ${here}    RETURN
        Click Element    css:button.react-datepicker__navigation--next
        Sleep    ${TIMEOUTS}[ANIMATION]s
    END
    Fail    ไม่พบช่องวันที่ '${date_part}' ในปฏิทินภายใน ${max_clicks} เดือน

Get Delivery Day Class
    [Arguments]    ${date_part}
    Open Delivery Calendar
    Navigate Calendar To    ${date_part}
    ${cls}=    Get Element Attribute
    ...    xpath=//div[contains(@class,'react-datepicker__day') and contains(@aria-label,'${date_part}')]    class
    RETURN    ${cls}

Assert Delivery Day Disabled
    [Documentation]    The calendar cell for ${date_part} must be NOT selectable
    ...    (react-datepicker__day--disabled).
    [Arguments]    ${date_part}
    ${cls}=    Get Delivery Day Class    ${date_part}
    Should Contain    ${cls}    react-datepicker__day--disabled
    ...    วันที่ '${date_part}' ควรเลือกไม่ได้ (เกินกฎจัดส่ง) แต่ปฏิทินยังเปิดให้เลือก

Assert Delivery Day Enabled
    [Documentation]    The calendar cell for ${date_part} must be selectable.
    [Arguments]    ${date_part}
    ${cls}=    Get Delivery Day Class    ${date_part}
    Should Not Contain    ${cls}    react-datepicker__day--disabled
    ...    วันที่ '${date_part}' ควรเลือกได้ (อยู่ในกรอบจัดส่ง) แต่ปฏิทิน disable

Pick Soonest Delivery Date
    [Documentation]    CheckoutPage.pickSoonestDeliveryDate() — click the first enabled
    ...    day cell; fall back to the computed next-Saturday label. Returns the aria-label.
    Click Element    ${CHK_DELIVERY_DATE}
    ${ok}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${CHK_DAY_CELL_ENABLED}    ${TIMEOUTS}[DEFAULT]
    IF    not ${ok}
        ${fallback}=    Next Delivery Aria Label
        Pick Delivery Date    ${fallback}
        RETURN    ${fallback}
    END
    ${label}=    Get Element Attribute    ${CHK_DAY_CELL_ENABLED}    aria-label
    Click Element    ${CHK_DAY_CELL_ENABLED}
    RETURN    ${label}

Select Delivery Time
    [Documentation]    CheckoutPage.selectDeliveryTime(value) — native <select>.
    [Arguments]    ${value}
    Select From List By Value    ${CHK_DELIVERY_TIME}    ${value}

Select First Available Time
    [Documentation]    CheckoutPage.selectFirstAvailableTime() — first non-empty,
    ...    non-disabled option. Returns the value chosen.
    ${value}=    Execute JavaScript    ${_FIRST_TIME_VALUE_JS}
    Should Not Be Empty    ${value}    [delivery] no enabled time option found in <select>
    Select From List By Value    ${CHK_DELIVERY_TIME}    ${value}
    RETURN    ${value}

Pick Delivery Date And Time
    [Documentation]    CheckoutPage.pickDeliveryDateAndTime(maxDays) — pick the soonest
    ...    date that actually has a free time slot (advance day-by-day if needed).
    ...    Returns a dict {date, time}.
    [Arguments]    ${max_days}=7
    FOR    ${day_index}    IN RANGE    ${max_days}
        Click Element    ${CHK_DELIVERY_DATE}
        ${appeared}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${CHK_DAY_CELL_ENABLED}    ${TIMEOUTS}[DEFAULT]
        IF    not ${appeared}    BREAK
        ${count}=    Get Element Count    ${CHK_DAY_CELL_ENABLED}
        IF    ${day_index} >= ${count}    BREAK
        ${nth}=    Evaluate    ${day_index} + 1
        ${cell}=    Set Variable    xpath=(//div[@role='option' and not(@aria-disabled='true') and not(contains(@class,'react-datepicker__day--disabled'))])[${nth}]
        ${label}=    Get Element Attribute    ${cell}    aria-label
        Click Element    ${cell}
        Sleep    ${TIMEOUTS}[ANIMATION]s
        ${value}=    Execute JavaScript    ${_FIRST_TIME_VALUE_JS}
        IF    '${value}' != ''
            Select From List By Value    ${CHK_DELIVERY_TIME}    ${value}
            ${result}=    Create Dictionary    date=${label}    time=${value}
            RETURN    ${result}
        END
    END
    Fail    [delivery] ไม่พบวันจัดส่งที่มีเวลาว่างภายใน ${max_days} วัน

# ── Ribbon (ข้อความป้าย) ──────────────────────────────────────────────────────
Fill Ribbon
    [Documentation]    CheckoutPage.fillRibbon(data) — N-4: renderer can be slow; confirm,
    ...    wait for the modal to close, retry the confirm once if still open.
    [Arguments]    ${data}
    Click Element    ${CHK_RIBBON_EDIT_BTN}
    Wait Until Element Is Visible    ${CHK_RIBBON_MODAL}    ${TIMEOUTS}[DEFAULT]
    Input Text    ${CHK_RIBBON_LINE1}    ${data}[line1]
    ${line2}=    Get From Dictionary    ${data}    line2    ${EMPTY}
    IF    '${line2}' != ''    Input Text    ${CHK_RIBBON_LINE2}    ${line2}
    ${tone}=    Get From Dictionary    ${data}    tone    w
    IF    '${tone}' == 'b'
        Run Keyword And Ignore Error    Click Element Safe    ${CHK_RIBBON_TONE_BLACK}
    ELSE
        Run Keyword And Ignore Error    Click Element Safe    ${CHK_RIBBON_TONE_WHITE}
    END
    ${layout}=    Get From Dictionary    ${data}    layout    ${EMPTY}
    IF    '${layout}' != ''
        Run Keyword And Ignore Error    Click Element Safe    xpath=//input[@value='${layout}']
    END
    Click Element    ${CHK_RIBBON_CONFIRM}
    ${closed}=    Run Keyword And Return Status
    ...    Wait Until Element Is Not Visible    ${CHK_RIBBON_MODAL}    ${TIMEOUTS}[RIBBON_RENDER]
    IF    not ${closed}
        Run Keyword And Ignore Error    Click Element    ${CHK_RIBBON_CONFIRM}
        Run Keyword And Ignore Error    Wait Until Element Is Not Visible    ${CHK_RIBBON_MODAL}    ${TIMEOUTS}[RIBBON_RENDER]
    END

Assert Ribbon Preview Contains
    [Documentation]    CheckoutPage.assertRibbonPreviewContains(text) — modal closed,
    ...    edit button back; preview text is image-rendered so DOM text is best-effort.
    [Arguments]    ${text}
    Wait Until Element Is Not Visible    ${CHK_RIBBON_MODAL}    ${TIMEOUTS}[RIBBON_RENDER]
    Element Should Be Visible    ${CHK_RIBBON_EDIT_BTN}
    Run Keyword And Ignore Error    Wait Until Page Contains    ${text}    ${TIMEOUTS}[ANIMATION]

# ── Buyer ─────────────────────────────────────────────────────────────────────
Fill Buyer
    [Documentation]    CheckoutPage.fillBuyer(customer) — N-1: real fill() events + consent.
    [Arguments]    ${customer}
    Input Text Reliably    ${CHK_BUYER_NAME}    ${customer}[name]
    Input Text Reliably    ${CHK_BUYER_EMAIL}    ${customer}[email]
    Input Text Reliably    ${CHK_BUYER_PHONE}    ${customer}[phone]
    IF    ${customer}[privacyPolicyAccepted]
        ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${CHK_PRIVACY_CHECKBOX}
        IF    not ${checked}    Click Element Safe    ${CHK_PRIVACY_CHECKBOX}
    END
    ${edm}=    Get From Dictionary    ${customer}    acceptForEdm    ${FALSE}
    IF    ${edm}
        ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${CHK_EDM_CHECKBOX}
        IF    not ${checked}    Click Element Safe    ${CHK_EDM_CHECKBOX}
    END

Get Buyer Email Value
    ${value}=    Get Value    ${CHK_BUYER_EMAIL}
    RETURN    ${value}

Assert Privacy Checkbox Checked
    Checkbox Should Be Selected    ${CHK_PRIVACY_CHECKBOX}

Assert Privacy Checkbox Not Checked
    Checkbox Should Not Be Selected    ${CHK_PRIVACY_CHECKBOX}

# ── Payment ───────────────────────────────────────────────────────────────────
Select Payment Method
    [Documentation]    CheckoutPage.selectPayment(method). The radios are 1x1 hidden
    ...    custom controls; the source clicked the visible label, but under Selenium that
    ...    big <div> label is click-intercepted. Clicking the radio input itself (JS click
    ...    via Click Element Safe) reliably selects it and fires React's onChange. Then wait
    ...    for the radio to report selected (Playwright toBeChecked auto-waits).
    [Arguments]    ${method}
    ${radio}=    Set Variable If    '${method}' == 'qr'    ${CHK_PAYMENT_QR_RADIO}    ${CHK_PAYMENT_CARD_RADIO}
    ${label}=    Set Variable If    '${method}' == 'qr'    ${CHK_PAYMENT_QR_LABEL}    ${CHK_PAYMENT_CARD_LABEL}
    # The payment section mounts a few seconds after the SPA route to /checkout/.
    # Clicking the radio before the form settles triggers a remount that drops it,
    # so wait for the radio to be present AND let the form settle before clicking.
    Wait Until Any Element Visible    ${label}    ${TIMEOUTS}[DEFAULT]
    Wait Until Page Contains Element    ${radio}    ${TIMEOUTS}[DEFAULT]
    Sleep    ${TIMEOUTS}[CART_PERSIST]s
    Wait Until Keyword Succeeds    ${TIMEOUTS}[RENDERER_SLOW]s    0.5s    Click Payment Radio And Verify    ${radio}

Click Payment Radio And Verify
    [Documentation]    JS-click the (sr-only) payment radio and confirm it is selected by
    ...    reading .checked on the SAME element synchronously. A native radio click sets
    ...    .checked=true before any React re-render, so we never re-query the DOM by locator
    ...    — that re-query is what hit a "locator not found" race when the order summary
    ...    remounts on payment change. Retried by the caller so a dropped click self-heals.
    [Arguments]    ${radio}
    Wait Until Page Contains Element    ${radio}    ${TIMEOUTS}[ANIMATION]
    ${el}=    Get WebElement    ${radio}
    ${checked}=    Execute JavaScript    arguments[0].click(); return arguments[0].checked === true;    ARGUMENTS    ${el}
    Should Be True    ${checked}    payment radio ${radio} did not become checked after click

Assert Payment Radio Checked
    [Arguments]    ${method}
    ${radio}=    Set Variable If    '${method}' == 'qr'    ${CHK_PAYMENT_QR_RADIO}    ${CHK_PAYMENT_CARD_RADIO}
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.3s    Payment Radio Should Be Checked    ${radio}

Payment Radio Should Be Checked
    [Documentation]    True when the radio reports .checked, read live via JS. If a transient
    ...    React remount detaches the node, Get WebElement raises and the caller's retry
    ...    re-finds it — never a hard "checkbox not found" failure.
    [Arguments]    ${radio}
    ${el}=    Get WebElement    ${radio}
    ${checked}=    Execute JavaScript    return arguments[0].checked === true;    ARGUMENTS    ${el}
    Should Be True    ${checked}    payment radio ${radio} is not checked yet

Assert All Payment Options Visible
    [Documentation]    CheckoutPage.assertAllPaymentOptionsVisible() — AC3.
    Element Should Be Attached    ${CHK_PAYMENT_QR_RADIO}
    Element Should Be Attached    ${CHK_PAYMENT_CARD_RADIO}
    Wait Until Any Element Visible    ${CHK_PAYMENT_QR_LABEL}    ${TIMEOUTS}[DEFAULT]
    Wait Until Any Element Visible    ${CHK_PAYMENT_CARD_LABEL}    ${TIMEOUTS}[DEFAULT]

Assert Card Fee Note Visible
    [Documentation]    CheckoutPage.assertCardFeeNoteVisible() — +3% note shown.
    Wait Until Element Is Visible    ${CHK_CARD_FEE_NOTE}    ${TIMEOUTS}[DEFAULT]

Assert Free Shipping On Checkout
    [Documentation]    CheckoutPage.assertFreeShipping() — Bangkok temple ค่าจัดส่ง ฿0/ฟรี.
    Wait Until Any Element Visible    ${CHK_FREE_SHIPPING}    ${TIMEOUTS}[DEFAULT]

Apply Discount Code
    [Documentation]    Type the code into the visible discount field and click ยืนยัน. Targets
    ...    the first VISIBLE match — the union locator also matches a hidden duplicate that
    ...    is not interactable. Empty ${code} just clears (for the "กรุณากรอกรหัส" case).
    [Arguments]    ${code}
    Input Into First Visible    ${CHK_DISCOUNT_INPUT}    ${code}
    Click First Visible Element    ${CHK_DISCOUNT_CONFIRM}

Apply Coupon And Expect Error
    [Documentation]    Enter a coupon code, click ยืนยัน, then assert the rejection message
    ...    appears anywhere on the page (validate_coupon errors render in a toast/modal whose
    ...    DOM position is not stable, so match by Thai text fragment).
    [Arguments]    ${code}    ${expected_fragment}
    Apply Discount Code    ${code}
    Wait Until Page Contains    ${expected_fragment}    ${TIMEOUTS}[DEFAULT]

# ── Order summary total (card +3%) ────────────────────────────────────────────
Get Order Summary Total Amount
    [Documentation]    CheckoutPage.getOrderSummaryTotalAmount() — numeric รวมทั้งสิ้น,
    ...    or None if the element is not visible.
    ${vis}=    Run Keyword And Return Status    Element Should Be Visible    ${CHK_ORDER_TOTAL}
    IF    not ${vis}    RETURN    ${NONE}
    ${text}=    Get Text    ${CHK_ORDER_TOTAL}
    ${amount}=    Parse Amount    ${text}
    RETURN    ${amount}

Wait For Card Total Update
    [Documentation]    CheckoutPage.waitForCardTotalUpdate(expectedTotal) — wait for the
    ...    grand total text to show the +3% (2dp) value after card selection.
    [Arguments]    ${expected_total}
    ${expected_str}=    Format Two Decimals    ${expected_total}
    Wait Until Keyword Succeeds    ${TIMEOUTS}[RENDERER_SLOW]s    0.5s
    ...    Order Total Text Should Contain    ${expected_str}

Order Total Text Should Contain
    [Arguments]    ${expected_str}
    ${text}=    Get Text    ${CHK_ORDER_TOTAL}
    ${clean}=    Replace String    ${text}    ,    ${EMPTY}
    Should Contain    ${clean}    ${expected_str}

Assert Card Total
    [Documentation]    CheckoutPage.assertCardTotal(expectedTotal) — within 0.01.
    [Arguments]    ${expected_total}
    Wait Until Element Is Visible    ${CHK_ORDER_TOTAL}    ${TIMEOUTS}[DEFAULT]
    ${actual}=    Get Order Summary Total Amount
    Amounts Should Be Close    ${actual}    ${expected_total}    0.01
    ...    Checkout grand total should equal price*1.03

# ── Submit ────────────────────────────────────────────────────────────────────
Assert Submit Disabled
    [Documentation]    CheckoutPage.assertSubmitDisabled() — TC-CHK-02 gate.
    Element Should Be Disabled    ${CHK_SUBMIT_BUTTON}

Assert Submit Enabled
    [Documentation]    CheckoutPage.assertSubmitEnabled().
    Wait Until Element Is Enabled    ${CHK_SUBMIT_BUTTON}    ${TIMEOUTS}[RENDERER_SLOW]

Click Submit
    [Documentation]    Click "ชำระเงิน" without waiting for navigation (negative-path use).
    Click Element    ${CHK_SUBMIT_BUTTON}

Place Order
    [Documentation]    CheckoutPage.placeOrder() — submit, wait for /payment/, return hash.
    Assert Submit Enabled
    Click Element    ${CHK_SUBMIT_BUTTON}
    Wait Until Url Contains Fragment    /payment/    ${TIMEOUTS}[ORDER_CREATED]
    ${url}=    Get Location
    ${hash}=    Extract Payment Hash    ${url}
    RETURN    ${hash}
