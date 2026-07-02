*** Settings ***
Documentation    Shared test-suite setup/helper keywords used by the per-test-case
...              suites under tests/. Extracted here so each TC lives in its own
...              .robot file without duplicating common setup logic.
...              Pulls in the full POM stack via the single import hub.
Resource         ../imports/app_imports.robot

*** Keywords ***
Open H014 In Cart
    [Documentation]    Add H014 to the cart and land on /cart/. Returns the product dict.
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    RETURN    ${product}

Setup Checkout
    [Documentation]    Add H014 to cart and navigate to /checkout/.
    ${product}=    Load Test Data    product    h014
    Dismiss Cookie
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Proceed To Checkout From Cart

Login As Test User
    [Documentation]    Log in as the verified test user (TD-30) and confirm success → lands on
    ...    /user-infos. Used by the A6/A7 user-infos suites.
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]
    Assert Login Succeeded
    RETURN    ${user}

Setup Checkout Two Pwang
    [Documentation]    Add H014, bump quantity to 2 (→ 2 พวง), reach /checkout/. Used by
    ...    TC-CHK-13 (message-card count rule).
    Open WNW Browser
    Dismiss Cookie
    ${product}=    Load Test Data    product    h014
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Increase Cart Quantity    1
    Sleep    ${TIMEOUTS}[CART_PERSIST]s
    Proceed To Checkout From Cart

Setup Purchase Loop Test
    [Documentation]    beforeEach gate: skip on PROD unless ALLOW_PROD_ORDER=true; then open browser.
    IF    '${ENV}' == 'prod' and not ${ALLOW_PROD_ORDER}
        Skip    PROD order creation is DISABLED. Set ALLOW_PROD_ORDER=true to enable. WARNING: creates real orders.
    END
    Open WNW Browser

Setup Tracking
    [Documentation]    beforeEach: open browser, dismiss cookie, open /tracking/.
    Open WNW Browser
    Dismiss Cookie
    Open Tracking Page

Setup Auth Test
    [Documentation]    beforeEach for Account/Auth suites: open browser at site root and
    ...    dismiss the cookie banner so it never overlaps the auth modal trigger.
    Open WNW Browser
    Dismiss Cookie

# ── Coupon / promotion (TC-PROMO-*) ───────────────────────────────────────────
Skip If Coupon Not Ready
    [Documentation]    Gate a positive coupon case until dev supplies usable data. The valid
    ...    coupon (coupons.json key=valid) is BLOCKED while DISCOUNT10 stays consumed by
    ...    loginUser — flip _status to "ready" and fill expectedDiscount once dev returns a
    ...    fresh code (QA-Coupon-TestData-Request.md §1.1). Skips with a clear reason otherwise.
    [Arguments]    ${coupon}
    IF    "${coupon.get('_status', 'todo')}" != "ready"
        Skip    BLOCKED: ขอ valid coupon (code ที่ loginUser ยังไม่เคยใช้ + expectedDiscount) จาก dev — QA-Coupon-TestData-Request.md §1.1
    END

Prepare Checkout For Coupon
    [Documentation]    Fill the minimum a coupon needs before it can be applied — temple +
    ...    a soonest date/time. The apply button is gated behind a delivery date
    ...    (note "เลือกวันจัดส่งก่อน"), so without this the click is a no-op.
    ${temple}=    Load Test Data    temple    wat_arun_bkk
    Select Temple With Hall    ${temple}
    Pick Delivery Date And Time

Setup Coupon Checkout As Guest
    [Documentation]    beforeEach: open browser, then (guest, NOT logged in) add H014, reach
    ...    /checkout/, ready the coupon field. Used by TC-PROMO-04 — applying any coupon must
    ...    demand login first.
    Open WNW Browser
    Dismiss Cookie
    ${product}=    Load Test Data    product    h014
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    Proceed To Checkout From Cart
    Prepare Checkout For Coupon

Setup Coupon Checkout As Login User
    [Documentation]    beforeEach for login-required coupon cases (02-R/03-R/05/07). Coupons need
    ...    login. NOTE: the guest→login cart merge (synUserCart) is currently BROKEN on staging —
    ...    the guest cart is dropped after login and the server cart comes back empty (verified
    ...    live 2026-07-02, see QA-Dev-Request-Blockers §3). So we log in FIRST and THEN add H014
    ...    directly to the logged-in (server-side) cart, avoiding the merge path entirely. The
    ...    merge itself is the subject of TC-LOGIN-07.
    Open WNW Browser
    Dismiss Cookie
    ${user}=    Load Test Data    user    login
    Login With    ${user}[email]    ${user}[password]
    Assert Login Succeeded
    # login user's cart is server-side and persists across runs — clear it first so coupon
    # min/max cases start from a KNOWN cart (exactly 1×H014 = ฿1,599), not accumulated leftovers.
    Clear Cart
    ${product}=    Load Test Data    product    h014
    Open Product By Data    ${product}
    Add To Cart
    Go To Cart
    # Server-side cart renders after an API round-trip; wait for the "ซื้อทันที" button before
    # clicking (the shared Proceed keyword clicks without waiting).
    Wait Until Any Element Visible    ${CART_CHECKOUT_BUTTON}    ${TIMEOUTS}[NAVIGATION]
    Proceed To Checkout From Cart
    Prepare Checkout For Coupon
