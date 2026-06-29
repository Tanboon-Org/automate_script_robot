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
