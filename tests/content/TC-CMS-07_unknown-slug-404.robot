*** Settings ***
Documentation     TC-CMS-07 — slug ที่ไม่มีจริง → หน้า NotfoundPage ("ไม่พบหน้า").
...               Negative. ทดสอบ dynamic router fallback.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms

*** Test Cases ***
TC-CMS-07 Unknown content slug shows the 404 page
    [Documentation]    P2 — Negative. เปิด slug มั่ว → "ไม่พบหน้า".
    [Tags]    TC-CMS-07
    Dismiss Cookie
    Go To Absolute    ${BASE_URL}/this-slug-does-not-exist-xyz
    # ใช้ visible text — markup NotFound ติดมาใน HTML ทุกหน้า การเช็ค source จะผ่านปลอม
    Wait Until Keyword Succeeds    ${TIMEOUTS}[DEFAULT]s    0.5s    Not Found Marker Should Be Visible
