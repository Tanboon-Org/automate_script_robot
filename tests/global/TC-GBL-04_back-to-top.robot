*** Settings ***
Documentation     TC-GBL-04 — ปุ่ม Back to top: เลื่อนลงแล้วกด → กลับขึ้นบนสุด.
...               Functional. ปุ่มเป็น icon fixed (bottom-20 right-6) ไม่มี text.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:global    group:footer

*** Test Cases ***
TC-GBL-04 Back-to-top scrolls the page to the top
    [Documentation]    P3 — Functional. scroll ลง → ปุ่มโผล่ → คลิก → scrollY กลับ ~0.
    [Tags]    TC-GBL-04
    Dismiss Cookie
    Execute Javascript    window.scrollTo(0, 5000);
    Wait Until Element Is Visible    ${BACK_TO_TOP_BTN}    ${TIMEOUTS}[DEFAULT]
    Click Element    ${BACK_TO_TOP_BTN}
    Sleep    ${TIMEOUTS}[ANIMATION]s
    ${y}=    Execute Javascript    return Math.round(window.pageYOffset);
    Should Be True    ${y} < 200    คลิก back-to-top แล้วควรเลื่อนกลับบนสุด แต่ scrollY=${y}
