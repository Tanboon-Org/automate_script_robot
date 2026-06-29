# QA Round 3 — Test Case Quality Review & Refinement
## Order Flow: หรีด ณ วัด (Wreath Na Wat)

| | |
|---|---|
| **ระบบ** | หรีด ณ วัด (Wreath Na Wat) — ร้านขายพวงหรีด/ดอกไม้งานศพออนไลน์ |
| **อ้างอิง** | `QA-WreathNaWat-OrderFlow-TestPlan.md`, `...-CodeMap-Traceability.md` (R1), `...-GapAnalysis.md` (R2) |
| **ขอบเขตรอบนี้** | Test Case Quality Review + Refinement + แปลง Missing TC เป็น Detailed TC |
| **วันที่** | 2026-06-25 |
| **ผู้จัดทำ** | Senior QA Engineer / Test Case Reviewer |

> **กฎ:** อิง code evidence จาก R1/R2 เท่านั้น — ไม่เดา, ไม่ทำ Playwright automation ละเอียด, แก้ assumption ผิด (ribbon/date) ให้ตรง code, backend-only rule → API Test, FE/BE inconsistency → ทั้ง UI + API Test

---

# Step 1 — Review Existing Test Case Quality

| Test Case ID | Module | Status (R1) | Issue Type | Detail | Impact | Suggested Action |
|---|---|---|---|---|---|---|
| TC-HOME-01 | Home | Valid | Steps Not Clear | เมนู `href="#"`+JS ไม่ระบุวิธียืนยัน navigation | Medium | Rewrite |
| TC-HOME-02 | Home | Not Verifiable | Not Executable | ลิงก์ภายนอก (LINE/โทร) assert ได้แค่ URL | Low | Keep |
| TC-CAT-01 | Category | Valid | Expected Result Too Broad | "badge ครบ" ไม่ระบุ field | Low | Rewrite |
| TC-CAT-02 | Category | Partially Valid | Missing Validation Detail | ไม่ระบุ mapping sort จริง (`recommend`/`price`) | Medium | Rewrite + Parameterize |
| TC-CAT-03 | Category | Valid | Keep | — | Low | Keep |
| TC-CAT-04 | Category | Partially Valid | Missing Test Data | ไม่ระบุว่าเป็น page หรือ load-more | Medium | Need More Evidence |
| TC-CAT-05 | Category | Not Verifiable | Missing Test Data | ไม่ระบุ filter combo ที่ให้ 0 ผล | Low | Rewrite |
| TC-PDP-01 | PDP | Valid | Missing Validation Detail | ราคา/ไซซ์ hardcode เฉพาะ H015 | Low | Parameterize |
| TC-PDP-02 | PDP | Valid | Keep | critical path | High | Keep |
| TC-PDP-03 | PDP | Valid | Missing Validation Detail | ไม่ระบุว่า Buy Now ข้าม cart ตรงไป /checkout | Medium | Rewrite |
| TC-PDP-04 | PDP | **Invalid** | **Not Match Code** | **assumption ผิด — ริบบิ้นมีจริงที่ Checkout (R1 DEF-003)** | High | Rewrite (ย้าย module → Checkout) |
| TC-CART-01 | Cart | Valid | Invalid Expected Result | "ปุ่มชำระเงิน disabled/ซ่อน" ยังไม่ยืนยันจาก code | Medium | Rewrite + Need More Evidence |
| TC-CART-02 | Cart | Valid | Should Split | รวม เพิ่ม/ลด/ลบ/boundary 10 ในเคสเดียว | Medium | Split |
| TC-CART-03 | Cart | Valid | Missing Test Data | ไม่แยก guest (`localStorage['cart']`) vs login | Medium | Split |
| TC-CART-04 | Cart | Valid | Keep | critical path | High | Keep |
| TC-CART-05 | Cart | Partially Valid | Not Match Code | trigger จริงอยู่ตอนเลือกวัดใน checkout ไม่ใช่ปุ่ม cart | Medium | Rewrite |
| TC-PROMO-01 | Promotion | Partially Valid | Missing Preconditions | **ขาด precondition ต้อง login (web_user_token)** | High | Rewrite |
| TC-PROMO-02 | Promotion | Partially Valid | Should Parameterize | error ตามกรณีจริง (WM21/used/ไม่พบ) ไม่ครบ | High | Rewrite + Parameterize |
| TC-PROMO-03 | Promotion | Valid | Missing Validation Detail | uppercase behavior ระบุไม่ชัด | Medium | Rewrite |
| TC-CHK-01 | Checkout | Valid | Missing Test Data | ขาด message card + วัด + delivery_date ใน data | High | Rewrite |
| TC-CHK-02 | Checkout | Partially Valid | Missing Validation Detail | ชุด required ขาด wat / delivery_date / ribbon | High | Rewrite + Parameterize |
| TC-CHK-03 | Checkout | Valid | Should Parameterize | email valid/invalid เหมาะ data-driven | Medium | Parameterize |
| TC-CHK-04 | Checkout | Partially Valid | Needs API-level Test | **FE `^0\d{9}$` ≠ BE regex (+66) → ต้องทดสอบ 2 ชั้น** | High | Split (UI+API) |
| TC-CHK-05 | Checkout | Partially Valid | Needs API-level Test | **consent enforce เฉพาะ FE — BE ไม่ block** | High | Split (UI+API) |
| TC-CHK-06 | Checkout | Valid | Expected Result Too Broad | ไม่ระบุว่ายอดคำนวณที่ BE (`/order/total-payment`) | Medium | Rewrite |
| TC-CHK-07 | Checkout | Not Verifiable | Missing Validation Detail | ไม่ระบุ field/endpoint ทดสอบ payload | Medium | Rewrite |
| TC-CHK-08 | Checkout | Partially Valid | Missing Validation Detail | BE max:255 (ศาลา/ป้าย) ไม่ได้อ้าง | Medium | Rewrite + Parameterize |
| TC-PAY-01 | Payment | Valid | Missing Validation Detail | ไม่ระบุว่า order success = `/payment/[tracking_id]` + media required | High | Rewrite |
| TC-PAY-02 | Payment | Partially Valid | Invalid Expected Result | **คำนวณ 3% ตายตัวผิด — fee จาก env** | High | Rewrite |
| TC-PAY-03 | Payment | Valid | Keep | safety gate | High | Keep |
| TC-ORD-01 | Order Success | Valid | Too Broad | รวม success/thankyou/fail/email ในเคสเดียว | Medium | Split |
| TC-TRK-01 | Tracking | Partially Valid | Should Split | รวม valid/invalid/2 path ในเคสเดียว (microservice แยก) | Medium | Split + Need More Evidence |
| TC-AUTH-01 | Auth | Valid | Missing Validation Detail | ไม่อ้าง `register_new_web_user` / password rule | Medium | Rewrite |
| TC-SRCH-01 | Search | Partially Valid | Not Match Code | **assumption "ไม่มี search" ไม่ครบ — BE รองรับ `?keyword=`** | Medium | Rewrite (แยก UI box vs keyword param) |
| TC-ERR-01 | Error | Valid | Keep | มี `not-found.tsx` | Low | Keep |
| TC-ERR-02 | Responsive | Not Verifiable | Too Broad | "flow บนมือถือ" กว้างเกิน | Low | Keep (manual) |

---

# Step 2 — Rewrite / Improve Existing Test Cases

| Revised ID | Original ID | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence / Reason |
|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-HOME-01-R | TC-HOME-01 | Home | เมนูหมวด | UI | Positive | High | Home โหลดสำเร็จ | เมนู "พวงหรีดดอกไม้สด" | 1.เปิด `/` 2.คลิก dropdown 3.คลิกหมวดย่อย | URL เปลี่ยนเป็น slug หมวด, listing แสดงสินค้าหมวดนั้น, breadcrumb ตรง | `[...slug]/page.tsx` map slug |
| TC-CAT-02-R | TC-CAT-02 | Category | Sort | UI | Positive/Boundary | High | อยู่ listing ≥2 สินค้า | sort: แนะนำ/ช่วงราคา | 1.เลือก sort 2.อ่าน URL param 3.parse ราคาเรียง | "ช่วงราคา"→param `price` เรียงถูก; "แนะนำ"→`recommend`; URL คงค่า | `filter.ts:41-42` |
| TC-PDP-03-R | TC-PDP-03 | PDP | Buy Now | UI | Positive | High | สินค้า `allow_add_to_cart=true` | H015 | 1.กด "ซื้อทันที!" | set `sessionStorage['checkoutProduct']`=สินค้านี้ → ไป `/checkout` ตรง (ไม่ผ่าน cart) | `ProductButton:88-102` |
| TC-PDP-04-R | TC-PDP-04 | **Checkout** | ข้อความริบบิ้น (มีจริง) | UI | Validation | High | มีสินค้า, อยู่ /checkout | "ด้วยรักและอาลัย" | 1.เปิด checkout 2.เปิด MessageCard modal 3.กรอก attachedMessage1 4.บันทึก | ช่องริบบิ้น **มีจริงที่ Checkout**; เก็บ `localStorage['messageCardModal-{n}-{code}']`; ส่งเป็น `attached_message_1` | R1 DEF-003 ผิด; `MessageCardModal`, `validateMessageCards:38` |
| TC-CART-02-R | TC-CART-02 | Cart | เพิ่ม/ลดจำนวน | UI | Positive | High | ≥1 สินค้าในตะกร้า | qty 1→2→1 | 1.กด + 2.กด − 3.ดูยอดรวม | ยอด = qty×ราคา; ยอดอัปเดตทุกครั้ง | `AddItemButton:39-92` |
| TC-CART-02b-R | TC-CART-02 | Cart | ลดถึง 0 → ลบ | UI | Boundary | Medium | มี 1 สินค้า qty=1 | — | 1.กด − ตอน qty=1 | ลบสินค้า + toast "ลบสินค้าออกจากตะกร้า" | `AddItemButton:69-81` |
| TC-CART-03-R | TC-CART-03 | Cart | persist (guest) | UI | Regression | Medium | guest, มีสินค้า | — | 1.เพิ่มสินค้า 2.refresh | คงอยู่ใน `localStorage['cart']` | `storage.ts:71-84 CartStorage` |
| TC-CART-05-R | TC-CART-05 | Checkout | ต่างจังหวัด → LINE | UI | Negative | Medium | มีสินค้า, อยู่ checkout | วัดต่างจังหวัด | 1.เลือกวัดนอก 6 จังหวัด | disable ปุ่มชำระ + modal นำไป LINE | `CheckoutForm:onChangeWat:248` |
| TC-PROMO-01-R | TC-PROMO-01 | Promotion | คูปองถูกต้อง | Integration | Positive | **login (web_user_token)**, มีสินค้าในเขต, ยอดอยู่ในช่วง min/max | coupon valid จาก dev | 1.login 2.checkout 3.กรอกคูปอง 4.Apply | `_infos.error=false`, ยอดส่วนลดถูกหัก, grand total ลด | `validate_coupon:1356`, R1 coupon ต้อง login |
| TC-PROMO-02-R | TC-PROMO-02 | Promotion | คูปองผิด (data-driven) | Integration | Negative | login, checkout | ดู Step 5 param | 1.กรอกแต่ละโค้ด 2.Apply | error ตรงกรณีจริง (ไม่พบ/WM21/used) | `validate_coupon`, `Controller.php:917-934` |
| TC-PROMO-03-R | TC-PROMO-03 | Promotion | uppercase/ว่าง | Integration | Validation | Medium | login, checkout | "abc123"(จริง ABC123), "" | 1.กรอก 2.Apply | พิมพ์เล็กใช้ได้ (strtoupper); ว่าง→"กรุณากรอกรหัสส่วนลด" | `validate_coupon:1369,1360` |
| TC-CHK-01-R | TC-CHK-01 | Checkout | Happy path เต็ม | Integration | Positive | มีสินค้า, **กรอก message card ครบ** | วัด+วันที่(อนาคต ≥4ชม)+เวลา slot+ผู้สั่ง+email+phone `08xxxxxxxx`+consent+ribbon | 1.กรอกครบ+ribbon 2.เลือกชำระ 3.กดชำระ | ผ่าน → redirect `/payment/{tracking_id}` (หยุดก่อนชำระจริง) | `onCreateOrder`, `OrderController:store` |
| TC-CHK-02-R | TC-CHK-02 | Checkout | required ว่าง (param) | UI | Validation | High | กรอกเกือบครบ | param: ดู Step 5 (รวม wat, delivery_date, ribbon) | 1.เว้นทีละช่อง 2.กดชำระ | block submit + error ใต้ช่อง | `validation/checkout.ts`, `getValidationErrors` |
| TC-CHK-04-UI | TC-CHK-04 | Checkout | phone (FE) | UI | Validation | High | อยู่ checkout | "0812345678"(ผ่าน), "+66..."(FE reject) | 1.กรอก 2.blur/submit | FE: เฉพาะ `^0\d{9}$` ผ่าน | `validation/checkout.ts:customer_phone_number` |
| TC-CHK-04-API | TC-CHK-04 | Checkout | phone (BE) | API | FE/BE Inconsistency | High | — | "+66812345678", "02xxxxxxx" | POST `/api/order` ตรง | **BE รับ +66/เบอร์บ้าน** (regex กว้างกว่า FE) → รายงาน inconsistency | `OrderController:store:customer.phone_number` |
| TC-CHK-05-UI | TC-CHK-05 | Checkout | consent (FE) | UI | Negative | High | กรอกครบ ไม่ติ๊ก consent | — | 1.ไม่ติ๊ก 2.กดชำระ | FE block + แจ้งยอมรับนโยบาย | `privacy_policy_accepted` (yup) |
| TC-CHK-05-API | TC-CHK-05 | Checkout | consent bypass (BE) | API | Security | High | — | payload ไม่มี privacy_policy | POST `/api/order` ตรง | **BE ไม่มี rule → ผ่าน** = ความเสี่ยง bypass | R2 GAP-26; `OrderController:store` (ไม่มี privacy rule) |
| TC-CHK-06-R | TC-CHK-06 | Checkout | คำนวณยอด | Integration | Positive | 2-3 สินค้า, login (ถ้าใช้คูปอง) | สินค้าราคาต่าง + coupon | 1.ดู subtotal 2.ค่าส่ง 3.coupon 4.grand total | ยอดจาก `/order/total-payment`: total=(สินค้า+ส่ง−ลด); กทม.ส่งฟรี | `get_total_payment:~1610` |
| TC-CHK-08-R | TC-CHK-08 | Checkout | boundary ข้อความ (param) | UI/API | Boundary | Medium | อยู่ checkout | "ก"×255 / ×256 / emoji / เว้นหน้า-หลัง | 1.กรอกศาลา/ป้าย 2.submit | ≤255 ผ่าน; >255 reject "ยาวได้สูงสุด 255"; trim | `OrderController:store` max:255 |
| TC-PAY-01-R | TC-PAY-01 | Payment | QR/โอน + แจ้งชำระ | Integration | Positive | order รอชำระ (status_payment=0) | bank_id 1-3/QR + สลิป | 1.เปิด `/payment/{tracking_id}` 2.เลือกธนาคาร 3.แนบสลิป | แสดง QR/บัญชี; แจ้งชำระ → `/order/accept-payment-infos`; **ไม่ตัดเงินอัตโนมัติ** | `payment/[tracking_id]`, `accept_payment_infos` |
| TC-PAY-02-R | TC-PAY-02 | Payment | บัตร fee (env) | Integration | Boundary | High | ผ่าน checkout, ยอดทราบค่า | method=2, ยอด=X | 1.เลือกบัตร 2.ดูยอด | fee = X×`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`/100 (**ยืนยันค่า env ไม่ใช่ 3 ตายตัว**) | R2 GAP-15; `get_total_payment:~1625` |
| TC-ORD-01a-R | TC-ORD-01 | Order Success | หน้า success | UI | Positive | order สำเร็จ (sandbox) | tracking_id | 1.เปิด `/payment/success/{tracking_id}` | แสดงเลขออเดอร์/สรุป | `app/payment/success/[tracking_id]` |
| TC-ORD-01b-R | TC-ORD-01 | Order Success | email ยืนยัน | Integration | Positive | order สำเร็จ | email ผู้สั่ง | 1.สั่งสำเร็จ 2.ตรวจเมล | `SendOrderCreatedEmailJob` dispatch + ได้เมล | `OrderController:store:~440` |
| TC-TRK-01a-R | TC-TRK-01 | Tracking | ค้นด้วย tracking_id | Integration | Positive | tracking_id จริง (microservice พร้อม) | tracking_id | 1.เปิด `/tracking?tracking_id=` 2.ค้นหา | แสดงสถานะตาม status_payment | `app/tracking/page.tsx`; service = `Not verifiable from code` |
| TC-AUTH-01-R | TC-AUTH-01 | Auth | สมัครตอน checkout | Integration | Positive | checkout, email ใหม่ | add_to_new_user=1, password ≥8 | 1.ติ๊กสมัคร 2.ตั้ง password 3.สั่ง | `register_new_web_user` สร้าง user; login ภายหลังได้ | `OrderController:register_new_web_user` |
| TC-SRCH-01-R | TC-SRCH-01 | Search | keyword vs UI box | UI | Negative/Exploratory | Medium | — | keyword="ดอกไม้สด" | 1.หา search box (UI) 2.เปิด listing `?keyword=` | **BE รองรับ `?keyword=` (listing กรองได้)**; กล่อง UI = `Not verifiable from code` ต้อง execute | `app/products/page.tsx:62-68` |

---

# Step 3 — Convert Missing Test Cases (R2 High Priority) → Detailed Test Cases

| New TC ID | Source MTC | Module | Feature | Test Level | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Evidence |
|---|---|---|---|---|---|---|---|---|---|---|---|
| TC-CHK-09 | MTC-CHK-09 | Checkout | delivery อดีต | API/UI | Negative | High | มีสินค้า, เลือกวัด | delivery_date=เมื่อวาน, time=12:00 | 1.กรอกวัน-เวลาอดีต 2.กดชำระ/POST order | reject "ไม่สามารถย้อนเวลาไปส่งให้ในอดีตได้..." | `Rules/PossibleDeliveryDateTime.php:22-26` |
| TC-CHK-10 | MTC-CHK-10 | Checkout | delivery < 4 ชม. | API/UI | Boundary | High | มีสินค้า, เลือกวัด | now+3ชม (fail) / now+4ชม (pass) | 1.เลือกเวลาใกล้ 2.submit | <4ชม reject "ไม่สามารถส่งได้ภายใน 4 ชั่วโมง..."; =4ชม ผ่าน | `PossibleDeliveryDateTime.php:29-35` |
| TC-CHK-11 | MTC-CHK-11 | Checkout | delivery > 30 วัน | API | Boundary | Medium | มีสินค้า | now+30วัน (pass) / now+31วัน (fail) | 1.เลือกวันไกล 2.submit | >30วัน reject "...เกิน 30 วัน" | `PossibleDeliveryDateTime.php:38-44` |
| TC-CHK-12 | MTC-CHK-12 | Checkout | slug ไม่มีจริง | API | API Error | High | — | cart slug="not-exist-xxx" | 1.แก้ payload/sessionStorage 2.POST `/api/order` | reject "ไม่พบสินค้าตาม slug ... ในตะกร้า" | `Rules/ProductSlugExists.php:20-31` |
| TC-CHK-13 | MTC-CHK-13 | Checkout | ป้ายน้อยกว่าจำนวน | API/UI | Validation | High | สินค้า amount=2 | กรอก message card 1 ใบ | 1.เพิ่ม 2 ชิ้น 2.กรอกป้าย 1 3.กดชำระ | reject "...จำนวน 2 ชิ้น แต่ระบุข้อความ ... 1" | `OrderController:store` cart.* closure; `validateMessageCards` |
| TC-AUTH-03 | MTC-AUTH-03 | Auth | email ซ้ำตอนสมัคร | API | Negative | มี email ที่ลงทะเบียนแล้ว | add_to_new_user=1, email=ซ้ำ | 1.ติ๊กสมัคร + email ซ้ำ 2.สั่ง | reject "อีเมล์แอดเดรส ... ถูกใช้ไปแล้ว" | `Rules/WebUserExists::validate` |
| TC-AUTH-04 | MTC-AUTH-04 | Auth | token ไม่ถูกต้อง | API | Permission | High | — | web_user_token ปลอม + coupon_code | 1.POST order ด้วย token ผิด | reject "Web User Token ไม่ถูกต้อง" | `WebUserExists::validToken` |
| TC-PROMO-04 | MTC-PROMO-04 | Promotion | guest ใส่คูปอง | Integration | Permission | High | **ไม่ login** | coupon valid | 1.checkout (guest) 2.กรอกคูปอง 3.Apply | "ต้องล๊อคอินเข้าสู่ระบบก่อนค่ะ" | `validate_coupon:1416-1424` |
| TC-PROMO-05 | MTC-PROMO-05 | Promotion | ยอด < discount_min | API | Negative | login, คูปองมี discount_min | ยอด < min | 1.Apply คูปอง | WM21 "ราคารวม...ไม่สามารถประยุกต์ใช้..." | `Controller.php:917-934` |
| TC-PROMO-06 | MTC-PROMO-06 | Promotion | ยอดพอดี min/max | API | Boundary | Medium | login | ยอด=min, =max | 1.Apply | ค่าขอบพอดี **ใช้ไม่ได้** (`>min && <max`) | `Controller.php:918` |
| TC-PROMO-07 | MTC-PROMO-07 | Promotion | คูปองใช้ซ้ำ | Integration | Negative | login + เคยใช้คูปองนี้ (UserCoupon) | coupon used | 1.Apply คูปองเดิม | "ท่านได้ใช้รหัสส่วนลด ... ไปแล้วค่ะ" | `validate_coupon:1426-1438` |
| TC-PROMO-10 | MTC-PROMO-10 | Promotion | re-validate ตอนสั่ง | Integration | API Error | High | login, สลับยอด/คูปองให้ขัด | coupon, cart | 1.Apply ผ่าน 2.กดชำระ | order reject "Error validating coupon code(WME01): ..." | `OrderController:store:~320` |
| TC-CART-06 | MTC-CART-06 | Cart | เกิน 10 ชิ้น | UI | Boundary | High | ตะกร้ามี 10 ชิ้น | เพิ่มชิ้นที่ 11 | 1.กด + จนรวม 11 | แสดง modal, จำกัดไม่เกิน 10 | `AddItemButton:46-52`, `CheckoutForm:107` |
| TC-SHIP-01 | MTC-SHIP-01 | Shipping | allow_delivery=false | Integration | Negative | — | location ค่าส่งพิเศษ | 1.เลือกวัดนั้น | modal "...ติดต่อทีมบริการลูกค้า @wreathmala" | `fetchDeliveryFee:~340` |
| TC-PAY-04 | MTC-PAY-04 | Payment | fee จาก env | Integration | Boundary | High | ผ่าน checkout, ยอดทราบค่า | method=2, ยอด=X | 1.เลือกบัตร 2.ดูยอด | fee=X×env%/100; total+fee แสดงก่อนชำระ | `get_total_payment:~1625` |
| TC-PAY-05 | MTC-PAY-05 | Payment | สลิปบังคับ | API | Validation | High | order รอชำระ | bank_id=1, ไม่มี media_id | 1.POST `/order/accept-payment-infos` ไม่แนบสลิป | reject (media_id required_with bank_id) | `accept_payment_infos:rules` |
| TC-SEC-01 | MTC-SEC-01 | Security | consent bypass | API | Security | High | — | payload ไม่มี privacy_policy_accepted | 1.POST `/api/order` ตรง | **BE ไม่ block → ผ่าน** = ความเสี่ยง; รายงานให้ dev เพิ่ม rule | `OrderController:store` (ไม่มี privacy rule) |
| TC-API-01 | MTC-API-01 | API Error | ERP 422 | Integration | API Error | High | mock ERP คืน 422 | — | 1.submit order | proxy คืน `{error:true,...}` → `openErrorModal` แสดง | `pages/api/order.ts:catch`, `onCreateOrder:else` |
| TC-API-02 | MTC-API-02 | API Error | ERP 500/timeout | Integration | API Error | High | mock ERP คืน 500/timeout | — | 1.submit order/total-payment | modal error, ไม่ crash | `pages/api/total-payment.ts:catch`, instance interceptors |
| TC-SESS-01 | MTC-SESS-01 | Session | 401 handling | Integration | Session | High | login | mock 401 จาก ERP_API | 1.เรียก API ระหว่าง flow | `clearStorage()` + reload | `instance.ts` ERP_API interceptor |
| TC-LOAD-01 | MTC-LOAD-01 | Checkout | double submit | UI | Race Condition | High | กรอกครบ | — | 1.กดชำระเงินรัว ๆ 2 ครั้ง | `isSubmitting` block ครั้งที่ 2, ไม่สร้างออเดอร์ซ้ำ | `CheckoutForm:onSubmit`, `disableButton` |

> หมายเหตุ Test Level: backend-only rule (slug, datetime, email ซ้ำ, token, consent, สลิป) → **API Test**; FE/BE inconsistency (phone, consent) → **ทั้ง UI + API**; logic ที่มีทั้ง 2 ฝั่ง (coupon, payment, cart) → **Integration**

---

# Step 4 — Merge / Split / Remove Recommendation

| Action | Test Case ID(s) | Reason | Recommended New Structure |
|---|---|---|---|
| Rewrite | TC-PDP-04 | assumption ผิด (ริบบิ้นมีจริง) เปลี่ยน module PDP→Checkout | `TC-PDP-04-R` (Checkout/Validation) |
| Split | TC-CART-02 | รวม เพิ่ม/ลด/ลบ/boundary | `TC-CART-02-R` (เพิ่ม/ลด) + `TC-CART-02b-R` (ลบ) + `TC-CART-06` (boundary 10) |
| Split | TC-CART-03 | guest vs login persist ต่างกลไก | `TC-CART-03-R` (guest) + เพิ่ม TC login sync (R2 MTC-CART-07) |
| Split | TC-CHK-04 | FE/BE phone ไม่ตรงกัน | `TC-CHK-04-UI` + `TC-CHK-04-API` |
| Split | TC-CHK-05 | consent FE block vs BE bypass | `TC-CHK-05-UI` + `TC-CHK-05-API` (=TC-SEC-01) |
| Split | TC-ORD-01 | รวม success/email/หลายหน้า | `TC-ORD-01a-R` (success) + `TC-ORD-01b-R` (email) + (thankyou/fail แยกตาม R2 MTC-ORD-02) |
| Split | TC-TRK-01 | รวม 2 path + valid/invalid | `TC-TRK-01a-R` (tracking_id) + TC-TRK-02 (order_code+เบอร์) + TC-TRK-03 (invalid) |
| Merge | TC-PAY-03 + safety note | safety gate ซ้ำกับทุก payment TC | คง `TC-PAY-03` เป็น gate กลาง อ้างในทุก payment TC |
| Parameterize | TC-CHK-02, TC-CHK-03, TC-CHK-08, TC-PROMO-02 | data-driven หลายชุด | ดู Step 5 |
| Keep | TC-CAT-03, TC-CART-04, TC-PDP-02, TC-PAY-03, TC-ERR-01, TC-HOME-02 | คุณภาพดี/critical path | คงเดิม |
| Remove | — (ไม่มี) | ไม่มีเคสซ้ำซ้อนจนต้องลบทิ้ง | — |

> **ไม่ลบเคสใดทิ้ง** — เคสที่ assumption ผิด (PDP-04, SRCH-01, PAY-02) ใช้วิธี Rewrite ให้ตรง code แทนการ Remove

---

# Step 5 — Parameterization Recommendation

| Base TC ID | Parameter Field | Parameter Values | Expected Variation | Reason |
|---|---|---|---|---|
| TC-CHK-10 | delivery datetime | now+3ชม / now+4ชม / now+5ชม | <4ชม fail; ≥4ชม pass | boundary 4 ชม. (`PossibleDeliveryDateTime`) |
| TC-CHK-11 | delivery date | now+30วัน / now+31วัน | ≤30 pass; >30 fail | boundary 30 วัน |
| TC-CART-06 | product quantity | รวม 9 / 10 / 11 | ≤10 ผ่าน; 11 modal | limit 10 (`AddItemButton`) |
| TC-PROMO-02-R | coupon type/case | ไม่พบ / used / ยอด<min / ยอด>max | error ต่างกัน (ไม่พบ/WM21/used) | error ตาม code จริง |
| TC-PROMO-06 | coupon min/max boundary | ยอด=min / min+1 / max−1 / =max | พอดี min,max ใช้ไม่ได้ (strict) | `> min && < max` |
| TC-PROMO-09 | coupon type | amount / percent | บาทคงที่ vs %×ยอด | `discountAmount:1707-1770` |
| TC-CHK-01-R | payment method | method_id 1 / 2 | 1→`/payment/{id}`; 2→`/payment/2c2p/{id}` | `onCreateOrder` branch |
| TC-PAY-06 | bank_id | 0/1/2/3/4 | payment.type map 4/2/3/1/6 | `accept_payment_infos:switch` |
| TC-CHK-04-UI/API | phone format | `0812345678` / `+66812345678` / `02xxxxxxx` / `12345` / `08a2345678` | FE: เฉพาะ `^0\d{9}$`; BE: รับ +66/เบอร์บ้าน | FE/BE inconsistency |
| TC-CHK-03 | email | `a@b.com`,`a.b+c@sub.co.th` (valid) / `abc`,`abc@`,`@x.com` (invalid) | valid ผ่าน; invalid reject | yup `.email()` |
| TC-CHK-08-R | message/text length | "ก"×255 / ×256 / emoji / เว้นหน้า-หลัง | ≤255 ผ่าน; >255 reject; trim | max:255 |
| TC-API-01/02 | API error status | 422 / 500 / timeout / 401 | modal/clear ต่างกัน | proxy + interceptors |
| TC-TRK-01a-R | tracking search type | tracking_id / order_code+phone_or_email / invalid | result/notFound | `tracking/page.tsx:36-44` |
| TC-CHK-01-R | user type | guest / login | login ใช้คูปองได้; guest ไม่ได้ | R1 coupon ต้อง login |

---

# Step 6 — Final Test Case Structure Recommendation

| Section | Recommendation |
|---|---|
| Module grouping | จัดกลุ่มตาม flow จริง: Home → Listing/Search → PDP → Cart → **Checkout (รวม Shipping + Coupon + Message Card + Consent)** → Payment → Order Success → Tracking → Auth → Cross-cutting (API Error/Session/Security/Responsive) |
| Test Case ID convention | `TC-<MODULE>-<NN>` + suffix `-R` (revised), `-UI`/`-API` (test level split); Missing จาก R2 ใช้เลขต่อเนื่อง (CHK-09+); คง map กลับ Original/MTC เสมอ |
| Test Level (ฟิลด์ใหม่) | บังคับทุกเคส: `UI` / `API` / `Integration` / `Manual Exploratory` — backend-only rule = API, inconsistency = UI+API |
| Test Type | คงชุดมาตรฐาน + เพิ่ม `FE/BE Inconsistency`, `Security`, `Race Condition`, `Session`, `API Error`, `Empty State` |
| Priority | High / Medium / Low — High = เปลี่ยน "สั่งได้/ไม่ได้" หรือ "ยอดเงิน" (datetime, coupon, payment fee, double submit) |
| Preconditions | ระบุชัดเจน: user type (guest/login+token), product (slug/allow_add_to_cart/qty), coupon (type/min-max/used), location (ในเขต/นอกเขต/allow_delivery), order status_payment, payment method |
| Test Data | ห้ามกว้าง — อ้างค่า env (`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`), error code จริง (WM21/WME01), data ต้องระบุแหล่ง (dev/sandbox) |
| Expected Result format | ต้องตรวจสอบได้: ระบุ message ไทยตาม code, endpoint/redirect (`/payment/{tracking_id}`), state (localStorage key, status_payment), HTTP code |
| Code Evidence (ฟิลด์ใหม่) | **บังคับทุกเคส** — path:line ของ FE/BE rule ที่รองรับ; ถ้าไม่มี → `Not verifiable from code` |
| Automation Candidate | คงฟิลด์ไว้ (รายละเอียด Playwright เลื่อนไป Round ถัดไป) — ระบุแค่ Yes/Partial/No |
| Traceability (ฟิลด์ใหม่) | map: Scenario ID ↔ Original TC ↔ MTC/GAP ID ↔ Code Evidence ↔ Defect (ปิด DEF-003/004 ที่ assumption ผิด) |

### หมายเหตุปิดท้าย — รายการที่ยัง `Not verifiable from code`
- **Tracking microservice** (`/track-order`) — source ไม่อยู่ใน repo → TC-TRK-* ต้องขอ spec
- **กล่อง Search UI** — BE รองรับ `keyword` แต่ต้อง execute หน้าเว็บยืนยัน (TC-SRCH-01-R)
- **ค่า env จริง** (fee %, excluded tags, min/max price default) — ขอจาก dev ก่อน assert ตัวเลข
- **XSS/SQLi sanitize, 2C2P gateway, email/SMS ส่งจริง** — ต้อง execute/sandbox

### สิ่งที่ควรทำต่อ (Round 4)
1. Playwright Automation Recommendation (POM, data-driven จาก Step 5, mock API/payment) — เลื่อนสะสมจาก R1/R3
2. ออก Test Plan ฉบับ refactor เต็มตาม structure Step 6 (รวม revised + new TC ทั้งหมด)
3. ประสาน dev ปิด defect จริง: consent ที่ BE (TC-SEC-01), FE/BE phone regex (TC-CHK-04), cleanup messageCard keys
4. ยืนยัน/ปิด DEF-001 (search UI), DEF-003 (ริบบิ้น — assumption ผิด), DEF-004 (วันที่ — assumption ผิด) กับ PO
