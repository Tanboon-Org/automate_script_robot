*** Settings ***
Documentation     TC-CMS-04 — หน้าบริการ (static) โหลดได้ + title/canonical (SEO smoke).
...               NOTE: ทดสอบเฉพาะ service-funeral + all-service (โหลดได้). เส้นทาง
...               service-crematory / -pet / -relics คืน 404 บน staging → finding (route ไม่ตรง
...               doc) รอ dev ยืนยัน slug จริง.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms
Test Template     Assert Content Page Loads

*** Test Cases ***                 PATH
TC-CMS-04 Service funeral          /service-funeral
TC-CMS-04 All service              /all-service
