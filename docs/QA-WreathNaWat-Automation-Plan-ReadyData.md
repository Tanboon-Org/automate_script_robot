# แผนงาน Automation Script — เฉพาะ Test Case ที่ Test Data พร้อมแล้ว
## ระบบ: หรีด ณ วัด (Wreath Na Wat) — Checkout / Order Flow

---

## 1. ข้อมูลเอกสาร

| Field | Value |
|---|---|
| Project | Wreath Na Wat (หรีด ณ วัด) |
| ขอบเขต | Automate **เฉพาะ** Test Case ที่ test data พร้อม (status `ready`) |
| อ้างอิง Test Case | `QA-WreathNaWat-Checkout-OrderFlow-Final-TestCases.md` (75 เคส) |
| อ้างอิง Test Data | `automation/test-data/*.json` + `wnw-checkout-orderflow.testdata.json` |
| Framework | Playwright + TypeScript (POM + fixtures + dataLoader เดิม) |
| Environment | Dev/Test (`wnw2025-frontend.dev-app-bit.com`) — **ห้าม payment จริง** |
| Date | 2026-06-25 |

---

## 2. หลักการ (Ground Rules)

1. **ทำเฉพาะเคสที่ data พร้อม** — เคสที่ data เป็น `todo` / `<<ask-dev>>` จะ **ไม่ทำในรอบนี้** (อยู่ใน §6 รายการ Blocked)
2. **ใช้ของเดิมให้มากที่สุด** — POM ใน `automation/pages/`, fixtures `automation/fixtures/test.ts`, `dataLoader`, helpers, constants
3. **Data-driven** — อ่านค่าจาก `test-data/*.json` เท่านั้น ห้าม hardcode ใน spec (ตาม convention เดิม)
4. **Payment safety gate** — ทุกเคส payment หยุดก่อนยืนยันจริง (ตรวจหน้า/redirect/ยอด เท่านั้น) ตาม TC-PAY-03
5. **Mapping เลข TC** — spec เดิมใช้เลขเก่า (TC-CHK-01..10 ไม่มี `-R`) ต้อง **re-align ให้ตรงเลขชุด Final** (`-R`, `-UI`, `-API`) ก่อนเขียนเพิ่ม
6. ระบุ `TC-ID` ใน `test()` title ทุกเคส เพื่อ trace กลับ Excel `checkout` sheet

---

## 3. สรุปขอบเขตรอบนี้

| สถานะ | จำนวน | หมายเหตุ |
|---|---|---|
| ✅ **READY — ทำรอบนี้** | **41 เคส** | data ครบ ทำได้ทันที |
| ⚠️ **READY-with-caveat** | 8 เคส | ทำได้ แต่ต้องยืนยัน 1 จุด (env%/mapping/login) ก่อน assert ค่าตายตัว |
| ⛔ **BLOCKED — ข้ามรอบนี้** | 26 เคส | รอ dev (คูปอง / location / 2c2p / tracking spec / สินค้าสั่งไม่ได้) |

---

## 4. รายการ READY — ทำได้ทันที (41 เคส)

### Phase 1 — Discovery & Cart (foundation, ทำก่อน)

| TC-ID | ทำอะไร | Spec ปลายทาง | POM/Helper | Data ที่ใช้ |
|---|---|---|---|---|
| TC-HOME-01-R | เมนูหมวด → listing ตรง slug | `tests/atomic/home.spec.ts` | HomePage, CategoryPage | categories.json |
| TC-CAT-01-R | listing render รูป/ชื่อ/ราคา | `tests/atomic/category.spec.ts` | CategoryPage | categories, products |
| TC-CAT-02-R | sort ช่วงราคา/แนะนำ (URL param) | category.spec.ts | CategoryPage | categories |
| TC-CAT-03 | filter + ล้างตัวกรอง | category.spec.ts | CategoryPage | categories |
| TC-CAT-04 | pagination หน้า 1/ถัดไป/สุดท้าย | category.spec.ts | CategoryPage | categories |
| TC-CAT-05-R | empty result state | category.spec.ts | CategoryPage | filter combo (qa) |
| TC-PDP-01-R | PDP แสดงข้อมูลตรง listing | `tests/atomic/product.spec.ts` | ProductPage | products.json |
| TC-PDP-02 | Add to Cart → ตัวนับ+cart | product.spec.ts | ProductPage, CartPage | h016/h015 |
| TC-PDP-03-R | Buy Now → sessionStorage → /checkout | product.spec.ts | ProductPage | h015 |
| TC-CART-01 | empty cart state | `tests/atomic/cart.spec.ts` | CartPage | — |
| TC-CART-02-R | เพิ่ม/ลดจำนวน → ยอดรวม | cart.spec.ts | CartPage | products |
| TC-CART-02b-R | ลดถึง 0 → ลบ + toast | cart.spec.ts | CartPage | products |
| TC-CART-03-R | persist guest (localStorage) | cart.spec.ts | CartPage | products |
| TC-CART-04 | ไป Checkout พร้อมสรุปยอด | cart.spec.ts | CartPage, CheckoutPage | products |
| TC-CART-05-R | วัดต่างจังหวัด → disable + modal LINE | cart.spec.ts | CheckoutPage | temples:out_of_province |
| TC-CART-06 | เกิน 10 ชิ้น → modal limit | cart.spec.ts | CartPage | qty 9/10/11 |

### Phase 2 — Checkout validation & rules (core)

| TC-ID | ทำอะไร | Spec ปลายทาง | POM/Helper | Data ที่ใช้ |
|---|---|---|---|---|
| TC-CHK-01-R | happy path เต็ม (method 1, หยุดก่อนจ่าย) | `tests/atomic/checkout.spec.ts` + `tests/e2e/purchase-loop.spec.ts` | CheckoutPage, checkoutFlow | products, temple in-area, customer, recipient |
| TC-CHK-02-R | required ว่าง (parameterize ทีละช่อง) | checkout.spec.ts | CheckoutPage | happyPath - field |
| TC-CHK-03 | email valid/invalid (parameterize) | checkout.spec.ts | CheckoutPage | emailFormats |
| TC-CHK-04-UI | phone FE `^0\d{9}$` | checkout.spec.ts | CheckoutPage | phoneFormats |
| TC-CHK-04-API | phone BE รับ +66/เบอร์บ้าน (POST ตรง) | `tests/atomic/checkout-api.spec.ts` (ใหม่) | request fixture | phoneFormats |
| TC-CHK-05-UI | consent ไม่ติ๊ก → block | checkout.spec.ts | CheckoutPage | — |
| TC-CHK-06-R | คำนวณยอด (subtotal+ส่ง, **ไม่มีคูปอง**) | checkout.spec.ts | CheckoutPage | 2 สินค้า, temple in-area |
| TC-CHK-08-R | boundary ข้อความ 255/256/emoji/trim | checkout.spec.ts | CheckoutPage | textBoundary |
| TC-PDP-04-R | ริบบิ้น/message card ที่ Checkout | checkout.spec.ts | CheckoutPage (MessageCardModal) | ribbonMessage1/2 |
| TC-CHK-09 | delivery อดีต → reject | checkout.spec.ts | CheckoutPage | deliveryDateTimeBoundary.past |
| TC-CHK-10 | delivery <4ชม / =4ชม (parameterize) | checkout.spec.ts | CheckoutPage | within3h/exact4h |
| TC-CHK-11 | delivery >30วัน (parameterize) | checkout.spec.ts | CheckoutPage | day30/day31 |
| TC-CHK-12 | slug ไม่มีจริง → reject (POST) | checkout-api.spec.ts | request fixture | invalidSlug |
| TC-CHK-13 | ป้ายน้อยกว่าจำนวน → reject | checkout.spec.ts | CheckoutPage | messageCardMismatch |
| TC-EMPTY-01 | /checkout ตะกร้าว่าง → ไม่ crash | checkout.spec.ts | CheckoutPage | — |
| TC-LOAD-01 | double submit → block ครั้งที่ 2 | checkout.spec.ts | CheckoutPage | happyPath |
| TC-PROMO-04 | guest ใส่คูปอง → "ต้องล็อกอินก่อน" | checkout.spec.ts | CheckoutPage | guest + code ใดก็ได้ |

### Phase 3 — Payment (หยุดก่อนจ่ายจริง) & Tracking

| TC-ID | ทำอะไร | Spec ปลายทาง | POM/Helper | Data ที่ใช้ |
|---|---|---|---|---|
| TC-PAY-03 | safety gate — ไม่มี transaction จริง | `tests/atomic/payment-channels.spec.ts` | PaymentPage | — |
| TC-PAY-05 | สลิปบังคับ (POST ไม่แนบ media_id → reject) | `tests/atomic/payment-api.spec.ts` (ใหม่) | request fixture | order pending (trackingId จริง) |
| TC-PAY-07 | status_payment โอน=1/บัตร=2 | payment-api.spec.ts | request fixture | order pending |
| TC-PAY-09 | transfer date/time format ผิด → reject | payment-api.spec.ts | request fixture | transferInfo.invalidFormat |
| TC-TRK-03 | tracking id ปลอม → notFound (ไม่ leak) | `tests/atomic/tracking.spec.ts` | TrackingPage | invalid trackingId |
| TC-TRK-04 | branch status_payment (0/1 vs 2-4) | tracking.spec.ts | TrackingPage | orders.pending + paid (จริง) |

### Phase 4 — Cross-cutting (API error / session / security)

| TC-ID | ทำอะไร | Spec ปลายทาง | POM/Helper | Data ที่ใช้ |
|---|---|---|---|---|
| TC-SEC-01 | consent bypass BE (POST ไม่มี consent → ผ่าน = risk) | `tests/regression/security.spec.ts` (ใหม่) | request fixture | order payload |
| TC-SEC-02 | phone bypass FE (= CHK-04-API) | security.spec.ts | request fixture | phoneFormats |
| TC-SEC-03 | XSS/SQLi ในป้าย/ศาลา → ไม่ execute/ไม่ 500 | security.spec.ts | request fixture | securityPayloads |
| TC-API-01 | ERP 422 → openErrorModal | `tests/atomic/api-error.spec.ts` (ใหม่) | page.route | mockApi.erp422 |
| TC-API-02 | ERP 500/timeout → modal ไม่ crash | api-error.spec.ts | page.route | mockApi.erp500/timeout |
| TC-SESS-01 | 401 → clearStorage + reload | api-error.spec.ts | page.route | mockApi.unauthorized401 |
| TC-SESS-02 | cleanup messageCard keys หลังลบ/สั่งสำเร็จ | checkout.spec.ts | CheckoutPage | — |
| TC-ERR-01 | 404 page + ลิงก์กลับ | `tests/atomic/home.spec.ts` | BasePage | — |

> รวม **41 เคส** (ตัวเลขในตารางด้านบน) — ทำได้โดยไม่ต้องรอ dev

---

## 5. รายการ READY-with-caveat (8 เคส) — ทำได้ แต่ยืนยัน 1 จุดก่อน

| TC-ID | ทำได้แค่ไหน | จุดที่ต้องยืนยันก่อน assert | Spec |
|---|---|---|---|
| TC-PAY-02-R | คำนวณ/แสดง fee บัตรได้ | ค่า `CREDIT_CARD_SERVICE_FEE_PERCENTAGE` จริง (data ใส่ "3" ไว้ — RSK-06) | payment-channels.spec.ts |
| TC-PAY-04 | fee = total×env% | เหมือน 02-R (ยืนยัน env%) | payment-channels.spec.ts |
| TC-PAY-06 | map bank_id → payment.type | mapping ใน data มี `_warning` "comment code สลับ" — ยืนยัน dev | payment-api.spec.ts |
| TC-PAY-10 | 2c2p fail ผ่านบัตร declined | ใช้ `cards.json:declined_non3ds` (มีอยู่) แต่ confirm ว่าเป็น sandbox | regression/2c2p-card-declined.spec.ts (มีแล้ว) |
| TC-CART-07 | guest→login sync cart | login ผ่าน UI ใช้ `loginUser` email/pass (webUserToken ยัง ask-dev แต่ UI ไม่ต้องใช้) | cart.spec.ts |
| TC-AUTH-01-R | สมัครตอน checkout + สร้าง order | จะสร้าง order จริงบน staging — ใช้ email gen ใหม่ + gate | checkout-api.spec.ts |
| TC-AUTH-03 | email ซ้ำ → reject | ใช้ `existingEmailForDuplicate` (ready) — ยืนยันว่ายังมีในระบบ | checkout-api.spec.ts |
| TC-AUTH-05 | password สั้น → reject | data inline พร้อม | checkout-api.spec.ts |

> ถ้ายืนยันค่าตามคอลัมน์กลางได้ครบ → ย้ายขึ้นเป็น READY ทันที (รวมเป็น 49 เคส)

---

## 6. รายการ BLOCKED — ข้ามรอบนี้ (26 เคส) + เหตุผล

| กลุ่ม | TC-ID | ติดอะไร (รอ dev) |
|---|---|---|
| Coupon | TC-PROMO-01-R / 02-R / 03-R / 05 / 06 / 07 / 09 / 10 | คูปองทุกชนิด `todo` + `loginUser.webUserToken` = `<<ask-dev>>` |
| Shipping | TC-SHIP-01 | location `allow_delivery=false` = `<<ask-dev>>` |
| PDP | TC-PDP-05 | สินค้า `allow_add_to_cart=false` slug ยัง `todo` (ซ้ำ B301) |
| Payment | TC-PAY-01-R | ต้อง 2c2p/slip flow + order — slip มี แต่ขอ confirm end-to-end sandbox |
| Order | TC-ORD-01a-R / 01b-R | ต้องสร้าง order สำเร็จ + ตรวจเมล (mail server เข้าไม่ถึงจาก automation) |
| Tracking | TC-TRK-01a-R / 02 | microservice `/track-order` อยู่นอก repo — ต้องขอ spec/endpoint |
| Search | TC-SRCH-01-R | ยังไม่ยืนยันกล่อง UI (BE รองรับ keyword) — ต้อง execute ยืนยันก่อน (RSK-05) |
| Category | TC-CAT-06 | ต้องมีหมวดที่มี `EXCLUDED_TAGS` จริง — ขอ category ตัวอย่าง |
| Auth | TC-AUTH-04 | doc ระบุต้องมี token ปลอม + `coupon_code` — ผูกกับ coupon (todo) |
| Manual | TC-HOME-02 / TC-ERR-02 | Manual Exploratory (responsive/banner) — ทำ smoke ได้แต่จัดเป็น manual |

> เมื่อ dev ส่ง: คูปอง 7 ชนิด + webUserToken + location allow_delivery=false + 2c2p sandbox + tracking spec + env values → ปลดล็อก 26 เคสนี้ในรอบถัดไป

---

## 7. งานโครงสร้างที่ต้องเตรียม (ก่อน/ระหว่างเขียน spec)

1. **Re-align เลข TC เดิม** ใน spec ปัจจุบัน (atomic/*) ให้ตรงชุด Final (`-R/-UI/-API`)
2. **เพิ่ม spec ไฟล์ใหม่:**
   - `tests/atomic/checkout-api.spec.ts` (API-level: CHK-04-API, CHK-12, AUTH-01/03/05)
   - `tests/atomic/payment-api.spec.ts` (PAY-05/06/07/09)
   - `tests/atomic/api-error.spec.ts` (API-01/02, SESS-01)
   - `tests/regression/security.spec.ts` (SEC-01/02/03)
3. **เติม key ใน test-data JSON** ที่ spec ใหม่จะใช้ (ทำให้ตรง interface `dataLoader`):
   - products: เพิ่ม `h016` (data หลักใช้ H016) ให้ตรง `wnw-checkout-orderflow.testdata.json`
   - temples: เพิ่ม in-area `วัดประยุรวงศาวาส (65938)` ให้ตรง testdata หลัก
   - เพิ่มไฟล์/section: phone/email/text boundary, mockApi scenarios, securityPayloads (ปัจจุบันอยู่ใน testdata รวม — ย้าย/wire เข้า dataLoader)
4. **แก้ data 2 จุดที่ค้างจากรอบก่อน:**
   - slip path ใน testdata ชี้ `./fixtures/files/slip-sample.jpg` แต่ไฟล์จริง = `test-data/slip-test.png` → แก้ให้ตรง
   - รวม `coupons.json` (placeholder) ให้สอดคล้องกับ section coupons ใน testdata หลัก (เลือกแหล่งเดียว)
5. **API helper** สำหรับเคส API-level (build order payload กลาง + ฟังก์ชัน POST ผ่าน `request` fixture)
6. **Update Excel** `checkout` sheet: ตั้ง `Automatable` + `Script Status=In Progress` ให้ 41 เคสรอบนี้

---

## 8. ลำดับการทำ (แนะนำ)

1. **เตรียมโครงสร้าง** (§7 ข้อ 1–5) — 0.5 วัน
2. **Phase 1** Discovery & Cart (16 เคส) — ใช้ POM เดิมเป็นหลัก
3. **Phase 2** Checkout validation (17 เคส) — core มูลค่าสูงสุด
4. **Phase 3** Payment/Tracking (6 เคส) — มี safety gate
5. **Phase 4** Cross-cutting API/security (8 เคส)
6. **ยืนยัน caveat 8 เคส** (§5) กับ dev → เพิ่มเข้า suite
7. อัปเดต Excel + รัน regression set → ส่งมอบ

---

## 9. Definition of Done (ต่อเคส)

- [ ] `test()` title มี TC-ID ตรง Final doc
- [ ] อ่าน data จาก `test-data/*.json` (ไม่ hardcode)
- [ ] ใช้ POM/fixtures เดิม ไม่ duplicate locator
- [ ] payment ทุกเคสหยุดก่อนยืนยันจริง
- [ ] ผ่านบน `chromium` (config staging) แบบ deterministic (ไม่ flaky)
- [ ] อัปเดต Status ใน Excel `checkout` sheet เป็น `Script Done`
