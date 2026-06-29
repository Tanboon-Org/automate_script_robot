*** Settings ***
Documentation     Full purchase loop (port of tests/e2e/purchase-loop.spec.ts).
...               Browse → add to cart → checkout → order created → payment page asserted
...               → notify payment (TEST slip) → Order Success → track.
...               @createsOrder — SKIPPED on PROD unless ALLOW_PROD_ORDER=true.
...               NO funds move: suite stops at content assertions; slip is a TEST image;
...               buyer/recipient names carry the "TEST" keyword.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Purchase Loop Test
Test Teardown     Close WNW Browser
Test Tags         feature:payment    createsorder

*** Test Cases ***
TC-PAY Full loop: order → payment → notify payment → order success → track
    [Tags]    TC-CHK-10    TC-PAY-01    TC-PAY-02    TC-PAY-04    TC-TRK-01
    ${customer}=    Load Test Data    customer    qa_test
    ${recipient}=    Load Test Data    recipient    qa_test
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    ${payment}=    Load Test Data    payment    qr

    ${product}=    Open Random Product Via Home
    ${price}=    Get PDP Price
    Should Be True    ${price} > 0
    Log    [e2e] ราคาที่อ่านจากหน้าสินค้า ${product}[code]: ${price}
    Add To Cart

    Go To Cart
    Assert Cart Has Item    ${product}[name]    ${price}
    Proceed To Checkout From Cart

    ${ribbon}=    Create Dictionary    line1=TEST QA อย่าจัดส่ง    line2=QA Regression Prod    layout=1    tone=w
    Fill Delivery And Buyer    ${temple}    ${recipient}    ${customer}    ${ribbon}

    Select Payment By Data    ${payment}
    ${order_hash}=    Place Order And Get Hash
    Should Not Be Empty    ${order_hash}

    ${order_no}=    Verify Order Created    total_amount=${price}
    Should Match Regexp    ${order_no}    O-\\d+
    Current Url Should Contain    /payment/

    # Notify payment + upload TEST slip → /payment/thankyou/ (Order Success). No real transfer.
    ${slip}=    Evaluate    os.path.abspath(r"${CURDIR}/../../resources/variables/test_data/slip-test.png")    modules=os
    Notify Payment    ${slip}    กสิกร    ${price}    10:00    ${order_no}

    # Track the just-created order by its number + entered phone → status page loads.
    Track Order    ${order_no}    ${customer}[phone]
    Assert Tracking Result Loaded
