*** Settings ***
Documentation     TC-CMS-06 — dynamic [...slug] router route ไปหน้าถูก + decode Thai URL ได้.
...               Smoke: เปิด slug ภาษาไทยหลายแบบผ่าน [...slug] switch → โหลดเป็นหน้าจริง
...               (ไม่ใช่ 404) + มี title/canonical. slug มั่ว→404 ทดสอบแยกที่ TC-CMS-07.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms
Test Template     Assert Content Page Loads

*** Test Cases ***
TC-CMS-06 How-to-order (Thai slug)
    /วิธีสั่งซื้อ/

TC-CMS-06 Privacy policy (Thai slug)
    /นโยบายความเป็นส่วนตัว/

TC-CMS-06 Compensation policy (Thai slug)
    /นโยบายชดเชย/

TC-CMS-06 Contact (Thai slug)
    /ติดต่อเรา/
