*** Settings ***
Documentation     TC-CHK-12 — POST /api/order ด้วย slug สินค้าที่ไม่มีจริง ต้องถูก reject
...               ด้วยข้อความ "ไม่พบสินค้าตาม slug ... ในตะกร้า" (Rules/ProductSlugExists).
...               BLOCKED (bug): ปัจจุบัน backend คืน 500 "Undefined array key 'count'"
...               (OrderController.php:176) แทนที่จะ reject สวย ๆ → ดู QA-Dev-Request-Blockers §3.8.
...               จะปลดเมื่อ dev แก้ให้เป็น 422 + ข้อความ slug.
Library           api_library.py
Force Tags        feature:api    group:order-api

*** Test Cases ***
TC-CHK-12 Order API rejects an unknown product slug
    [Documentation]    P1 — API Error. BLOCKED รอ dev แก้ 500 → 422 (ProductSlugExists).
    [Tags]    TC-CHK-12    fixme
    Skip    BLOCKED: backend คืน 500 (Undefined array key "count", OrderController.php:176) แทน 422 slug-rule — ดู QA-Dev-Request-Blockers.md §3.8
