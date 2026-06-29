*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
positive-path: todayAriaLabel format is consistent (June 20 is a Saturday)
    ${label}=    Today Aria Label    2026-06-20T10:00:00Z
    Should Match Regexp    ${label}    ^Choose
    Should Match Regexp    ${label}    Choose (Sunday|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday),
    Should Be Equal    ${label}    Choose Saturday, June 20th, 2026
