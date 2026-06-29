*** Settings ***
Documentation     Unit test for the date helpers (port of tests/unit/dateHelpers.spec.ts).
...               Pure logic — no browser or network. A fixed `now` makes the assertion
...               deterministic regardless of the runner's timezone.
Library           custom_library.py
Test Tags         feature:unit

*** Test Cases ***
todayAriaLabel: UTC 20:00 on June 17 → Bangkok is June 18 (not June 17)
    ${label}=    Today Aria Label    2026-06-17T20:00:00Z
    Should Contain    ${label}    June 18th, 2026
    Should Not Contain    ${label}    June 17th, 2026
    Should Be Equal    ${label}    Choose Thursday, June 18th, 2026
