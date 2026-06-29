*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
nextDeliveryAriaLabel: offsetDays=0 on a Friday → next Saturday
    ${label}=    Next Delivery Aria Label    0    2026-06-19T12:00:00Z
    Should Contain    ${label}    Saturday
    Should Contain    ${label}    June 20th, 2026
