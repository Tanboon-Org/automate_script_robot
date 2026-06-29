*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
nextDeliveryAriaLabel: returns a Saturday at least 4 days after Bangkok date
    ${label}=    Next Delivery Aria Label    4    2026-06-17T20:00:00Z
    Should Contain    ${label}    Saturday
    Should Contain    ${label}    June 27th, 2026
    Should Be Equal    ${label}    Choose Saturday, June 27th, 2026
