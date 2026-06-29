*** Settings ***
Documentation     Track by order code + phone shows order status
...               (port of tests/atomic/tracking.spec.ts). PROD-only known order.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Setup Tracking
Test Teardown     Close WNW Browser
Test Tags         feature:tracking

*** Test Cases ***
TC-TRK-01 Track by order code + phone shows order status
    [Documentation]    P1 — uses the PROD test order O-0000291286 (valid only on PROD).
    [Tags]    TC-TRK-01
    ${customer}=    Load Test Data    customer    qa_test
    IF    '${ENV}' == 'prod'
        Track By Order Code    O-0000291286    ${customer}[phone]
        Assert Tracking Status Visible    ${MESSAGES}[ORDER_UNPAID_STATUS]
    ELSE
        Skip    TC-TRK-01 on staging requires a known order. Set ENV=prod for PROD order tracking.
    END
