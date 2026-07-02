# คำขอจาก Dev เพื่อปลดล็อก Test Automation (Wreath Na Wat)

> รวม **ข้อมูลที่ต้องขอ + ฟีเจอร์ที่ต้องยืนยัน + bug/finding ที่เจอจากการรันจริง** บน staging
> Environment: **staging** — `https://wnw2025-frontend.dev-app-bit.com`
> อัปเดต: 2026-06-30 · อ้างอิงสถานะใน `QA-WreathNaWat-Checkout-OrderFlow-TestCases.xlsx` (คอลัมน์ Script Status = `Blocked`)
> รายละเอียดคูปองแบบเต็มดูเพิ่มที่ `QA-Coupon-TestData-Request.md`

ตอนนี้ automate ผ่านแล้ว ~65 เคส (35%) — เคสที่เหลือกลุ่มใหญ่ติดอยู่ที่ของด้านล่าง ถ้าได้ครบจะปลดล็อกได้อีกหลายสิบเคส

---

## 1. Test Data ที่ต้องขอ (สำคัญสุด)

| # | สิ่งที่ขอ | ใช้กับ | รายละเอียด |
|---|---|---|---|
| 1.1 | **`web_user_token`** ของ `champw05w@gmail.com` | ทุกเคส coupon ระดับ API | คูปองต้อง login — มี user/password แล้ว ขาด token |
| 1.2 | **คูปอง valid** ที่ `champw05w` **ยังไม่เคยใช้** | TC-PROMO-01-R / 09 | ตอนนี้ `DISCOUNT10` ถูก user นี้ใช้ไปแล้ว (เป็นเคส "used") → ขอโค้ดใหม่ที่ยังไม่ถูกใช้ + บอกช่วงยอด min/max + ชนิดส่วนลด (บาท/%) |
| 1.3 | **คูปองหมดอายุจริง** (`codeExpired`) | TC-PROMO-02-R (expired) | `WD12` ที่ให้มา **ไม่ reject** บน staging (กดแล้วเงียบ ส่วนลด ฿0 ไม่มี error) → ขอโค้ดที่หมดอายุจริง |
| 1.4 | **คูปอง min/max** ที่ตั้งค่า ≤ ยอดที่จัดได้ | TC-PROMO-05 / 06 | สินค้าถูกสุด ~฿1,599 แต่ `MINMAXTEST` min=1,000 → จัดยอด < min ไม่ได้ ขอ min ที่ทดสอบ boundary ได้ (เช่น min 2,000 / max 3,000) |
| 1.5 | **user ที่มีออเดอร์** (pending + completed) — `TD-39` | TC-OH-01 / 03 / 04 | `champw05w` ไม่มีออเดอร์เลย → empty state เท่านั้นที่ทดสอบได้ ขอ user (หรือ set ออเดอร์ให้) เพื่อทดสอบ "ประวัติออเดอร์ + copy เลขออเดอร์" |
| 1.6 | **article slug + author slug จริง** — `TD-38` | TC-CMS-01 / 02 / 03 | ทดสอบหน้า `/บทความ/[slug]`, `/ผู้เขียน/[slug]` + JSON-LD |
| 1.7 | **ไฟล์โลโก้ทดสอบ** — `TD-35` | TC-CARD-06 / 07 / 08 | รูป >288px (ใหญ่เกิน), รูปปกติ, ไฟล์ non-image (.pdf) สำหรับทดสอบ upload โลโก้ป้าย |
| 1.8 | **slug สินค้าที่ `allow_add_to_cart=false`** — `TD-04` | TC-DISC-07 / TC-PDP-05 | slug `b301-wnw-วลิลา-01-16` ที่ให้มา **ยังมีปุ่มซื้อ** (สั่งได้) → ขอ slug ที่ปิดการขายจริง (ต้องซ่อน Buy Now + แสดงปุ่ม LINE) |
| 1.9 | **user ที่ยังไม่ยืนยันอีเมล** — `TD-31` | TC-LOGIN-04 | ยังเป็น `<<ask-dev>>` |

---

## 2. ฟีเจอร์ / Config ที่ต้องยืนยัน

| # | เรื่อง | คำถามถึง dev | กระทบเคส |
|---|---|---|---|
| 2.1 | **เปลี่ยนรหัสผ่าน** ใน `/user-infos` | build staging ปัจจุบัน **ไม่มีปุ่ม/ฟอร์ม "เปลี่ยนรหัสผ่าน"** (มีแต่ปุ่ม "แก้ไข") — เปิดใช้ที่ไหน/ยังไง? | TC-USER-08/09/10 |
| 2.2 | **service routes** | `/service-crematory`, `/service-pet`, `/service-relics` คืน **404** (ส่วน `/service-funeral`, `/all-service` ปกติ) — slug ที่ถูกคืออะไร? | TC-CMS-04 |
| 2.3 | **bank_id → payment.type mapping** | comment ในโค้ดสลับชวนสับสน (ดู testdata `payment.bankIdMapping._warning`) ขอ mapping จริง | TC-PAY-06 |
| 2.4 | **2C2P sandbox** | merchant_id / secret_key / เลขบัตรทดสอบ (sandbox) | TC-PAY-10 / TC-ORD (2c2p) |
| 2.5 | **tracking microservice** | endpoint/spec ของ `/track-order` (อยู่นอก repo) | TC-TRK กลุ่ม |    https://tracking-all-2023.dev-app-bit.com/api/track-order Parameters ที่ส่งไป (จาก ITrackOrder):

Field	คำอธิบาย
tracking_id
Tracking ID
order_code
รหัสคำสั่งซื้อ
phone_or_email_address
เบอร์โทรหรืออีเมล
user_agent
User-Agent จาก request header
| 2.6 | **location `allow_delivery=false`** | locationId ตัวอย่างที่ตั้ง allow_delivery=false | TC-SHIP-01 |

---

## 3. Bug / Finding ที่เจอจากการรันจริง (ขอให้ตรวจ/ยืนยัน)

| # | อาการที่เจอบน staging | คาดหวัง | จุดที่เกี่ยว |
|---|---|---|---|
| 3.1 | **Sort ไม่ทำงาน/ไม่สะท้อน URL** — เลือก "ราคา (ต่ำ-สูง)" แล้ว URL ได้แค่ `?page=1` ไม่มี `sort=` และลำดับสินค้าไม่เปลี่ยน | URL/query → `recommend`/`price` + ลำดับเปลี่ยน | listing `filter.ts` |
| 3.2 | **Search `?keyword=` ไม่กรองผล** — เปิด `?keyword=บุหลัน` ได้ผลเท่าเดิม (15 ชิ้น) | กรองตาม keyword | `products/page.tsx` |
| 3.3 | **Filter sidebar** — ไม่มี checkbox มาตรฐาน (ตรวจไม่เจอ control) คาดว่าไม่ reflect URL เหมือน sort | tag_ids_operand and/or ใน URL | listing filter |
| 3.4 | **`/wreath-donate/` โชว์ "ไม่พบหน้า"** เมื่อไม่มีสินค้า tag บริจาค (render ไม่นิ่ง) | empty-state ไม่ใช่ 404 | wreath-donate |
| 3.5 | **forget-password ไม่กันกดซ้ำจริง** — ปุ่มเปลี่ยน text เป็น "กำลังดำเนินการ" แต่ `disabled=false` | ปุ่มควร disable ระหว่างส่ง | `forget-password/page.tsx` |
| 3.6 | **(typo?)** ปุ่มตอนส่ง forget-password ขึ้นข้อความ **"กำลังดดำเนินการ"** (มี ด ซ้ำ) | "กำลังดำเนินการ" | เดียวกัน |
| 3.7 | **NotFound markup ติดมาใน HTML ทุกหน้า** (ซ่อนอยู่) — ทำให้เช็ค 404 จาก page source ไม่ได้ ต้องใช้ visible text | (ไม่ใช่ bug ร้ายแรง แต่กระทบ SEO/test) ยืนยันว่าตั้งใจ | dynamic router |
| 3.8 | **🔴 `POST /api/order` crash 500** — ส่ง cart ที่ slug ไม่มีจริง/ไม่มี field `count` → ได้ `500 {"message":"Undefined array key \"count\"","file":"OrderController.php","line":176}` แทนที่จะ reject สวย ๆ ด้วย "ไม่พบสินค้าตาม slug..." | ควรเป็น 422 + ข้อความ slug rule (ProductSlugExists) ไม่ใช่ PHP 500 | `OrderController.php:176`, `Rules/ProductSlugExists.php` (TC-CHK-12) |
| 3.9 | **🔴 guest→login cart merge พัง** — เพิ่มสินค้าตอนเป็น guest แล้ว login (champw05w) → ตะกร้า**ว่าง** ("ไม่มีสินค้า") สินค้าที่เพิ่งเพิ่มหายหมด (verify ด้วย Selenium 2026-07-02: login สำเร็จแต่ cart empty). กระทบ TC-PROMO-02-R/03-R/05/07 + **TC-LOGIN-07** (เคสที่เทสต์ merge โดยตรง). Workaround ใน automate: setup coupon เปลี่ยนเป็น login-ก่อน-แล้วค่อย-add (เลี่ยง merge) | guest cart ต้อง merge เข้า user cart ตอน login | `synUserCart` (TC-LOGIN-07) |

---

## 4. Checklist สำหรับ Dev (คัดลอกตอบกลับได้)

```
[ ] web_user_token (champw05w@gmail.com) = 1295|KoaWKNaRsZgj1jJfIhQzym29rNRE7pLoKTLlcrzd95aa314a
[ ] coupon valid (ยังไม่ถูกใช้)           = TESTDISCOUNNT01  (min–max 1000–ไม่มีกำหนด, ส่วนลด 10%)
[ ] coupon expired (reject จริง)          = TESTEXPIRE01
[ ] coupon min/max (min ≤ ยอดที่จัดได้)   = MINMAXTEST  (min 2000 / max 6000)
[ ] user ที่มีออเดอร์ (TD-39)             =  set orders ให้ yes
[ ] article slug / author slug (TD-38)    = https://wnw2025-frontend.dev-app-bit.com/%E0%B8%9A%E0%B8%97%E0%B8%84%E0%B8%A7%E0%B8%B2%E0%B8%A1/%E0%B8%A3%E0%B8%B9%E0%B9%89%E0%B8%A5%E0%B8%B6%E0%B8%81%E0%B9%80%E0%B8%A3%E0%B8%B7%E0%B9%88%E0%B8%AD%E0%B8%87%E0%B8%9E%E0%B8%A7%E0%B8%87%E0%B8%AB%E0%B8%A3%E0%B8%B5%E0%B8%94/%E0%B8%84%E0%B8%B3%E0%B9%84%E0%B8%A7%E0%B9%89%E0%B8%AD%E0%B8%B2%E0%B8%A5%E0%B8%B1%E0%B8%A2-%E0%B8%AA%E0%B8%B3%E0%B8%AB%E0%B8%A3%E0%B8%B1%E0%B8%9A%E0%B8%9E%E0%B8%A7%E0%B8%87%E0%B8%AB%E0%B8%A3%E0%B8%B5%E0%B8%94/ /ไม่มีนะ
[ ] โลโก้ทดสอบ (TD-35)                     = แนบไฟล์ ใหญ่/ปกติ/non-image
[ ] slug สินค้า allow_add_to_cart=false   = d040-wnw-ดอนญ่ารำลึก
[ ] unverified user (TD-31)               = email testsuer@gmail.com / pass 123456789_Sno
[ ] เปลี่ยนรหัสผ่านใน /user-infos เปิดยังไง = ต้องส่งรหัสยืนยันเข้า email จาก https://wnw2025-frontend.dev-app-bit.com/forget-password/
[ ] bank_id→type mapping / 2C2P sandbox   = ตอนนี้ระบบไม่รองรับการใช้ card test ข้ามไปก่อน
ยืนยัน bug (3.x):
[ ] sort ควร reflect URL + เรียงจริง?           yes / no / known-issue
[ ] keyword search ควรกรอง?                      yes / no / known-issue
[ ] /wreath-donate ตอนว่างควรเป็น empty ไม่ใช่ 404?  yes / no
[ ] forget-password ควร disable ปุ่มกันกดซ้ำ?    yes / no
[ ] typo "กำลังดดำเนินการ"                        จะแก้ yes / no
```

---

## 5. สิ่งที่ QA จะทำต่อเอง (ไม่ต้องรอ dev)

- เปิด **API track** (RequestsLibrary/CDP) → TC-CHK-12 (slug invalid), TC-API error mock, attachments payload, session 401
- เก็บกลุ่ม UI ที่เหลือ: **H. LINE/B2B redirect**, **J. Contact/Corporate**, **TC-XSEC-04** (XSS/SQLi), **CMS-06/08** (router/sitemap)
- **message-card preview** ทดสอบบน headless ไม่ขึ้น (888ms debounce/base64) — จะลองโหมด headed หรือเพิ่ม wait
- **mobile viewport** (hamburger, sticky bar) — ตั้ง window size mobile แล้ว probe selector
