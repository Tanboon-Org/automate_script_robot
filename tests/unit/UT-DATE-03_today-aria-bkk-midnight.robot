*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
todayAriaLabel: Bangkok midnight boundary (17:00 UTC = 00:00 Bangkok next day)
    ${label}=    Today Aria Label    2026-06-17T17:00:00Z
    Should Contain    ${label}    June 18th, 2026
    Should Not Contain    ${label}    June 17th
