*** Settings ***
Documentation     TC-CMS-01 — หน้า listing บทความ (/บทความ) โหลดได้ + มีลิงก์บทความ (smoke).
...               TD-38. NOTE: category filter + pagination 20/หน้า เป็น functional เพิ่มเติม —
...               รอบนี้ทำระดับ smoke (หน้าโหลดจริง ไม่ใช่ 404 + มีการ์ดบทความ).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms

*** Variables ***
${ARTICLE_LISTING}    /บทความ/

*** Test Cases ***
TC-CMS-01 Article listing loads with article links
    [Documentation]    P2 — เปิด /บทความ → หน้าโหลด (มี title/canonical, ไม่ 404) + มีลิงก์บทความ.
    [Tags]    TC-CMS-01
    Assert Content Page Loads    ${ARTICLE_LISTING}
    Assert Listing Has Links    /บทความ/    1
