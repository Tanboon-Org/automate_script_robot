*** Settings ***
Documentation     Checkout shows both payment methods + all bank channels selectable
...               (port of tests/atomic/payment-channels.spec.ts). Creates exactly 1 unpaid
...               order (no notify submit). @createsOrder — gated on PROD via ALLOW_PROD_ORDER.
Resource          ../../resources/imports/app_imports.robot
Test Setup        Setup Payment Channels Test
Test Teardown     Close WNW Browser
Test Tags         feature:payment    createsorder

*** Test Cases ***
TC-PAY-05 Checkout shows both payment methods + all bank channels selectable
    [Tags]    TC-PAY-05
    ${customer}=    Load Test Data    customer    qa_test
    ${recipient}=    Load Test Data    recipient    qa_test
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${payment}=    Load Test Data    payment    qr

    # ── Browse → add to cart ──────────────────────────────────────────────────
    ${product}=    Open Random Product Via Home
    ${price}=    Get PDP Price
    Should Be True    ${price} > 0
    Log    [atomic] สินค้า: ${product}[code] (${product}[name]), ราคา: ${price}
    Add To Cart

    # ── Cart → checkout ───────────────────────────────────────────────────────
    Go To Cart
    Assert Cart Has Item    ${product}[name]    ${price}
    Proceed To Checkout From Cart

    # ── Fill delivery + ribbon + buyer ────────────────────────────────────────
    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA Regression Channels    layout=1    tone=w
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}

    # ── AC3: both payment options visible (before placeOrder) ─────────────────
    Assert All Payment Options Visible
    Log    [atomic] AC3 PASS — both payment options visible on checkout

    # ── Select QR and place order ─────────────────────────────────────────────
    Select Payment By Data    ${payment}
    ${order_hash}=    Place Order And Get Hash
    Should Not Be Empty    ${order_hash}

    # ── Verify payment page reached ───────────────────────────────────────────
    ${order_no}=    Verify Order Created    total_amount=${price}
    Should Match Regexp    ${order_no}    O-\\d+
    Log    [atomic] ออเดอร์ที่สร้าง: ${order_no} (hash: ${order_hash})
    Wait For Notify Form

    # ── AC1: enumerate bank options + assert each selectable (no submit) ───────
    ${bank_options}=    Get Bank Options
    ${count}=    Get Length    ${bank_options}
    Log    [atomic] จำนวนช่องทางธนาคาร: ${count}
    Should Be True    ${count} > 1    Expected >1 bank notification channel, got ${count}
    FOR    ${opt}    IN    @{bank_options}
        Assert Bank Option Selectable    ${opt}[value]
        Log    [atomic] ช่องทาง "${opt}[label]" (value="${opt}[value]") — SELECTABLE
    END
    Log    [atomic] AC1 PASS — ${count} ช่องทางทั้งหมดเลือกได้, ไม่ได้ submit

*** Keywords ***
Setup Payment Channels Test
    [Documentation]    beforeEach gate: skip on PROD unless ALLOW_PROD_ORDER=true; then
    ...    open the browser. This block creates ONE unpaid order on staging.
    IF    '${ENV}' == 'prod' and not ${ALLOW_PROD_ORDER}
        Skip    PROD order creation is DISABLED. Set ALLOW_PROD_ORDER=true to enable.
    END
    Open WNW Browser
