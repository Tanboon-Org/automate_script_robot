# Checklist: Data / Access ที่ต้องขอ Dev เพื่อปลดล็อก Automation

> อัปเดต: 2026-07-02 · Env: staging (`wnw2025-frontend.dev-app-bit.com`)
> สถานะปัจจุบัน: **Script Done 92 / automatable 175 (53%)** · เหลือ 83 (Not Started 61 + Blocked 22)
> เอกสารนี้สรุป "ขอ 1 อย่าง → ปลดได้กี่เคส" เรียงตาม impact เพื่อให้ ping ทีมทีเดียวจบ

---

## A. ต้องขอ Dev (ปลดได้ ~34 เคส)

| # | สิ่งที่ขอ | ปลด | เคสที่เกี่ยว | หมายเหตุ |
|---|---|---|---|---|
| A1 | **Email tokens** — confirm-email (valid/expired/used) + reset-password (valid/expired/used) หรือให้ **access inbox / วิธี generate** | **7** | TC-CFM-01/03/04/05, TC-RST-01/03/05 | ตอนนี้เข้า inbox ไม่ได้ → เปิดลิงก์ยืนยัน/รีเซ็ตไม่ได้ |
| A2 | **Mock/trigger backend errors** — ERP 500/timeout, media-upload fail, 401 (endpoint/feature-flag/toggle) | **5** | TC-API-02, TC-XAPI-02, TC-CARD-07, TC-FGT-02, TC-XSESS-01 | ต้องบังคับ error path บน staging ให้ได้ |
| A3 | **Test user ที่มีออเดอร์** (pending + completed) — `TD-39` | **3** | TC-OH-01/03/04 | inoobeam ไม่มีออเดอร์ → ทดสอบได้แค่ empty state |
| A4 | **Order + tracking data หลายสถานะ** — order_code + tracking_id (status 0/1/2/3/4) + phone/email ที่ค้นได้ — `TD-20/21/22` | **5** | TC-TRK-01a-R/04, TC-TRK2-01/02/03 | ต้องมี order จริงบน staging ให้ค้น |
| A5 | **Coupon เพิ่ม** — (a) amount-type code, (b) campaign code + applicable slug, (c) สินค้าราคาแตะ min/max พอดี **หรือ** ปรับ min/max ของ MINMAXTEST | **3** | TC-PROMO-06/09/10 | ปัจจุบันมีแต่คูปอง %; สินค้าถูกสุด 1,599 แตะ 2000/6000 ไม่ได้ |
| A6 | **ยืนยัน/แก้ บั๊ก** sort, keyword-search, cart-merge (§3.1/3.2/3.9) | **5** | TC-CAT-02-R, TC-DISC-01/03, TC-SRCH-01-R, TC-CART-07 | ถ้ายัง bug อยู่ → เขียนได้แต่จะ fail (เป็น bug-doc) |
| A7 | **Logo test files** — รูป >288px + ไฟล์ non-image (.pdf) — `TD-35` | **2** | TC-CARD-06/08 | แนบไฟล์มาให้ |
| A8 | **Excluded tag** — ตัวอย่าง tag/สินค้า ที่ถูก EXCLUDED_TAGS | **2** | TC-CAT-06, TC-DISC-06 | เพื่อ verify ว่าสินค้า excluded ไม่โผล่ |
| A9 | **locationId `allow_delivery=false`** — §2.6 | **1** | TC-SHIP-01 | |
| A10 | **author slug จริง** — `TD-38` | **1** | TC-CMS-03 | รอบก่อนตอบ "ไม่มีนะ" |

**รวมขอ dev → ปลด ~34 เคส**

---

## B. QA ทำต่อเองได้ (ไม่ต้องรอ dev · ~35 เคส · เก็บด้วย effort/probe)

- **API track (RequestsLibrary/CDP):** TC-CHK-12 (slug 500), TC-CHK-04-API, TC-SEC-01/02, TC-SESS-01/02
- **Message Card interactions:** TC-CARD-01/02/04/09/10/11/12
- **Register ตอน checkout:** TC-AUTH-01-R/03/04/05
- **Security FE:** TC-XSEC-01/02/03/04, TC-SEC-03
- **Checkout/listing:** TC-CHK-08-R (255), TC-CAT-03/04/05-R, TC-DISC-02, TC-CART-05-R, TC-LOAD-01/TC-XPERF-01, TC-LINE-03
- **Auth misc:** TC-CFM-02, TC-RST-02/04, TC-FGT-04
- **Tracking module:** TC-TRK2-05/06

> ⚠️ **deprioritize:** TC-USER-03/04/06/07/11 (ฟอร์มเปราะ + แก้ข้อมูลจริง), TC-CHK-10 (ต้อง mock เวลา), TC-ERR-02/TC-XPERF-03 (manual/responsive)

---

## C. ตัดออกแล้ว (manual — no automation)

- **Payment/2C2P sandbox (13):** TC-PAY-01-R/02-R/03/04/05/06/07/09, TC-ORD-01a-R/01b-R + K-Global 3 → dev ยืนยันไม่มี 2C2P sandbox → **เทสมือ**

---

## D. Checklist สั้นให้ dev กรอก (คัดลอกได้)

```
[ ] A1 email tokens: confirm(valid/expired/used)= __ / reset(valid/expired/used)= __  (หรือ inbox access)
[ ] A2 วิธี trigger error: ERP 500/timeout= __ , media fail= __ , 401= __
[ ] A3 user มีออเดอร์ (pending+completed)= email __  (หรือ set ให้ inoobeam)
[ ] A4 order_code= __ , tracking_id= __ , statuses= 0/1/2/3/4 , lookup phone/email= __
[ ] A5 coupon amount code= __ , campaign code= __ + slug= __ , (min/max ปรับเป็น หรือ สินค้าราคา __ )
[ ] A6 bug §3.1 sort / §3.2 keyword / §3.9 cart-merge : fix? yes/no/known-issue
[ ] A7 logo files: แนบ ใหญ่/non-image
[ ] A8 excluded tag ตัวอย่าง= __ / สินค้าที่ติด tag= __
[ ] A9 locationId allow_delivery=false= __
[ ] A10 author slug= __
```
