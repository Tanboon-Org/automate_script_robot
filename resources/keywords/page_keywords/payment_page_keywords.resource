*** Settings ***
Documentation    Payment page actions/assertions (port of pages/PaymentPage.ts).
...              IMPORTANT: automation NEVER transfers funds. The notify-payment flow
...              uploads a TEST slip with TEST-marked buyer data only.
Resource         ../common_keywords.resource
Resource         ../../locators/payment_page_locators.resource

*** Keywords ***
Wait For Payment Load
    [Documentation]    PaymentPage.waitForLoad() — /payment/<hash>/ + order number visible.
    Wait Until Url Contains Fragment    /payment/    ${TIMEOUTS}[ORDER_CREATED]
    Wait Until Element Is Visible    ${PAY_ORDER_NUMBER}    ${TIMEOUTS}[NAVIGATION]

Get Order Number
    [Documentation]    PaymentPage.getOrderNumber() — extract "O-#########".
    ${text}=    Get Text    ${PAY_ORDER_NUMBER}
    ${order_no}=    Extract Order Number    ${text}
    RETURN    ${order_no}

Assert Order Details
    [Documentation]    PaymentPage.assertOrderDetails({orderNumber, totalAmount, buyerName}).
    [Arguments]    ${order_number}=${NONE}    ${total_amount}=${NONE}    ${buyer_name}=${NONE}
    IF    $order_number is not None
        Element Should Contain    ${PAY_ORDER_NUMBER}    ${order_number}
    END
    IF    $total_amount is not None
        ${formatted}=    Thai Number Format    ${total_amount}
        Element Should Contain    ${PAY_TOTAL_AMOUNT}    ${formatted}
    END
    IF    $buyer_name is not None
        Wait Until Page Contains    ${buyer_name}    ${TIMEOUTS}[DEFAULT]
    END

Assert QR Visible
    Wait Until Element Is Visible    ${PAY_QR_SECTION}    ${TIMEOUTS}[DEFAULT]

Assert Bank Transfer Visible
    [Documentation]    PaymentPage.assertBankTransferVisible() — section + account holder name.
    Wait Until Element Is Visible    ${PAY_BANK_TRANSFER}    ${TIMEOUTS}[DEFAULT]
    Wait Until Element Is Visible    ${PAY_ACCOUNT_HOLDER}    ${TIMEOUTS}[DEFAULT]

Assert Countdown Visible
    Wait Until Element Is Visible    ${PAY_COUNTDOWN}    ${TIMEOUTS}[DEFAULT]

Assert Notify Payment Button Visible
    Wait Until Element Is Visible    ${PAY_NOTIFY_BUTTON}    ${TIMEOUTS}[DEFAULT]

Wait For Notify Form
    [Documentation]    Best-effort wait for the notify-payment form to render.
    Run Keyword And Ignore Error    Wait Until Element Is Visible    ${PAY_NOTIFY_BUTTON}    ${TIMEOUTS}[DEFAULT]

Get Bank Options
    [Documentation]    PaymentPage.getBankOptions() — real bank_id options (no placeholder).
    ...    Returns a list of dicts {value, label}.
    ${options}=    Execute JavaScript
    ...    const s=document.querySelector('select[name="bank_id"]'); if(!s) return []; return [...s.options].filter(o=>o.value!=='' && !/เลือก|กรุณา/.test(o.text)).map(o=>({value:o.value,label:o.text.trim()}));
    RETURN    ${options}

Assert Bank Option Selectable
    [Documentation]    PaymentPage.assertBankOptionSelectable(value) — select + verify; no submit.
    [Arguments]    ${value}
    Select From List By Value    ${PAY_BANK_SELECT}    ${value}
    List Selection Should Be    ${PAY_BANK_SELECT}    ${value}

Submit Payment Notification
    [Documentation]    PaymentPage.submitPaymentNotification(...) — fill the notify form,
    ...    upload the TEST slip, and submit. NO real funds move.
    [Arguments]    ${slip_path}    ${bank_keyword}    ${amount}    ${transfer_time}=10:00
    ${value}=    Execute JavaScript
    ...    const s=document.querySelector('select[name="bank_id"]'); if(!s) return ''; const opt=[...s.options].find(o=>o.text.includes(arguments[0])); return opt? opt.value:'';    ARGUMENTS    ${bank_keyword}
    Select From List By Value    ${PAY_BANK_SELECT}    ${value}
    Input Text    ${PAY_AMOUNT_INPUT}    ${amount}
    Click Element    ${PAY_DATE_INPUT}
    ${today_label}=    Today Aria Label
    Click Element    xpath=//*[@role='option'][@aria-label="${today_label}"]
    Run Keyword And Ignore Error    Press Keys    ${NONE}    ESCAPE
    Input Text    ${PAY_TRANSFER_TIME}    ${transfer_time}
    Choose File    ${PAY_SLIP_INPUT}    ${slip_path}
    Run Keyword And Ignore Error    Wait Until Element Is Visible    ${PAY_UPLOAD_SUCCESS}    ${TIMEOUTS}[NAVIGATION]
    Wait Until Element Is Enabled    ${PAY_NOTIFY_SUBMIT}    ${TIMEOUTS}[ORDER_CREATED]
    Click Element    ${PAY_NOTIFY_SUBMIT}

Assert Notification Submitted
    [Documentation]    PaymentPage.assertNotificationSubmitted(expectedOrderNo) —
    ...    redirect to /payment/thankyou/ + "ขอบคุณสำหรับคำสั่งซื้อ".
    [Arguments]    ${expected_order_no}=${NONE}
    Wait Until Url Contains Fragment    /payment/thankyou/    ${TIMEOUTS}[ORDER_CREATED]
    Wait Until Element Is Visible    ${PAY_THANKYOU_TEXT}    ${TIMEOUTS}[NAVIGATION]
    IF    $expected_order_no is not None
        Wait Until Page Contains    ${expected_order_no}    ${TIMEOUTS}[DEFAULT]
    END

Assert Payment Status Result Visible
    [Documentation]    Used by purchase-loop to confirm the tracking result page loaded.
    Wait Until Element Is Visible    ${PAY_ORDER_NUMBER}    ${TIMEOUTS}[DEFAULT]
