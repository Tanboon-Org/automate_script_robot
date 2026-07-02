*** Settings ***
Documentation     TC-XPERF-02 — หน้า PDP มี SEO ครบ: canonical + Open Graph + JSON-LD.
...               Smoke/SEO. ใช้ PDP H014. (บทความ + BreadcrumbList ตรวจแยกที่ TC-CMS-02)
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:seo    group:crosscutting

*** Variables ***
${PDP_PATH}    /พวงหรีด/h014-wnw-บุหลันพราวแสง/

*** Test Cases ***
TC-XPERF-02 PDP carries canonical, Open Graph and JSON-LD
    [Documentation]    P3 — เปิด PDP → มี title/canonical (ไม่ 404) + og:* + JSON-LD.
    [Tags]    TC-XPERF-02
    Assert Content Page Loads    ${PDP_PATH}
    Assert Open Graph Present
    Assert JsonLd Present
