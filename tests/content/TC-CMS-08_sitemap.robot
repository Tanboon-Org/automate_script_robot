*** Settings ***
Documentation     TC-CMS-08 — /sitemap.xml เป็น XML sitemap ที่ถูกต้อง (sitemapindex + <loc>).
...               Smoke/SEO. ไม่ต้องใช้ test data.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms

*** Test Cases ***
TC-CMS-08 Sitemap index is valid XML
    [Documentation]    P3 — เปิด /sitemap.xml → เป็น sitemapindex/urlset + มี <loc>.
    [Tags]    TC-CMS-08
    Assert Sitemap Xml    /sitemap.xml
