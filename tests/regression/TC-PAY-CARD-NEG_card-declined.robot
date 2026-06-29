*** Settings ***
Documentation     2C2P card-declined negative test (port of tests/regression/2c2p-card-declined.spec.ts).
...               TC-PAY-CARD-NEG: browse → checkout → card payment → place order → 2C2P hosted
...               page → fill declined sandbox card → assert decline outcome (/payment/fail/ +
...               "การชำระเงินไม่สำเร็จ"). Also cross-checks checkout total == 2C2P amount == price*1.03.
...               @createsOrder + @cardDeclined. PROD requires BOTH ALLOW_PROD_ORDER=true and
...               ALLOW_PROD_2C2P=true. No funds move (sandbox declined card 4444333322221111).
Resource          ../../resources/imports/app_imports.robot
Test Setup        Setup Card Declined Test
Test Teardown     Close WNW Browser
Test Tags         feature:payment    createsorder    carddeclined

*** Test Cases ***
TC-PAY-CARD-NEG Card declined — 2C2P sandbox (non-3DS)
    [Tags]    TC-PAY-CARD-NEG
    ${customer}=    Load Test Data    customer    qa_test
    ${recipient}=    Load Test Data    recipient    qa_test
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${payment}=    Load Test Data    payment    card
    ${card}=    Load Test Data    card    declined_non3ds

    ${product}=    Open Random Product Via Home
    ${price}=    Get PDP Price
    Should Be True    ${price} > 0
    Log    [card-declined] สินค้า: ${product}[code], ราคา: ${price}
    Add To Cart

    Go To Cart
    Assert Cart Has Item    ${product}[name]    ${price}
    Proceed To Checkout From Cart

    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA Card Declined Test    layout=1    tone=w
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}

    Select Payment By Data    ${payment}
    Assert Card Fee Note Visible

    # Checkout grand total must equal price * 1.03 (site does not round).
    ${expected_total}=    Evaluate    round(${price} * 1.03, 2)
    Log    [card-declined] ราคาสินค้า: ${price}, expectedTotal (+3%): ${expected_total}
    Wait For Card Total Update    ${expected_total}
    ${checkout_total}=    Get Order Summary Total Amount
    Should Not Be Equal    ${checkout_total}    ${NONE}
    ...    Checkout grand total must not be null after card selected
    Amounts Should Be Close    ${checkout_total}    ${expected_total}    0.1    checkout total must equal price*1.03
    ${diff_base}=    Evaluate    abs(${checkout_total} - ${price})
    Should Be True    ${diff_base} > 0.5    checkout total must NOT equal base price (card fee +3% missing)
    Log    [card-declined] checkout grand total PASS: ${checkout_total} ≈ ${expected_total}

    # Place order → 2C2P hosted page.
    ${url_segment}=    Place Order And Get Hash
    Log    [card-declined] URL segment after placeOrder(): "${url_segment}"
    Wait For Card Page

    # 2C2P amount must equal expected total and match the checkout total.
    ${observed}=    Get Card Charge Amount
    Should Not Be Equal    ${observed}    ${NONE}    2C2P chargeAmount must not be null
    Amounts Should Be Close    ${observed}    ${expected_total}    0.1    2C2P amount must equal price*1.03
    ${diff_2c2p_base}=    Evaluate    abs(${observed} - ${price})
    Should Be True    ${diff_2c2p_base} > 0.5    2C2P amount must NOT equal base price (card fee missing)
    Amounts Should Be Close    ${observed}    ${checkout_total}    0.1    2C2P amount must match checkout total
    Log    [card-declined] cross-check PASS: 2C2P ${observed} ≈ checkout ${checkout_total}

    # Fill the sandbox declined card and submit.
    Fill Card    ${card}    ${customer}[email]
    Submit Card

    # Wait for the decline redirect, capture a screenshot, assert the outcome.
    Wait Until Url Contains Fragment    /payment/fail/    60
    Wait For Page Settle
    Capture Page Screenshot    ${OUTPUT DIR}/2c2p-card-declined-outcome.png
    ${final_url}=    Get Location
    Log    [card-declined] Final URL after submit: ${final_url}

    # NEGATIVE: must not be a success page. POSITIVE: locked decline heading.
    Should Not Match Regexp    ${final_url}    (?i)thankyou|success
    Assert Card Declined    /payment/fail/    การชำระเงินไม่สำเร็จ
    Log    [card-declined] PASS — decline outcome confirmed. URL: ${final_url}

*** Keywords ***
Setup Card Declined Test
    [Documentation]    beforeEach gates: on PROD require ALLOW_PROD_ORDER and ALLOW_PROD_2C2P.
    IF    '${ENV}' == 'prod'
        IF    not ${ALLOW_PROD_ORDER}
            Skip    PROD order creation is DISABLED. Set ALLOW_PROD_ORDER=true to enable.
        END
        IF    not ${ALLOW_PROD_2C2P}
            Skip    PROD 2C2P card submission is DISABLED. Set ALLOW_PROD_2C2P=true to enable. Verify prod selectors/domain first.
        END
    END
    Open WNW Browser
