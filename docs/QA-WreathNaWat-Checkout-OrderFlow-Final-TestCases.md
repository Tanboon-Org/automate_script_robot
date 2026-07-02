# Checkout / Order Flow — Final Test Cases
## ระบบ: หรีด ณ วัด (Wreath Na Wat)

---

## 1. Document Information

| Field | Value |
|---|---|
| Project | Wreath Na Wat (หรีด ณ วัด) |
| Document Name | Checkout / Order Flow Final Test Cases |
| Source Documents | Round 1 (`CodeMap-Traceability`), Round 2 (`GapAnalysis`), Round 3 (`TestCaseReview`), Test Plan เดิม |
| Environment | Dev / Test (`wnw2025-frontend.dev-app-bit.com`) — **ห้าม payment จริง** |
| Date | 2026-06-25 |
| Prepared By | Senior QA Engineer / Test Architect |

---

## 2. Scope

เอกสารนี้ **ครอบคลุม** flow การสั่งซื้อตั้งแต่ค้นพบสินค้า → ชำระเงิน → ติดตามสถานะ:

- Product discovery (Home navigation, Category/Listing, Search), Product Detail
- Add to Cart, Cart (แก้จำนวน/ลบ/persist/limit 10)
- Checkout validation (required, email, phone, ข้อความ boundary)
- Shipping (ในเขต/นอกเขต/allow_delivery)
- Coupon / Promotion (login, min/max, used, re-validate)
- Message Card / Ribbon (มีจริงที่ Checkout)
- Register during checkout / Guest Checkout
- Order creation, Payment (โอน/QR/บัตร), Order Success, Tracking
- API Error handling, Session/Token, Security negative cases ที่เกี่ยวกับ checkout/order

**ไม่ครอบคลุม:** CMS, SEO, Article/Content page, Admin panel, Production payment จริง

---

## 3. Assumptions and Constraints

1. **ห้ามทำ payment transaction จริง** — ทดสอบถึงหน้าก่อนยืนยัน หรือใช้ payment sandbox เท่านั้น
2. Payment / 2C2P ต้องใช้ **sandbox หรือ mock** (`2C2P_*` env แบบ test, บัตรทดสอบ)
3. **Tracking microservice** (`/track-order`) อยู่นอก repo — ต้องขอ spec/endpoint เพิ่ม
4. ค่า env เช่น **`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`**, `EXCLUDED_TAGS`, min/max price default — ต้องยืนยันจาก dev ก่อน assert ตัวเลข
5. **Coupon test data** (amount/percent/min-max/campaign/used) ต้องขอจาก dev + ต้องมี **test user login** (คูปองต้อง `web_user_token`)
6. **Location `allow_delivery=false`** ต้องขอจาก dev
7. บาง test case เป็น **API-level** เพราะเป็น backend-only rule (delivery datetime, slug, email ซ้ำ, token, สลิป, consent)
8. **FE/BE inconsistency** (phone, consent) ต้องทดสอบทั้ง **UI และ API**
9. assumption ผิดจาก Test Plan เดิมถูกแก้ตาม code จริงแล้ว: **ribbon/message card มีจริงที่ Checkout, delivery date มีจริงและ required, credit card fee จาก env ไม่ใช่ 3% ตายตัว**

---

## 4. Test Data Requirement

| Test Data ID | Data Type | Required Data | Used By Test Case | Setup Method | Notes |
|---|---|---|---|---|---|
| TD-01 | Guest user | session ไม่มี token | TC-PROMO-04, TC-EMPTY/guest flow | incognito | คูปองใช้ไม่ได้ |
| TD-02 | Login test user | email+password+`web_user_token` | TC-PROMO-01-R/02-R/05/06/07/10, TC-AUTH-04, TC-SESS-01 | dev สร้างใน WEB_API | จำเป็นทุกเคสคูปอง |
| TD-03 | Product สั่งได้ | slug + `allow_add_to_cart=true` | TC-PDP-02, TC-CART-*, TC-CHK-* | ERP listing | — |
| TD-04 | Product สั่งไม่ได้ | `allow_add_to_cart=false` | TC-PDP-05 | dev/หาสินค้าหมด | ซ่อนปุ่ม → LINE |
| TD-05 | Product slug ปลอม | slug ไม่มีจริง | TC-CHK-12 | แก้ payload/sessionStorage | API-level |
| TD-06 | Product qty 10/11 | เพิ่มจนรวม 10 และ 11 | TC-CART-06 | เพิ่มในตะกร้า | boundary |
| TD-07 | Valid coupon | code + ยอดอยู่ในช่วง min/max | TC-PROMO-01-R | dev | login |
| TD-08 | Invalid coupon | code ไม่มีจริง/หมดอายุ | TC-PROMO-02-R | dev | — |
| TD-09 | Used coupon | code + UserCoupon ของ user นี้ | TC-PROMO-07 | dev set UserCoupon | login |
| TD-10 | Coupon min/max | code + tag `discount_min`/`discount_max` | TC-PROMO-05/06 | dev | boundary strict |
| TD-11 | Coupon amount | code + tag `discount=amount` | TC-PROMO-09 (param) | dev | บาทคงที่ |
| TD-12 | Coupon percent | code + tag `discount=percent` | TC-PROMO-09 (param) | dev | %×ยอด |
| TD-13 | Coupon campaign | code + tag `discount_campaign` + สินค้า tag ตรง | TC-PROMO-09/10 | dev | subset matching |
| TD-14 | Location ใน 6 จังหวัด | location_id กทม./ปริมณฑล | TC-CHK-01-R, TC-PAY-04 | ERP `/location/province` | ส่งฟรี |
| TD-15 | Location นอก 6 จังหวัด | วัดต่างจังหวัด | TC-CART-05-R | wat search | → LINE |
| TD-16 | Location allow_delivery=false | location ค่าส่งพิเศษ | TC-SHIP-01 | dev | modal ติดต่อทีม |
| TD-17 | Payment method 1 | โอน/QR (bank_id 1-4) | TC-PAY-01-R/05/06 | flow checkout | — |
| TD-18 | Payment method 2 | บัตร (method_id=2) | TC-PAY-02-R/04 | flow checkout | fee env% |
| TD-19 | 2C2P sandbox | merchant/secret test + บัตรทดสอบ | TC-PAY (2c2p), TC-ORD | `2C2P_*` env test | ห้ามบัตรจริง |
| TD-20 | Order รอชำระ | status_payment=0 | TC-PAY-01-R/05/06, TC-TRK | สร้าง order ใหม่ | — |
| TD-21 | Order ชำระแล้ว | status_payment=1/2 | TC-TRK-04, TC-PAY-08 | หลังแจ้งชำระ | — |
| TD-22 | Tracking ID จริง | tracking_id (sha256) + order_code+เบอร์ | TC-TRK-01a-R/02/03 | จาก order จริง | microservice |
| TD-23 | Slip upload file | รูป jpg/png | TC-PAY-01-R/05 | เตรียมไฟล์ | media upload |
| TD-24 | Mock API responses | 422 / 500 / 401 / timeout | TC-API-01/02, TC-SESS-01 | `page.route`/MSW | error path |

---

## 5. Final Test Case List

> Status เริ่มต้น = **Not Run** ทุกเคส • Test Level: UI / API / Integration / Manual Exploratory • payment ทุกเคส = หยุดก่อนยืนยันจริง

### 5.1 Home / Navigation

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-HOME-01-R | Home | เมนูหมวด | UI | Positive | High | Home โหลดสำเร็จ | เมนู "พวงหรีดดอกไม้สด" | 1.เปิด `/` 2.คลิก dropdown 3.คลิกหมวดย่อย | URL เปลี่ยนเป็น slug หมวด, listing แสดงสินค้าหมวดนั้น, breadcrumb ตรง | `src/app/[...slug]/page.tsx` | Not Run | เมนูหลัก `href="#"`+JS |
| TC-HOME-02 | Home | แบนเนอร์/โซเชียล | Manual Exploratory | Positive | Low | Home โหลดสำเร็จ | แบนเนอร์ขายดี, LINE, tel | 1.คลิกแบนเนอร์ 2.คลิก LINE/โทร | แบนเนอร์ → collection ถูก; LINE/โทร deep link | `home/*`, `Footer` | Not Run | external — assert URL |

### 5.2 Category / Listing / Search

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-CAT-01-R | Category | แสดงสินค้า | UI | Positive | High | มีสินค้าในหมวด | `/ร้านพวงหรีด/พวงหรีดดอกไม้สด/` | 1.เปิดหมวด 2.ตรวจการ์ด | แสดงรูป/ชื่อ/รหัส/ราคาโปร+เดิม, จำนวนรวมถูก | `app/products/page.tsx` | Not Run | smoke |
| TC-CAT-02-R | Category | Sort | UI | Positive/Boundary | High | listing ≥2 สินค้า | sort: แนะนำ/ช่วงราคา | 1.เลือก sort 2.อ่าน URL param 3.parse ราคา | "ช่วงราคา"→param `price` เรียงถูก; "แนะนำ"→`recommend`; URL คงค่า | `filter.ts:41-42` | Not Run | data-driven |
| TC-CAT-03 | Category | Filter + ล้าง | UI | Positive | High | อยู่ listing | ตัวกรองช่วงราคา/ประเภท | 1.เลือกตัวกรอง 2.ตรวจผล 3.ล้างตัวกรอง | ผลตรงเงื่อนไข; ล้าง→รายการเต็ม; ตัวนับอัปเดต | `filter.ts`, `process_*_condition` | Not Run | keep |
| TC-CAT-04 | Category | Pagination | UI | Boundary | Medium | หมวดหลายหน้า | หน้า 1/2/สุดท้าย | 1.คลิกถัดไป/เลขหน้า 2.หน้าสุดท้าย 3.ก่อนหน้า | เปลี่ยนหน้าถูก; ก่อนหน้า disabled ที่หน้า1; ไม่ซ้ำข้ามหน้า | `Pagination.tsx`, `_products` paginate | Not Run | ยืนยัน page vs load-more |
| TC-CAT-05-R | Category | Empty result | UI | Negative | Medium | — | filter combo ที่ให้ 0 ผล | 1.ตั้งตัวกรองเข้มจน 0 รายการ | empty state สื่อความหมาย + ทางเลือกล้างตัวกรอง | `ProductSection` (empty) | Not Run | ระบุ filter combo |
| TC-CAT-06 | Category | EXCLUDED_TAGS | UI | Negative | Medium | — | หมวดที่มี excluded tag | 1.เปิด listing | สินค้า excluded ไม่แสดง | `StoreController::process_excluded_tags` | Not Run | ขอค่า env |
| TC-SRCH-01-R | Search | keyword vs UI box | UI | Negative/Exploratory | Medium | — | keyword="ดอกไม้สด" | 1.หา search box (UI) 2.เปิด listing `?keyword=` | **BE รองรับ `?keyword=` (listing กรองได้)**; กล่อง UI = `Not verifiable from code` | `app/products/page.tsx:62-68` | Not Run | แก้ assumption DEF-001 |

### 5.3 Product Detail

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-PDP-01-R | PDP | แสดงข้อมูล | UI | Positive | High | สินค้ามีอยู่ | `/พวงหรีด/<slug>/` | 1.เปิด PDP 2.ตรวจชื่อ/รหัส/ราคา/ไซซ์/breadcrumb | ข้อมูลตรง listing; ราคาโปร+เดิม; breadcrumb ถูก | `api/product:getProductBySlug` | Not Run | parameterize ต่อหลาย slug |
| TC-PDP-02 | PDP | Add to Cart | UI | Positive | High | ตะกร้าว่าง | TD-03 | 1.กด "เพิ่มลงตะกร้า" 2.ดูตัวนับ 3.เปิด /cart/ | ตัวนับ +1; สินค้า+ราคาถูกใน cart; toast | `AddItemButton`, `cart.ts` | Not Run | critical |
| TC-PDP-03-R | PDP | Buy Now | UI | Positive | High | TD-03 `allow_add_to_cart=true` | H015 | 1.กด "ซื้อทันที!" | set `sessionStorage['checkoutProduct']`=สินค้านี้ → ไป `/checkout` ตรง (ข้าม cart) | `ProductButton:88-102` | Not Run | ต่างจาก add-to-cart |
| TC-PDP-05 | PDP | สั่งไม่ได้ | UI | Negative | Medium | TD-04 | — | 1.เปิด PDP สินค้าสั่งไม่ได้ | ซ่อนปุ่ม Buy Now, แสดงลิงก์ LINE | `ProductButton:131-150` | Pass | — |

### 5.4 Cart

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-CART-01 | Cart | Empty state | UI | Negative | Medium | ตะกร้าว่าง | — | 1.เปิด `/cart/` | "- คุณยังไม่มีสินค้าในตะกร้า -"; ยอด ฿0 | `cart/page.tsx`, `CartItem` | Not Run | ปุ่มชำระ disable = ยืนยัน |
| TC-CART-02-R | Cart | เพิ่ม/ลดจำนวน | UI | Positive | High | ≥1 สินค้าในตะกร้า | qty 1→2→1 | 1.กด + 2.กด − 3.ดูยอดรวม | ยอด = qty×ราคา; อัปเดตทุกครั้ง | `AddItemButton:39-92` | Not Run | — |
| TC-CART-02b-R | Cart | ลดถึง 0 → ลบ | UI | Boundary | Medium | มี 1 สินค้า qty=1 | — | 1.กด − ตอน qty=1 | ลบสินค้า + toast "ลบสินค้าออกจากตะกร้า" | `AddItemButton:69-81` | Not Run | — |
| TC-CART-03-R | Cart | persist (guest) | UI | Regression | Medium | guest, มีสินค้า | — | 1.เพิ่มสินค้า 2.refresh | คงอยู่ใน `localStorage['cart']` | `storage.ts:71-84` | Not Run | — |
| TC-CART-04 | Cart | ไป Checkout | UI | Positive | High | มีสินค้า (กทม.) | — | 1.กดปุ่มไปชำระเงิน | ไป `/checkout` พร้อมสรุปยอด | `ProductButton:88-102` | Not Run | critical |
| TC-CART-05-R | Checkout | ต่างจังหวัด → LINE | UI | Negative | Medium | มีสินค้า, อยู่ checkout | TD-15 | 1.เลือกวัดนอก 6 จังหวัด | disable ปุ่มชำระ + modal นำไป LINE | `CheckoutForm:onChangeWat:248` | Not Run | แก้ trigger ให้ตรง flow |
| TC-CART-06 | Cart | เกิน 10 ชิ้น | UI | Boundary | High | ตะกร้ามี 10 | TD-06 | 1.กด + จนรวม 11 | แสดง modal, จำกัดไม่เกิน 10 | `AddItemButton:46-52` | Not Run | boundary 10/11 |
| TC-CART-07 | Cart | guest→login sync | Integration | Positive | Medium | guest มีของในตะกร้า | TD-01→TD-02 | 1.เพิ่มของ (guest) 2.login | cart merge ไม่หาย (`synUserCart`) | `cart.ts:25-48` | Not Run | — |

### 5.5 Checkout (Validation + Shipping + Message Card)

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-CHK-01-R | Checkout | Happy path เต็ม | Integration | Positive | High | มีสินค้า, **message card ครบ** | วัด+วันที่(อนาคต ≥4ชม)+เวลา slot+ผู้สั่ง+email+phone `08xxxxxxxx`+consent+ribbon | 1.กรอกครบ+ribbon 2.เลือกชำระ 3.กดชำระ | ผ่าน → redirect `/payment/{tracking_id}` (หยุดก่อนชำระจริง) | `onCreateOrder`, `OrderController:store` | Not Run | critical; param payment method |
| TC-CHK-02-R | Checkout | required ว่าง | UI | Validation | High | กรอกเกือบครบ | param: wat, delivery_date, delivery_time, deceased/ศาลา/เบอร์, ผู้สั่ง, email, phone, ribbon | 1.เว้นทีละช่อง 2.กดชำระ | block submit + error ใต้ช่อง | `validation/checkout.ts`, `getValidationErrors` | Not Run | parameterize |
| TC-CHK-03 | Checkout | email | UI | Validation | High | อยู่ checkout | valid:`a@b.com`,`a.b+c@sub.co.th` / invalid:`abc`,`abc@`,`@x.com` | 1.กรอกอีเมล 2.blur/submit | invalid reject; valid ผ่าน | `validation/checkout.ts` yup `.email()` | Not Run | parameterize |
| TC-CHK-04-UI | Checkout | phone (FE) | UI | Validation | High | อยู่ checkout | `0812345678`(ผ่าน), `+66...`(reject) | 1.กรอก 2.blur/submit | FE: เฉพาะ `^0\d{9}$` ผ่าน | `validation/checkout.ts:customer_phone_number` | Not Run | คู่กับ -API |
| TC-CHK-04-API | Checkout | phone (BE) | API | FE/BE Inconsistency | High | — | `+66812345678`, `02xxxxxxx` | 1.POST `/api/order` ตรง | **BE รับ +66/เบอร์บ้าน** (regex กว้างกว่า FE) → inconsistency | `OrderController:store:customer.phone_number` | Not Run | risk RSK-02 |
| TC-CHK-05-UI | Checkout | consent (FE) | UI | Negative | High | กรอกครบ ไม่ติ๊ก consent | — | 1.ไม่ติ๊ก 2.กดชำระ | FE block + แจ้งยอมรับนโยบาย | `privacy_policy_accepted` (yup) | Not Run | คู่กับ SEC-01 |
| TC-CHK-06-R | Checkout | คำนวณยอด | Integration | Positive | 2-3 สินค้า, login (ถ้าใช้คูปอง) | สินค้าราคาต่าง + coupon | 1.ดู subtotal 2.ค่าส่ง 3.coupon 4.grand total | ยอดจาก `/order/total-payment`: total=(สินค้า+ส่ง−ลด); กทม.ส่งฟรี | `get_total_payment:~1610` | Not Run | — |
| TC-CHK-08-R | Checkout | boundary ข้อความ | UI/API | Boundary | Medium | อยู่ checkout | "ก"×255 / ×256 / emoji / เว้นหน้า-หลัง | 1.กรอกศาลา/ป้าย 2.submit | ≤255 ผ่าน; >255 reject "ยาวได้สูงสุด 255"; trim | `OrderController:store` max:255 | Not Run | parameterize |
| TC-PDP-04-R | Checkout | ข้อความริบบิ้น (มีจริง) | UI | Validation | High | มีสินค้า, อยู่ /checkout | "ด้วยรักและอาลัย" | 1.เปิด MessageCard modal 2.กรอก attachedMessage1 3.บันทึก | ช่องริบบิ้น **มีจริงที่ Checkout**; เก็บ `localStorage['messageCardModal-{n}-{code}']`; ส่งเป็น `attached_message_1` | `MessageCardModal`, `validateMessageCards:38` | Not Run | **ปิด DEF-003 (assumption ผิด)** |
| TC-CHK-09 | Checkout | delivery อดีต | API/UI | Negative | High | มีสินค้า, เลือกวัด | delivery_date=เมื่อวาน, time=12:00 | 1.กรอกวัน-เวลาอดีต 2.กดชำระ/POST order | reject "ไม่สามารถย้อนเวลาไปส่งให้ในอดีตได้..." | `Rules/PossibleDeliveryDateTime.php:22-26` | Not Run | — |
| TC-CHK-10 | Checkout | delivery < 4 ชม. | API/UI | Boundary | High | มีสินค้า, เลือกวัด | now+3ชม(fail)/now+4ชม(pass) | 1.เลือกเวลาใกล้ 2.submit | <4ชม reject "...ภายใน 4 ชั่วโมง..."; =4ชม ผ่าน | `PossibleDeliveryDateTime.php:29-35` | Not Run | parameterize |
| TC-CHK-11 | Checkout | delivery > 30 วัน | API | Boundary | Medium | มีสินค้า | now+30วัน(pass)/now+31วัน(fail) | 1.เลือกวันไกล 2.submit | >30วัน reject "...เกิน 30 วัน" | `PossibleDeliveryDateTime.php:38-44` | Not Run | parameterize |
| TC-CHK-12 | Checkout | slug ไม่มีจริง | API | API Error | High | — | TD-05 | 1.แก้ payload/sessionStorage 2.POST `/api/order` | reject "ไม่พบสินค้าตาม slug ... ในตะกร้า" | `Rules/ProductSlugExists.php:20-31` | Not Run | — |
| TC-CHK-13 | Checkout | ป้ายน้อยกว่าจำนวน | API/UI | Validation | High | สินค้า amount=2 | กรอก message card 1 ใบ | 1.เพิ่ม 2 ชิ้น 2.กรอกป้าย 1 3.กดชำระ | reject "...จำนวน 2 ชิ้น แต่ระบุข้อความ ... 1" | `OrderController:store` cart.* closure | Not Run | — |
| TC-SHIP-01 | Shipping | allow_delivery=false | Integration | Negative | — | TD-16 | 1.เลือกวัดนั้น | modal "...ติดต่อทีมบริการลูกค้า @wreathmala" | `fetchDeliveryFee:~340` | Not Run | ขอ location จาก dev |
| TC-EMPTY-01 | Checkout | /checkout ไม่มีสินค้า | UI | Empty State | Medium | ตะกร้าว่าง | — | 1.เข้า `/checkout` ตรง | จัดการ `'{}'` fallback, ไม่ crash | `contexts/checkout:getProductPayload` | Not Run | — |
| TC-LOAD-01 | Checkout | double submit | UI | Race Condition | High | กรอกครบ | — | 1.กดชำระเงินรัว ๆ 2 ครั้ง | `isSubmitting` block ครั้งที่ 2, ไม่สร้างออเดอร์ซ้ำ | `CheckoutForm:onSubmit`, `disableButton` | Not Run | — |

### 5.6 Coupon / Promotion

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-PROMO-01-R | Promotion | คูปองถูกต้อง | Integration | Positive | High | **login (web_user_token)**, สินค้าในเขต, ยอดในช่วง min/max | TD-07 | 1.login 2.checkout 3.กรอกคูปอง 4.Apply | `_infos.error=false`, ส่วนลดถูกหัก, grand total ลด | `validate_coupon:1356` | Pass | ต้อง login |
| TC-PROMO-02-R | Promotion | คูปองผิด | Integration | Negative | High | login, checkout | param: ไม่พบ/used/ยอด<min/ยอด>max | 1.กรอกแต่ละโค้ด 2.Apply | error ตรงกรณีจริง (ไม่พบ/WM21/used) | `validate_coupon`, `Controller.php:917-934` | Pass (expired รอ dev) | parameterize |
| TC-PROMO-03-R | Promotion | uppercase/ว่าง | Integration | Validation | Medium | login, checkout | "abc123"(จริง ABC123), "" | 1.กรอก 2.Apply | พิมพ์เล็กใช้ได้ (strtoupper); ว่าง→"กรุณากรอกรหัสส่วนลด" | `validate_coupon:1369,1360` | Pass | — |
| TC-PROMO-04 | Promotion | guest ใส่คูปอง | Integration | Permission | High | **ไม่ login** | TD-01 + coupon valid | 1.checkout (guest) 2.กรอกคูปอง 3.Apply | "ต้องล๊อคอินเข้าสู่ระบบก่อนค่ะ" | `validate_coupon:1416-1424` | Not Run | — |
| TC-PROMO-05 | Promotion | ยอด < discount_min | API | Negative | High | login, TD-10 | ยอด < min | 1.Apply คูปอง | WM21 "ราคารวม...ไม่สามารถประยุกต์ใช้..." | `Controller.php:917-934` | Pass | — |
| TC-PROMO-06 | Promotion | ยอดพอดี min/max | API | Boundary | Medium | login, TD-10 | ยอด=min, =max | 1.Apply | ค่าขอบพอดี **ใช้ไม่ได้** (`>min && <max`) | `Controller.php:918` | Not Run | strict boundary |
| TC-PROMO-07 | Promotion | คูปองใช้ซ้ำ | Integration | Negative | High | login + เคยใช้ (TD-09) | coupon used | 1.Apply คูปองเดิม | "ท่านได้ใช้รหัสส่วนลด ... ไปแล้วค่ะ" | `validate_coupon:1426-1438` | Pass | — |
| TC-PROMO-09 | Promotion | amount vs percent | API | Positive | Medium | login | TD-11, TD-12 | 1.Apply แต่ละแบบ ดูยอดหัก | amount=บาทคงที่; percent=%×ยอด | `discountAmount:1707-1770` | Not Run | parameterize |
| TC-PROMO-10 | Promotion | re-validate ตอนสั่ง | Integration | API Error | High | login, สลับยอด/คูปองให้ขัด | TD-07/13 | 1.Apply ผ่าน 2.กดชำระ | order reject "Error validating coupon code(WME01): ..." | `OrderController:store:~320` | Not Run | — |

### 5.7 Register / Auth (during checkout)

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-AUTH-01-R | Auth | สมัครตอน checkout | Integration | Positive | Medium | checkout, email ใหม่ | add_to_new_user=1, password ≥8 | 1.ติ๊กสมัคร 2.ตั้ง password 3.สั่ง | `register_new_web_user` สร้าง user; login ภายหลังได้ | `OrderController:register_new_web_user` | Not Run | — |
| TC-AUTH-03 | Auth | email ซ้ำตอนสมัคร | API | Negative | High | มี email ที่ลงทะเบียนแล้ว | add_to_new_user=1, email=ซ้ำ | 1.ติ๊กสมัคร + email ซ้ำ 2.สั่ง | reject "อีเมล์แอดเดรส ... ถูกใช้ไปแล้ว" | `Rules/WebUserExists::validate` | Not Run | — |
| TC-AUTH-04 | Auth | token ไม่ถูกต้อง | API | Permission | High | — | web_user_token ปลอม + coupon_code | 1.POST order ด้วย token ผิด | reject "Web User Token ไม่ถูกต้อง" | `WebUserExists::validToken` | Not Run | — |
| TC-AUTH-05 | Auth | สมัคร password สั้น/ไม่ตรง | API/UI | Validation | Medium | checkout | password="123" | 1.ติ๊กสมัคร + password สั้น 2.สั่ง | reject "รหัสผ่านต้องยาวอย่างน้อย 8" | `OrderController:store`, `CheckoutForm:502` | Not Run | — |

### 5.8 Payment

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-PAY-01-R | Payment | QR/โอน + แจ้งชำระ | Integration | Positive | High | order รอชำระ (TD-20) | bank_id 1-4 + สลิป (TD-23) | 1.เปิด `/payment/{tracking_id}` 2.เลือกธนาคาร 3.แนบสลิป | แสดง QR/บัญชี; แจ้งชำระ → `/order/accept-payment-infos`; **ไม่ตัดเงินอัตโนมัติ** | `payment/[tracking_id]`, `accept_payment_infos` | Not Run | หยุดก่อนยืนยัน |
| TC-PAY-02-R | Payment | บัตร fee (env) | Integration | Boundary | High | ผ่าน checkout, ยอดทราบค่า (TD-18) | method=2, ยอด=X | 1.เลือกบัตร 2.ดูยอด | fee = X×`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`/100 (**ยืนยันค่า env**) | `get_total_payment:~1625` | Not Run | **แก้ assumption 3% ตายตัว** |
| TC-PAY-03 | Payment | ไม่ทำ transaction จริง | Manual Exploratory | Positive (safety gate) | High | อยู่หน้าชำระเงิน | — | 1.หยุดก่อนยืนยันชำระจริง | ไม่มี transaction จริงใน env ทดสอบ | กฎความปลอดภัย | Not Run | gate กลางทุก payment TC |
| TC-PAY-04 | Payment | fee = total×env% | Integration | Boundary | High | ผ่าน checkout (TD-18) | method=2, ยอด=X | 1.เลือกบัตร 2.ดูยอด | fee=X×env%/100; total+fee แสดงก่อนชำระ | `get_total_payment:~1625` | Not Run | ยืนยัน env |
| TC-PAY-05 | Payment | สลิปบังคับ | API | Validation | High | order รอชำระ (TD-20) | bank_id=1, ไม่มี media_id | 1.POST `/order/accept-payment-infos` ไม่แนบสลิป | reject (media_id required_with bank_id) | `accept_payment_infos:rules` | Not Run | — |
| TC-PAY-06 | Payment | bank_id → payment.type | API | Positive | Medium | order รอชำระ | bank_id 0/1/2/3/4 | 1.แจ้งชำระแต่ละธนาคาร | payment.type map ถูก (4/2/3/1/6) | `accept_payment_infos:switch` | Not Run | parameterize |
| TC-PAY-07 | Payment | status_payment โอน=1/บัตร=2 | API | Positive | Medium | order รอชำระ | โอน vs 2c2p | 1.แจ้งชำระ | status_payment = 1(โอน)/2(บัตร) | `accept_payment_infos:~1010` | Not Run | — |
| TC-PAY-09 | Payment | transfer date/time ผิด | API | Validation | Medium | order รอชำระ | date="2026/01/01" | 1.แจ้งชำระ format ผิด | reject "...รูปแบบ Y-m-d / H:i" | `accept_payment_infos:rules` | Not Run | — |
| TC-PAY-10 | Payment | 2C2P fail | API | API Error | Medium | order รอชำระ | success=false, tracking_id | 1.callback fail | ส่งเมล fail, return ok | `payment_fails:1147` | Not Run | sandbox |

### 5.9 Order Success / Tracking

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-ORD-01a-R | Order Success | หน้า success | UI | Positive | Medium | order สำเร็จ (sandbox) | tracking_id | 1.เปิด `/payment/success/{tracking_id}` | แสดงเลขออเดอร์/สรุป | `app/payment/success/[tracking_id]` | Not Run | — |
| TC-ORD-01b-R | Order Success | email ยืนยัน | Integration | Positive | Medium | order สำเร็จ | email ผู้สั่ง | 1.สั่งสำเร็จ 2.ตรวจเมล | `SendOrderCreatedEmailJob` dispatch + ได้เมล | `OrderController:store:~440` | Not Run | ตรวจที่ mail server |
| TC-TRK-01a-R | Tracking | ค้นด้วย tracking_id | Integration | Positive | Medium | TD-22 (service พร้อม) | tracking_id | 1.เปิด `/tracking?tracking_id=` 2.ค้นหา | แสดงสถานะตาม status_payment | `app/tracking/page.tsx`; service=`Not verifiable from code` | Not Run | ขอ spec service |
| TC-TRK-02 | Tracking | order_code + เบอร์/อีเมล | Integration | Positive | Medium | TD-22 | order_code + phone_or_email | 1.กรอกคู่ข้อมูล 2.ค้นหา | แสดงสถานะ | `tracking/page.tsx:36-44` | Not Run | path ที่ 2 |
| TC-TRK-03 | Tracking | ข้อมูลผิด | Integration | Negative | Medium | — | tracking_id ปลอม | 1.ค้นหา | branch notFound, ไม่ leak ข้อมูลผู้อื่น | `tracking/page.tsx:55-58` | Not Run | — |
| TC-TRK-04 | Tracking | branch status_payment | Integration | Positive | Medium | order หลายสถานะ (TD-20/21) | status 0/1 vs 2/3/4 | 1.เปิด tracking | 0/1→`result-notpayment`; 2-4→`result` | `tracking/page.tsx:140-160` | Not Run | — |

### 5.10 Cross-cutting: API Error / Session / Security / Responsive

| Test Case ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence | Status | Remark |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-SEC-01 | Security | consent bypass (BE) | API | Security | High | — | payload ไม่มี privacy_policy_accepted | 1.POST `/api/order` ตรง | **BE ไม่ block → ผ่าน** = ความเสี่ยง bypass; แจ้ง dev เพิ่ม rule | `OrderController:store` (ไม่มี privacy rule) | Not Run | = TC-CHK-05 ฝั่ง API |
| TC-SEC-02 | Security | phone bypass FE | API | FE/BE Inconsistency | Medium | — | `+66812345678` | 1.POST `/api/order` ตรง | FE reject แต่ BE รับ | FE vs BE regex | Not Run | — |
| TC-SEC-03 | Security | XSS/SQLi ในป้าย/ศาลา | API | Security | Medium | — | `<script>alert(1)</script>`, `' OR '1'='1` | 1.กรอก submit | Eloquent parameterized; ไม่ execute/ไม่ 500 (`Not verifiable from code` — ต้อง execute) | `OrderController:store` (ไม่พบ explicit sanitize) | Not Run | basic security smoke |
| TC-API-01 | API Error | ERP 422 | Integration | API Error | High | mock ERP 422 (TD-24) | — | 1.submit order | proxy คืน `{error:true,...}` → `openErrorModal` แสดง | `pages/api/order.ts:catch`, `onCreateOrder:else` | Not Run | mock |
| TC-API-02 | API Error | ERP 500/timeout | Integration | API Error | High | mock ERP 500/timeout (TD-24) | — | 1.submit order/total-payment | modal error, ไม่ crash | `pages/api/total-payment.ts:catch`, interceptors | Not Run | mock |
| TC-SESS-01 | Session | 401 handling | Integration | Session | High | login | mock 401 จาก ERP_API (TD-24) | 1.เรียก API ระหว่าง flow | `clearStorage()` + reload | `instance.ts` ERP_API interceptor | Not Run | — |
| TC-SESS-02 | Session | cleanup messageCard keys | UI | Session | Medium | มีของ + กรอกป้าย | — | 1.ลบสินค้า/สั่งสำเร็จ | localStorage `messageCardModal-*` ถูกลบ | `useCart:43-53`, `onCreateOrder:cleanup` | Not Run | กันข้อมูลป้ายเก่ารั่ว |
| TC-ERR-01 | Error | 404 page | UI | Negative | Medium | — | `/this-page-does-not-exist/` | 1.เปิด URL ไม่มีจริง | หน้า 404 ที่ออกแบบ + ลิงก์กลับ | `app/not-found.tsx` | Not Run | keep |
| TC-ERR-02 | Responsive | mobile flow | Manual Exploratory | Regression | Medium | — | viewport 375×812 | 1.ทำ flow สั่งซื้อบนมือถือ | layout ไม่แตก, ปุ่ม/ฟอร์มใช้ได้, hamburger ใช้ได้ | `CartSummaryMobile`, `MobileOrderSummary` | Not Run | manual |

---

## 6. Parameterized Test Cases

| Base Test Case ID | Parameter Field | Parameter Values | Expected Variation | Related Module | Notes |
|---|---|---|---|---|---|
| TC-CHK-10 | delivery datetime | now+3ชม / now+4ชม / now+5ชม | <4ชม fail; ≥4ชม pass | Checkout | `PossibleDeliveryDateTime` |
| TC-CHK-11 | delivery date | now+30วัน / now+31วัน | ≤30 pass; >30 fail | Checkout | boundary 30 วัน |
| TC-CART-06 | product quantity | รวม 9 / 10 / 11 | ≤10 ผ่าน; 11 modal | Cart | limit 10 |
| TC-PROMO-02-R | coupon case | ไม่พบ / used / ยอด<min / ยอด>max | error ต่างกัน | Promotion | error ตาม code จริง |
| TC-PROMO-06 | coupon min/max boundary | ยอด=min / min+1 / max−1 / =max | พอดี min,max ใช้ไม่ได้ (strict) | Promotion | `>min && <max` |
| TC-PROMO-09 | coupon type | amount / percent | บาทคงที่ vs %×ยอด | Promotion | `discountAmount` |
| TC-CHK-01-R | payment method | method_id 1 / 2 | 1→`/payment/{id}`; 2→`/payment/2c2p/{id}` | Checkout/Payment | `onCreateOrder` branch |
| TC-PAY-06 | bank_id | 0/1/2/3/4 | payment.type 4/2/3/1/6 | Payment | `accept_payment_infos:switch` |
| TC-CHK-04-UI / -API | phone format | `0812345678`/`+66812345678`/`02xxxxxxx`/`12345`/`08a2345678` | FE: เฉพาะ `^0\d{9}$`; BE: รับ +66/เบอร์บ้าน | Checkout | FE/BE inconsistency |
| TC-CHK-03 | email | valid:`a@b.com`,`a.b+c@sub.co.th` / invalid:`abc`,`abc@`,`@x.com` | valid ผ่าน; invalid reject | Checkout | yup `.email()` |
| TC-CHK-08-R | message/text length | "ก"×255 / ×256 / emoji / เว้นหน้า-หลัง | ≤255 ผ่าน; >255 reject; trim | Checkout | max:255 |
| TC-API-01/02 | API error status | 422 / 500 / timeout / 401 | modal/clear ต่างกัน | API Error/Session | proxy + interceptors |
| TC-TRK-01a-R | tracking search type | tracking_id / order_code+phone_or_email / invalid | result/notFound | Tracking | `tracking/page.tsx:36-44` |
| TC-CHK-01-R | user type | guest / login | login ใช้คูปองได้; guest ไม่ได้ | Checkout/Promotion | coupon ต้อง login |

---

## 7. High Priority Regression Set

| Test Case ID | Module | Reason |
|---|---|---|
| TC-CHK-01-R | Checkout | happy path end-to-end (รายได้หลัก) |
| TC-CHK-09 / 10 / 11 | Checkout | delivery datetime validation (อดีต/<4ชม/>30วัน) — เปลี่ยน "ส่งได้/ไม่ได้" |
| TC-PDP-04-R | Checkout | message card / ribbon validation (core ของพวงหรีด) |
| TC-CHK-13 | Checkout | ป้ายน้อยกว่าจำนวน → reject |
| TC-CHK-12 | Checkout | slug invalid → reject |
| TC-PROMO-01-R / 04 / 05 / 06 / 07 / 10 | Promotion | coupon login/min-max/used/re-validate — กระทบยอดเงิน |
| TC-CART-06 | Cart | limit 10/11 |
| TC-PAY-02-R / 04 | Payment | credit card fee (env%) — คิดเงินผิดเสี่ยงสูง |
| TC-PAY-05 | Payment | สลิป upload required |
| TC-API-01 / 02 | API Error | ERP 422/500 handling |
| TC-SESS-01 | Session | 401 handling |
| TC-LOAD-01 | Checkout | double submit protection (กันออเดอร์ซ้ำ) |
| TC-SEC-01 | Security | consent bypass (BE ไม่ enforce) |
| TC-CHK-04-UI / -API | Checkout | phone FE/BE inconsistency |

---

## 8. Known Limitations / Not Verifiable Items

| Item | Reason | Required Action |
|---|---|---|
| Tracking microservice `/track-order` | source ไม่อยู่ใน repo | ขอ spec/endpoint จาก dev (กระทบ TC-TRK-*) |
| Search UI box | BE รองรับ `keyword` แต่ไม่พบกล่อง UI ใน code | execute หน้าเว็บยืนยัน (TC-SRCH-01-R) |
| ค่า env จริง (`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`, `EXCLUDED_TAGS`, min/max default) | เป็น runtime config ไม่อยู่ใน code | ขอจาก dev ก่อน assert ตัวเลข |
| 2C2P gateway behavior | external gateway | ใช้ sandbox (TD-19) |
| Email/SMS delivery | queue job → mail server | ตรวจที่ mail server/inbox |
| XSS/SQLi sanitize | ไม่พบ explicit escape ใน code | execute security test (TC-SEC-03) |
| Coupon test data | ต้องมี product/tag/UserCoupon จริง | ขอจาก dev (TD-07..13) |
| Location `allow_delivery=false` | ขึ้นกับข้อมูล location จริง | ขอจาก dev (TD-16) |

---

## 9. Defect / Risk Notes

| Risk ID | Area | Description | Impact | Recommendation |
|---|---|---|---|---|
| RSK-01 | Security / Consent | consent (privacy policy) enforce เฉพาะ FE — **BE ไม่มี validation rule** | bypass ผ่าน API ได้ → PDPA compliance เสี่ยง | dev เพิ่ม rule `privacy_policy_accepted` ที่ `OrderController:store` (TC-SEC-01) |
| RSK-02 | Validation / Phone | FE `^0\d{9}$` (เข้ม) ≠ BE regex (รับ +66/เบอร์บ้าน) | ข้อมูลเบอร์ไม่สอดคล้อง/ผ่าน API ได้ | จัด policy เบอร์ให้ตรงกัน 2 ฝั่ง (TC-CHK-04-UI/-API) |
| RSK-03 | DEF-003 (ปิด) | "ไม่มีช่องริบบิ้น" — **assumption ผิด** code มี `MessageCardModal` + BE `attached_message_1 required` | Test Plan เดิมเข้าใจผิด | **ปิด DEF-003**; ใช้ TC-PDP-04-R (ช่องอยู่ที่ Checkout) |
| RSK-04 | DEF-004 (ปิด) | "ไม่มีวันที่จัดส่ง" — **assumption ผิด** มี `delivery_date` required FE/BE + กฎ datetime | Test Plan เดิมเข้าใจผิด | **ปิด DEF-004**; ใช้ TC-CHK-09/10/11 |
| RSK-05 | Search | DEF-001 — BE รองรับ `keyword` แต่ยังไม่ยืนยันกล่อง UI | conversion เสี่ยงถ้าไม่มี UI | execute ยืนยัน + คุยกับ PO (TC-SRCH-01-R) |
| RSK-06 | Payment | credit card fee = env% (ไม่ใช่ 3 ตายตัว) | ถ้า env ผิด → คิดเงินผิด | ยืนยันค่า `CREDIT_CARD_SERVICE_FEE_PERCENTAGE` (TC-PAY-02-R/04) |
| RSK-07 | Tracking | tracking service อยู่นอก repo | ตรวจ behavior จริงไม่ได้ | ขอ spec (TC-TRK-*) |
| RSK-08 | Coupon | คูปองต้อง login + ใช้ซ้ำเช็คผ่าน UserCoupon | guest ใช้ไม่ได้/UX สับสน | ระบุ precondition login ชัดเจน (TC-PROMO-04) |
| RSK-09 | Order / Race | กดชำระซ้ำอาจสร้าง web_order/order ซ้ำ | ออเดอร์/ตัดเงินซ้ำ | ยืนยัน `isSubmitting` กัน double submit (TC-LOAD-01) |

---

## 10. Next Step

1. **Review final test cases** กับ QA / PO / Dev — โดยเฉพาะปิด DEF-003/DEF-004 (assumption ผิด) และยืนยัน RSK-01..09
2. **ขอ test data จากทีม dev** ตามตาราง Step 4 (login user+token, coupon ครบชนิด, location allow_delivery=false, 2C2P sandbox, tracking_id/order_code จริง, ค่า env)
3. **Execute manual regression** เริ่มจาก High Priority Regression Set (Step 7)
4. **บันทึก defect ที่พบจริง** + อัปเดต Status/Actual Result (เปลี่ยนจาก Not Run)
5. **Round ถัดไป — Playwright Automation Feasibility:** ออกแบบ POM ตาม module, data-driven จาก Step 6, mock API/payment (`page.route`), เพิ่ม `data-testid` ให้ทีม dev (selector ปัจจุบันพึ่ง Thai text เปราะ)
