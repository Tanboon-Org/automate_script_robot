*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
todayAriaLabel: mid-day UTC (12:00) returns same day in both UTC and Bangkok
    ${label}=    Today Aria Label    2026-06-18T12:00:00Z
    Should Contain    ${label}    June 18th, 2026
    Should Be Equal    ${label}    Choose Thursday, June 18th, 2026
