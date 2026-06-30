*** Settings ***
Documentation     TC-CMS-05 — หน้า info แบบ static โหลดได้ + มี title/canonical (SEO smoke).
...               about-us / how-to-order / faqs / privacy / compensation / flower-shop /
...               review-wreath / contact.
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:content    group:cms
Test Template     Assert Content Page Loads

*** Test Cases ***                 PATH
TC-CMS-05 FAQs                      /faqs/
TC-CMS-05 Contact                  /ติดต่อเรา/
TC-CMS-05 Compensation policy      /นโยบายชดเชย/
TC-CMS-05 Privacy policy           /นโยบายความเป็นส่วนตัว/
TC-CMS-05 How to order             /วิธีสั่งซื้อ/
TC-CMS-05 About us                 /about-us
TC-CMS-05 Flower shop              /flower-shop
TC-CMS-05 Review wreath            /review-wreath
