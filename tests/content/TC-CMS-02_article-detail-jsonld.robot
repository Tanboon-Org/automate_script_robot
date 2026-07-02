*** Settings ***
Documentation     TC-CMS-02 — หน้า article detail render เนื้อหา + ฝัง JSON-LD BreadcrumbList.
...               Smoke. TD-38 (dev ให้ article slug จริง). Route: /บทความ/[category]/[slug].
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms

*** Variables ***
# dev-provided article (TD-38): /บทความ/รู้ลึกเรื่องพวงหรีด/คำไว้อาลัย-สำหรับพวงหรีด/
${ARTICLE_DETAIL}    /บทความ/รู้ลึกเรื่องพวงหรีด/คำไว้อาลัย-สำหรับพวงหรีด/

*** Test Cases ***
TC-CMS-02 Article detail renders content and JSON-LD breadcrumb
    [Documentation]    P3 — เปิดบทความจริง → หน้าโหลด (ไม่ 404, มี title/canonical) + JSON-LD.
    [Tags]    TC-CMS-02
    Assert Content Page Loads    ${ARTICLE_DETAIL}
    Assert JsonLd Breadcrumb Present
