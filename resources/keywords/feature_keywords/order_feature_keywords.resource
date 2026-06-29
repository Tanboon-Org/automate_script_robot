*** Settings ***
Documentation    Order confirmation / tracking / notify business actions
...              (port of keywords/orderKeywords.ts). Composed from page keywords only.
Resource         ../common_keywords.resource
Resource         ../page_keywords/payment_page_keywords.resource
Resource         ../page_keywords/tracking_page_keywords.resource

*** Keywords ***
Verify Order Created
    [Documentation]    orderKeywords.verifyOrderCreated(page, expectedOrderNo, expectedTotal).
    ...    HARD signals: /payment/<hash>/ + "O-#########" + total. SECONDARY (best-effort):
    ...    bank-transfer section, countdown, notify button. Returns the order number.
    [Arguments]    ${expected_order_no}=${NONE}    ${expected_total}=${NONE}
    Wait For Payment Load
    Assert Order Details    order_number=${expected_order_no}    total_amount=${expected_total}
    Run Keyword And Ignore Error    Assert Bank Transfer Visible
    Run Keyword And Ignore Error    Assert Countdown Visible
    Run Keyword And Ignore Error    Assert Notify Payment Button Visible
    ${order_no}=    Get Order Number
    RETURN    ${order_no}

Track Order
    [Documentation]    orderKeywords.trackOrder(page, orderCode, phoneOrEmail, expectedStatus).
    [Arguments]    ${order_code}    ${phone_or_email}    ${expected_status}=${NONE}
    Open Tracking Page
    Track By Order Code    ${order_code}    ${phone_or_email}
    IF    $expected_status is not None
        Assert Tracking Status Visible    ${expected_status}
    END

Notify Payment
    [Documentation]    orderKeywords.notifyPayment(page, opts) — upload TEST slip, confirm,
    ...    then assert the Order Success (thankyou) page. NO real funds move.
    [Arguments]    ${slip_path}    ${bank_keyword}    ${amount}    ${transfer_time}=10:00    ${expected_order_no}=${NONE}
    Submit Payment Notification    ${slip_path}    ${bank_keyword}    ${amount}    ${transfer_time}
    Assert Notification Submitted    ${expected_order_no}
