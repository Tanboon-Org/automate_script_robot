# QA Round 2 — Coverage Gap Analysis & Missing Test Cases
## Order Flow: หรีด ณ วัด (Wreath Na Wat)

| | |
|---|---|
| **ระบบ** | หรีด ณ วัด (Wreath Na Wat) — ร้านขายพวงหรีด/ดอกไม้งานศพออนไลน์ |
| **อ้างอิง** | `QA-WreathNaWat-OrderFlow-CodeMap-Traceability.md` (Round 1), `QA-WreathNaWat-OrderFlow-TestPlan.md` |
| **ขอบเขตรอบนี้** | Coverage Gap Analysis + Missing Test Cases (อิง code evidence เท่านั้น) |
| **วันที่** | 2026-06-25 |
| **ผู้จัดทำ** | Senior QA Automation Engineer / Test Architect |

> **กฎ:** ทุก gap/missing test case อ้างอิง code evidence จริง — ไม่เดา behavior, ไม่แก้ Test Case เดิม, ไม่ทำ Automation Recommendation ละเอียดในรอบนี้

### หลักฐานใหม่ที่พบเพิ่มใน Round 2 (เสริมจาก Round 1)

| Evidence | File | สาระสำคัญ |
|---|---|---|
| กฎวัน/เวลาจัดส่ง | `backend/erp/app/Rules/PossibleDeliveryDateTime.php` | **ต้องเป็นอนาคต**, **ห่างจากนี้ ≥ 4 ชม.**, **ล่วงหน้า ≤ 30 วัน** |
| สินค้าใน cart ต้องมีจริง | `backend/erp/app/Rules/ProductSlugExists.php` | slug ไม่พบ → 404 → "ไม่พบสินค้าตาม slug ..." |
| email ซ้ำตอนสมัคร | `backend/erp/app/Rules/WebUserExists.php::validate` | เช็ค **เฉพาะเมื่อ add_to_new_user=true** ผ่าน WEB_API |
| ตรวจ token | `WebUserExists::validToken` | `web_user_token` ผิด → "Web User Token ไม่ถูกต้อง" |
| ช่วงราคาคูปอง | `backend/erp/app/Http/Controllers/Controller.php:870-945` | **min < ยอดรวม < max (strict)**; error `WM21`; campaign/universal; type amount/percent |
| discount_min/max/type | `StoreController.php:1681-1850 (discountAmount)` | tag `discount_min`,`discount_max`,`discount`,`discount_campaign` |
| sort mapping | `frontend/src/utils/filter.ts:41-42,86` | `'แนะนำ'→recommend`, `'ช่วงราคา'→price` |

---

# Step 1 — Coverage Analysis by Module

| Module | Existing Coverage | Missing Coverage | Code Evidence | Risk Level | Recommendation |
|---|---|---|---|---|---|
| Home | TC-HOME-01/02 (เมนู/แบนเนอร์/โซเชียล) | section ขายดี/ส่งด่วน load จาก `getControlProductList` | `src/app/page.tsx`, `api/product:getControlProductList` | Low | เพิ่ม smoke ตรวจ section render |
| Category / Listing | TC-CAT-01/03/04/05 | exclude tags (`EXCLUDED_TAGS`), `random_order`, perpage default | `StoreController::_products`, `process_excluded_tags` | Medium | เพิ่ม TC ตรวจสินค้า excluded ไม่โผล่ |
| Sort | TC-CAT-02 (กว้าง) | mapping ค่า sort จริง (recommend/price), คงค่าใน URL | `filter.ts:41-42`, `parseCurrentFiltersFromUrl` | Medium | data-driven ตาม mapping จริง |
| Search | TC-SRCH-01 (สมมติว่าไม่มี) | **`?keyword=` ทำงานจริง** + ไม่มีกล่อง UI | `app/products/page.tsx:62-68`, `StoreController` keyword | Medium | แยกเป็น 2 เคส: UI box (ไม่มี) vs keyword param (มี) |
| Product Detail | TC-PDP-01/02/03 | `allow_add_to_cart=false` → ซ่อนปุ่ม Buy Now/แสดง LINE; ราคา promotion vs regular | `ProductButton:131-150` (`price_status.allow_add_to_cart`) | Medium | เพิ่ม TC สินค้าที่สั่งไม่ได้ |
| Cart | TC-CART-01..05 | **limit รวม ≤ 10** (modal), guest↔login sync (`synUserCart`), remove ลบ messageCard keys | `AddItemButton:46-52`, `cart.ts:25-48`, `useCart:36-53` | High | เพิ่ม boundary 10/11 + sync cart |
| Coupon / Promotion | TC-PROMO-01/02/03 | **ต้อง login**, **uppercase**, **ช่วงราคา min/max (WM21)**, amount/percent, campaign/universal, ใช้ซ้ำ (UserCoupon), double-validate ตอน order | `validate_coupon:1356`, `Controller.php:870-945`, `discountAmount`, `OrderController:store` (re-validate) | High | ครอบ negative cases ตาม error code จริง |
| Login / Register / Guest | TC-AUTH-01/02 | **email ซ้ำตอนสมัคร**, token ไม่ถูกต้อง, guest checkout (ไม่มี token) | `WebUserExists::validate/validToken`, `register_new_web_user` | High | เพิ่ม TC สมัครด้วย email ซ้ำ + token invalid |
| Address (วัด/จัดส่ง) | (ฝังใน CHK) | slug/location_id ไม่มีจริง (`exists:ab_locations,id`), ≥1 ใน {ผู้เสียชีวิต/ศาลา/เบอร์} | `OrderController:store`, `ProductSlugExists` | High | เพิ่ม TC location ผิด + required_without_all |
| Checkout | TC-CHK-01..08 | **delivery datetime: past / <4ชม / >30วัน**, slug invalid, message card count ≤ attachments, member password | `PossibleDeliveryDateTime.php`, `OrderController:store`, `validateMessageCards` | High | gap ใหญ่ที่สุด — เพิ่มหลาย TC |
| Shipping | TC-CHK-06 (รวม) | `allow_delivery=false` → modal, 6 จังหวัด hardcoded, ค่าส่งตาม location | `CheckoutForm:onChangeWat:248`, `fetchDeliveryFee`, `LocationController` | High | แยก TC ในเขต/นอกเขต/allow_delivery=false |
| Payment | TC-PAY-01/02/03 | **fee จาก env**, bank_id map (0-6), QR vs โอน vs บัตร, `merge_order_item.remain` | `get_total_payment:~1625`, `accept_payment_infos:switch` | High | เพิ่ม TC คำนวณ fee + ชำระบางส่วน |
| Order Success | TC-ORD-01 (กว้าง) | success/thankyou/fail แยกหน้า, email job, tracking_id แสดง | `app/payment/{success,thankyou,fail}`, `SendOrderCreatedEmailJob` | Medium | แยก TC 3 หน้า + email |
| Order History / Tracking | TC-TRK-01 | microservice แยก, status_payment branch (0/1 vs 2/3/4), tax invoice module flag | `app/tracking/page.tsx:140-160`, `TRACK_ORDER_API` | Medium | ขอ spec service; TC ตาม status |
| API Error Handling | — (ไม่มี) | 422/500/404 จาก ERP, proxy error shape `{error:true,...}` | `pages/api/order.ts:catch`, `instance.ts` interceptors | High | เพิ่ม TC mock API error |
| Validation | TC-CHK-02/03/04/08 | **FE/BE inconsistency (phone)**, BE max:255, regex line_id | `validation/checkout.ts` vs `OrderController:store` | High | เพิ่ม TC ระดับ API |
| Empty State | TC-CART-01, TC-CAT-05 | checkout เมื่อ `sessionStorage.checkoutProduct` ว่าง/หาย | `contexts/checkout:getProductPayload` (`'{}'` fallback) | Medium | เพิ่ม TC เปิด /checkout ตรงโดยไม่มีสินค้า |
| Loading State | — (ไม่มี) | `isSubmitting`, `disableButton`, `loading` ใน payment page | `CheckoutForm:isSubmitting`, `payment/[tracking_id]:loading` | Medium | เพิ่ม TC ปุ่ม disable ระหว่างส่ง |
| Permission / Authorization | TC ไม่มี | ERP routes `role:admin` แต่ FE ใช้ service key; direct API ไม่มี key | `routes/api.php`, `pages/api/*` | Medium | TC เรียก /api/* โดยไม่ผ่าน flow |
| Session / Token / LocalStorage | TC-CART-03 (persist) | 401 → `clearStorage()`+reload, token expire, messageCard keys ค้าง | `instance.ts` interceptors, `useCart:removeProductItemFromCart` | High | เพิ่ม TC token หมดอายุ + cleanup |
| Responsive / Cross Browser | TC-ERR-02 (กว้าง) | mobile summary, datepicker, hamburger | `CartSummaryMobile`, `MobileOrderSummary` | Low | คงไว้ตามเดิม |
| Security Negative | TC-CHK-07 (กว้าง) | **consent bypass (BE ไม่ enforce)**, phone bypass FE, coupon โดยไม่ login ผ่าน API | `OrderController:store` (ไม่มี privacy rule) | High | เพิ่ม TC API-level bypass |

---

# Step 2 — Missing Coverage from Code

| Gap ID | Module | Missing Logic / Scenario | Code Evidence | Existing TC Related | Risk | Why It Matters |
|---|---|---|---|---|---|---|
| GAP-01 | Checkout | จัดส่ง **เวลาเป็นอดีต** ถูก reject | `PossibleDeliveryDateTime.php:22-26` | TC-CHK-01 | High | ป้องกันส่งย้อนเวลา — ไม่มี TC เลย |
| GAP-02 | Checkout | จัดส่ง **ภายใน < 4 ชม.** ถูก reject | `PossibleDeliveryDateTime.php:29-35` | — | High | กฎผลิตทันรอบ — ไม่มี TC; สอดคล้อง slot 17/18/19:00 |
| GAP-03 | Checkout | จัดส่ง **ล่วงหน้า > 30 วัน** ถูก reject | `PossibleDeliveryDateTime.php:38-44` | — | Medium | boundary 30 วัน — ไม่มี TC |
| GAP-04 | Checkout/Cart | **slug สินค้าไม่มีจริง** → order ถูก reject 404 | `ProductSlugExists.php:20-31` | — | High | cart เก่า/สินค้าถูกลบ → order fail |
| GAP-05 | Auth | **สมัครด้วย email ที่มีในระบบ** (add_to_new_user=1) → reject | `WebUserExists.php:validate` | TC-AUTH-01 | High | สมัครซ้ำ — ไม่มี TC |
| GAP-06 | Auth | **web_user_token ไม่ถูกต้อง** → reject ตอน order | `WebUserExists::validToken` | — | High | token ปลอม/หมดอายุใช้คูปอง |
| GAP-07 | Coupon | **ยอดรวมต่ำกว่า discount_min / สูงกว่า discount_max** → WM21 | `Controller.php:917-934` | TC-PROMO-02 | High | minimum spend — Test Plan ระบุแต่ไม่มี evidence rule |
| GAP-08 | Coupon | **boundary ช่วงราคา (strict `> min` และ `< max`)** ค่าพอดี min/max ใช้ไม่ได้ | `Controller.php:918` (`> min && < max`) | — | Medium | ค่าขอบพอดี = ใช้ไม่ได้ (off-by-one) |
| GAP-09 | Coupon | **คูปองแบบ amount vs percent** หักต่างกัน | `discountAmount:1707-1770` | TC-PROMO-01 | Medium | สูตรหักต่างชนิด |
| GAP-10 | Coupon | **คูปอง campaign** ผูกกับ tag สินค้า (subset) | `discountAmount:1700-1745`, `is_coupon_tag_subset_of_product_tags` | — | Medium | คูปองเฉพาะแคมเปญ |
| GAP-11 | Coupon | **ใช้คูปองซ้ำ** (เคยใช้แล้ว) → reject | `validate_coupon:1426-1438` (UserCoupon count) | TC-PROMO-02 | High | ต้อง login + เคยใช้ |
| GAP-12 | Coupon | **คูปองถูก re-validate ซ้ำตอน create order** (WME01) | `OrderController:store:~320` | — | High | ใส่คูปองถูกตอนคำนวณ แต่ fail ตอนสั่ง |
| GAP-13 | Coupon | **guest ใส่คูปอง** → "ต้องล๊อคอินเข้าสู่ระบบก่อนค่ะ" | `validate_coupon:1416-1424` | TC-PROMO-01 | High | FE/flow ไม่ได้บังคับ login ก่อน |
| GAP-14 | Coupon | **coupon case-insensitive** (strtoupper) | `validate_coupon:1369`, `get_total_payment` | TC-PROMO-03 | Low | พิมพ์เล็กต้องใช้ได้ |
| GAP-15 | Payment | **credit card fee = total × env%** (ไม่ใช่ 3 ตายตัว) | `get_total_payment:~1625` | TC-PAY-02 | High | assert ค่าจริงจาก env ไม่ hardcode |
| GAP-16 | Payment | **bank_id map 0-6 → payment.type** | `accept_payment_infos:switch` | TC-PAY-01 | Medium | เลือกธนาคารผิด type |
| GAP-17 | Payment | **media_id required_with bank_id** (โอน/QR ต้องมีสลิป) | `accept_payment_infos:rules` | TC-PAY-01 | High | upload สลิปบังคับ |
| GAP-18 | Payment | **ชำระบางส่วน → merge_order_item.remain** | `accept_payment_infos:~1120` | — | Medium | ยอดคงค้าง partial payment |
| GAP-19 | Payment | **status_payment = 1(โอน)/2(บัตร)** หลังแจ้งชำระ | `accept_payment_infos:~1010` | TC-PAY-01 | Medium | สถานะถูกตั้งต่างกัน |
| GAP-20 | Payment | **transfer_date/time format Y-m-d / H:i** ผิด → reject | `accept_payment_infos:rules` | — | Medium | validation วันโอน |
| GAP-21 | Payment | **payment_fails endpoint** ส่งเมล fail | `payment_fails:1147` | — | Medium | 2C2P fail callback |
| GAP-22 | Payment(2C2P) | **amount padding 12 หลัก + HMAC hash** | `get_2c2p_payment_infos:~872` | TC-PAY-03 | Low | ความถูกต้องยอดส่ง gateway |
| GAP-23 | Checkout | **message card: count > sizeof(attachments)** → reject | `OrderController:store` (cart.* closure), `validateMessageCards` | TC-PDP-04 | High | สั่ง 2 ชิ้น แต่กรอกป้าย 1 |
| GAP-24 | Checkout | **attached_message_1/2 max 255** | `OrderController:store` rules | TC-CHK-08 | Medium | boundary ข้อความป้าย |
| GAP-25 | Validation | **phone FE `^0\d{9}$` vs BE regex (+66/เว้นวรรค)** | `validation/checkout.ts` vs `OrderController:store` | TC-CHK-04 | High | FE/BE inconsistency |
| GAP-26 | Security | **consent privacy enforce เฉพาะ FE — BE ไม่มี rule** | `OrderController:store` (ไม่มี privacy_policy) | TC-CHK-05 | High | bypass ผ่าน API ได้ |
| GAP-27 | Security | **เบอร์ผิดรูปแบบ FE แต่ผ่าน BE** ผ่าน API ตรง | เทียบ regex 2 ฝั่ง | TC-CHK-04 | Medium | bypass FE validation |
| GAP-28 | Cart | **boundary 10/11 ชิ้น** modal + disable | `AddItemButton:46-52`, `CheckoutForm:107` | TC-CART-02 | High | limit ตะกร้าไม่มี TC boundary |
| GAP-29 | Cart | **guest cart → login sync (synUserCart)** | `cart.ts:25-48` | TC-CART-03 | Medium | login แล้วของในตะกร้าหาย/รวม |
| GAP-30 | Session | **401 → clearStorage()+reload** | `instance.ts` ERP_API interceptor | — | High | token หมดอายุกลางคัน |
| GAP-31 | Session | **messageCard keys ค้างใน localStorage** หลังลบสินค้า/สั่งสำเร็จ | `useCart:43-53`, `onCreateOrder:cleanup` | — | Medium | ข้อมูลป้ายเก่ารั่วไปออเดอร์ใหม่ |
| GAP-32 | Empty State | **เปิด /checkout โดยไม่มี checkoutProduct** | `contexts/checkout:getProductPayload` (`'{}'`) | TC-CART-01 | Medium | เข้าตรง URL ไม่มีสินค้า |
| GAP-33 | Loading | **double submit ระหว่าง isSubmitting** | `CheckoutForm:onSubmit:setIsSubmitting`, `disableButton` | — | High | กดชำระซ้ำ → ออเดอร์ซ้ำ |
| GAP-34 | API Error | **ERP คืน 422/500 → proxy `{error:true}` → modal** | `pages/api/order.ts:catch`, `onCreateOrder:else` | — | High | error path ไม่มี TC |
| GAP-35 | Shipping | **allow_delivery=false → modal "ติดต่อ @wreathmala"** | `fetchDeliveryFee:~340` | TC-CART-05 | High | location มีค่าส่งพิเศษ |
| GAP-36 | Product | **allow_add_to_cart=false → ซ่อนปุ่ม + LINE** | `ProductButton:131-150` | TC-PDP-02 | Medium | สินค้าหมด/สั่งไม่ได้ |
| GAP-37 | Tracking | **ค้นด้วย order_code + phone_or_email** (ไม่ใช่ tracking_id) | `app/tracking/page.tsx:36-44` | TC-TRK-01 | Medium | path ที่ 2 ของ tracking |
| GAP-38 | Tracking | **ข้อมูลผิด → notFound branch** | `app/tracking/page.tsx:55-58` | TC-TRK-01 | Medium | negative tracking |
| GAP-39 | Order | **order ซ้ำเมื่อ submit สำเร็จแต่ network ขาด** (web_order pending) | `OrderController:store:104-110` | — | Medium | race / retry สร้าง web_order ซ้ำ |
| GAP-40 | Checkout | **สมัครสมาชิก: password < 8 / ไม่ match** | `OrderController:store` (password min:8, confirmation same) + `CheckoutForm:502-508` | TC-AUTH-01 | Medium | validation password |

---

# Step 3 — Suggested Missing Test Cases

> ทุกเคส **ห้าม** ทำ transaction จริง — payment ใช้ sandbox/หยุดก่อนยืนยัน

| Suggested TC ID | Module | Feature / Logic from Code | Test Type | Priority | Preconditions | Test Data | Test Steps | Expected Result | Code Reference / Evidence |
|---|---|---|---|---|---|---|---|---|---|
| MTC-CHK-09 | Checkout | จัดส่งเวลาเป็นอดีต | Negative | High | มีสินค้า, เลือกวัด | delivery_date/time = เมื่อวาน | กรอกวันเวลาในอดีต → กดชำระ | reject "ไม่สามารถย้อนเวลาไปส่งให้ในอดีตได้" | `PossibleDeliveryDateTime.php:22-26` |
| MTC-CHK-10 | Checkout | จัดส่งภายใน < 4 ชม. | Boundary | High | มีสินค้า | เวลา = now+3ชม / now+4ชม | เลือกเวลาน้อยกว่า 4 ชม. | <4ชม reject; =4ชม ผ่าน | `PossibleDeliveryDateTime.php:29-35` |
| MTC-CHK-11 | Checkout | จัดส่งล่วงหน้า > 30 วัน | Boundary | Medium | มีสินค้า | now+30วัน / now+31วัน | เลือกวันไกล | >30วัน reject "...เกิน 30 วัน" | `PossibleDeliveryDateTime.php:38-44` |
| MTC-CHK-12 | Checkout/Cart | slug สินค้าไม่มีจริง | API Error | High | mock cart มี slug ปลอม | slug="not-exist-xxx" | ส่ง order ผ่าน API/แก้ sessionStorage | reject "ไม่พบสินค้าตาม slug ..." | `ProductSlugExists.php:20-31` |
| MTC-CHK-13 | Checkout | สั่ง N ชิ้น แต่กรอกป้าย < N | Validation | High | สินค้า 1 รายการ amount=2 | กรอก message card แค่ 1 | กดชำระ | reject "...จำนวน 2 ชิ้น แต่ระบุข้อความ ... 1" | `OrderController:store` (cart.* closure) |
| MTC-CHK-14 | Checkout | attached_message ยาว > 255 | Boundary | Medium | — | message1 = "ก"×256 | กรอกป้าย submit | reject "...ยาวได้สูงสุดไม่เกิน 255" | `OrderController:store` rules |
| MTC-AUTH-03 | Auth | สมัครด้วย email ที่มีในระบบ | Negative | High | มี email ที่ลงทะเบียนแล้ว | add_to_new_user=1, email=ซ้ำ | ติ๊กสมัครสมาชิก + email ซ้ำ | reject "อีเมล์แอดเดรส ... ถูกใช้ไปแล้ว" | `WebUserExists::validate` |
| MTC-AUTH-04 | Auth | web_user_token ไม่ถูกต้อง | Permission | High | — | token ปลอม + coupon_code | ส่ง order ด้วย token ผิด | reject "Web User Token ไม่ถูกต้อง" | `WebUserExists::validToken` |
| MTC-AUTH-05 | Auth | สมัคร: password < 8 / ไม่ตรง | Validation | Medium | checkout | password="123" | ติ๊กสมัคร + password สั้น | reject "รหัสผ่านต้องยาวอย่างน้อย 8" | `OrderController:store`, `CheckoutForm:502` |
| MTC-PROMO-04 | Coupon | guest ใส่คูปอง (ไม่ login) | Permission | High | ไม่ login | coupon=valid | กรอกคูปอง + Apply | "ต้องล๊อคอินเข้าสู่ระบบก่อนค่ะ" | `validate_coupon:1416-1424` |
| MTC-PROMO-05 | Coupon | ยอดต่ำกว่า discount_min | Negative | High | login, คูปองมี discount_min | ยอด < min | Apply คูปอง | WM21 "ราคารวม...ไม่สามารถประยุกต์ใช้..." | `Controller.php:917-934` |
| MTC-PROMO-06 | Coupon | ยอดพอดี = min / = max (strict) | Boundary | Medium | login | ยอด = min, = max | Apply | ค่าขอบพอดี **ใช้ไม่ได้** (`>` และ `<`) | `Controller.php:918` |
| MTC-PROMO-07 | Coupon | คูปองใช้ซ้ำ (เคยใช้แล้ว) | Negative | High | login + เคยใช้คูปองนี้ | coupon=used | Apply | "ท่านได้ใช้รหัสส่วนลด ... ไปแล้วค่ะ" | `validate_coupon:1426-1438` |
| MTC-PROMO-08 | Coupon | คูปองพิมพ์เล็ก | Validation | Low | login | coupon="abc123" (จริง=ABC123) | Apply ด้วยตัวเล็ก | ใช้ได้ (strtoupper) | `validate_coupon:1369` |
| MTC-PROMO-09 | Coupon | คูปอง type amount vs percent | Positive | Medium | login | คูปอง amount + คูปอง percent | Apply แต่ละแบบ ดูยอดหัก | amount = บาทคงที่; percent = %×ยอด | `discountAmount:1707-1770` |
| MTC-PROMO-10 | Coupon | คูปอง valid ตอนคำนวณ แต่ fail ตอนสั่ง | Integration | High | login | สลับยอด/คูปองให้ขัด | Apply ผ่าน → กดชำระ | order reject "Error validating coupon code(WME01)" | `OrderController:store:~320` |
| MTC-CART-06 | Cart | เพิ่มจนเกิน 10 ชิ้น | Boundary | High | ตะกร้ามี 10 | เพิ่มชิ้นที่ 11 | กด + | แสดง modal, ไม่เพิ่มเกิน 10 | `AddItemButton:46-52` |
| MTC-CART-07 | Cart | guest cart → login sync | Integration | Medium | guest มีของในตะกร้า | login | เพิ่มของ (guest) → login | cart merge ไม่หาย (`synUserCart`) | `cart.ts:25-48` |
| MTC-CART-08 | Session | ลบสินค้า → ลบ messageCard keys | Session | Medium | มีของ + กรอกป้าย | — | ลบสินค้าออกจาก cart | localStorage `messageCardModal-*` ถูกลบ | `useCart:43-53` |
| MTC-SHIP-01 | Shipping | location allow_delivery=false | Negative | High | — | location ที่มีค่าส่งพิเศษ | เลือกวัดนั้น | modal "...ติดต่อทีมบริการลูกค้า @wreathmala" | `fetchDeliveryFee:~340` |
| MTC-SHIP-02 | Shipping | นอก 6 จังหวัด → LINE | Negative | High | — | วัดต่างจังหวัด | เลือกวัด | disable ปุ่ม + modal LINE | `CheckoutForm:onChangeWat:248` |
| MTC-PAY-04 | Payment | credit card fee = total × env% | Boundary | High | ผ่าน checkout | ยอดทราบค่า + method=2 | เลือกบัตร ดูยอด | fee = total×`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`/100 (ยืนยันค่า env) | `get_total_payment:~1625` |
| MTC-PAY-05 | Payment | โอน/QR ต้องแนบสลิป (media_id) | Validation | High | order รอชำระ | bank_id=1, ไม่แนบสลิป | แจ้งชำระไม่แนบไฟล์ | reject (media_id required_with bank_id) | `accept_payment_infos:rules` |
| MTC-PAY-06 | Payment | bank_id map → payment.type | Positive | Medium | order รอชำระ | bank_id 1/2/3/4 | แจ้งชำระแต่ละธนาคาร | payment.type map ถูก (2/3/1/6) | `accept_payment_infos:switch` |
| MTC-PAY-07 | Payment | status_payment โอน=1 / บัตร=2 | Positive | Medium | order รอชำระ | โอน vs 2c2p | แจ้งชำระ | status_payment = 1 (โอน) / 2 (บัตร) | `accept_payment_infos:~1010` |
| MTC-PAY-08 | Payment | ชำระบางส่วน → remain | Boundary | Medium | order ยอด X | price < X | แจ้งชำระน้อยกว่ายอด | merge_order_item.remain = X − price | `accept_payment_infos:~1120` |
| MTC-PAY-09 | Payment | transfer_date/time ผิดรูปแบบ | Validation | Medium | order รอชำระ | date="2026/01/01" | แจ้งชำระ format ผิด | reject "...รูปแบบ Y-m-d / H:i" | `accept_payment_infos:rules` |
| MTC-PAY-10 | Payment | 2C2P fail → payment_fails | API Error | Medium | order รอชำระ | success=false, tracking_id | callback fail | ส่งเมล fail, return ok | `payment_fails:1147` |
| MTC-ORD-02 | Order Success | หน้า success/thankyou/fail แยก | Positive | Medium | order สำเร็จ (sandbox) | tracking_id | เปิดแต่ละหน้า | render ถูกตาม route | `app/payment/{success,thankyou,fail}` |
| MTC-ORD-03 | Order Success | ส่งอีเมลยืนยันหลังสั่ง | Integration | Medium | order สำเร็จ | email ผู้สั่ง | สั่งสำเร็จ | `SendOrderCreatedEmailJob` ถูก dispatch | `OrderController:store:~440` |
| MTC-TRK-02 | Tracking | ค้นด้วย order_code + เบอร์/อีเมล | Positive | Medium | order จริง | order_code + phone_or_email | กรอกคู่ข้อมูล | แสดงสถานะ | `app/tracking/page.tsx:36-44` |
| MTC-TRK-03 | Tracking | ข้อมูลผิด → notFound | Negative | Medium | — | tracking_id ปลอม | ค้นหา | branch notFound, ไม่ leak ข้อมูล | `app/tracking/page.tsx:55-58` |
| MTC-TRK-04 | Tracking | branch ตาม status_payment | Positive | Medium | order หลายสถานะ | status 0/1 vs 2/3/4 | เปิด tracking | 0/1→`result-notpayment`; 2-4→`result` | `app/tracking/page.tsx:140-160` |
| MTC-SEC-01 | Security | consent bypass ผ่าน API | Security | High | — | payload ไม่มี privacy_policy | POST `/api/order` ตรง | **BE ไม่ block** (ไม่มี rule) → ความเสี่ยง | `OrderController:store` (ไม่มี privacy rule) |
| MTC-SEC-02 | Security | phone bypass FE ผ่าน API | FE/BE Inconsistency | Medium | — | phone="+66812345678" | ส่งตรงผ่าน API | FE reject แต่ BE รับ | `validation/checkout.ts` vs `OrderController:store` |
| MTC-SEC-03 | Security | XSS/SQLi ในป้าย/ศาลา | Security | Medium | — | `<script>`, `' OR '1'='1` | กรอก submit | Eloquent parameterized; ตรวจไม่ execute/ไม่ 500 | `OrderController:store` (ไม่พบ explicit sanitize) |
| MTC-API-01 | API Error | ERP คืน 422 → modal | API Error | High | mock ERP 422 | — | submit order | `{error:true}` → openErrorModal | `pages/api/order.ts:catch`, `onCreateOrder:else` |
| MTC-API-02 | API Error | ERP คืน 500/timeout | API Error | High | mock ERP 500 | — | submit/total-payment | modal error, ไม่ crash | `pages/api/total-payment.ts:catch`, instance interceptors |
| MTC-SESS-01 | Session | 401 → clearStorage+reload | Session | High | login | mock 401 จาก ERP_API | เรียก ระหว่าง flow | clearStorage + reload | `instance.ts` ERP_API interceptor |
| MTC-LOAD-01 | Loading/Race | double submit ปุ่มชำระ | Race Condition | High | กรอกครบ | — | กดชำระเงินรัว ๆ 2 ครั้ง | `isSubmitting` block ครั้งที่ 2, ไม่สร้างออเดอร์ซ้ำ | `CheckoutForm:onSubmit`, `disableButton` |
| MTC-EMPTY-01 | Empty State | เปิด /checkout ไม่มีสินค้า | Empty State | Medium | ตะกร้าว่าง | — | เข้า `/checkout` ตรง | จัดการ `'{}'` fallback, ไม่ crash | `contexts/checkout:getProductPayload` |
| MTC-PDP-05 | Product | สินค้า allow_add_to_cart=false | Negative | Medium | สินค้าที่สั่งไม่ได้ | — | เปิด PDP | ซ่อนปุ่ม Buy Now, แสดงลิงก์ LINE | `ProductButton:131-150` |
| MTC-CAT-06 | Category | สินค้า EXCLUDED_TAGS ไม่แสดง | Negative | Medium | — | หมวดที่มี excluded tag | เปิด listing | สินค้า excluded ไม่โผล่ | `StoreController::process_excluded_tags` |

---

# Step 4 — High-risk Area Summary

| Area | Risk | Missing Test Coverage | Impact if Not Tested | Recommended Action |
|---|---|---|---|---|
| Checkout (delivery datetime) | High | past / <4ชม / >30วัน (GAP-01..03) | สั่งวัน-เวลาที่ส่งจริงไม่ได้ → ออเดอร์เสีย/ส่งผิดงานศพ | เพิ่ม MTC-CHK-09/10/11 ก่อน regression |
| Order creation (slug/qty/card) | High | slug invalid, count>attachments (GAP-04, GAP-23) | สั่งสำเร็จแต่ของไม่มี/ป้ายไม่ครบ | MTC-CHK-12/13 |
| Coupon validation | High | min/max, ใช้ซ้ำ, guest, re-validate (GAP-07,11,12,13) | หักส่วนลดผิด/รายได้รั่ว/UX พัง | MTC-PROMO-04..10 |
| Payment | High | fee env%, สลิปบังคับ, status, remain (GAP-15,17,18,19) | คิดเงินผิด/รับชำระไม่ครบ | MTC-PAY-04..09 |
| Upload slip / accept payment | High | media required, transfer date, partial (GAP-17,18,20) | แจ้งชำระไม่ผ่าน/ยอดคงค้างผิด | MTC-PAY-05/08/09 |
| Tracking | Medium | order_code+เบอร์, notFound, status branch (GAP-37,38) | ลูกค้าติดตามไม่ได้/leak ข้อมูล | MTC-TRK-02/03/04 (ขอ spec service) |
| FE/BE validation inconsistency | High | phone FE≠BE (GAP-25,27) | ข้อมูลผิดเข้าระบบผ่าน API | MTC-SEC-02 |
| Consent bypass | High | BE ไม่ enforce privacy (GAP-26) | PDPA compliance เสี่ยง bypass | MTC-SEC-01 + แจ้ง dev เพิ่ม rule |
| Session / token | High | 401 clear+reload, token expire (GAP-30) | ผู้ใช้ค้างกลาง flow/ข้อมูลหาย | MTC-SESS-01 |
| API error handling | High | 422/500/timeout (GAP-34) | error เงียบ/หน้า crash | MTC-API-01/02 |
| Race / double submit | High | กดชำระซ้ำ (GAP-33,39) | ออเดอร์ซ้ำ/ตัดเงินซ้ำ | MTC-LOAD-01 |

---

# Step 5 — Test Data Required for Missing Coverage

| Test Data Type | Required Data | Used By Suggested TC | Source / Setup Method | Notes |
|---|---|---|---|---|
| Test user (login ได้) | email+password + `web_user_token` | MTC-PROMO-04..10, MTC-AUTH-04, MTC-SESS-01 | ทีม dev สร้างใน WEB_API | คูปองทุกเคสต้อง login |
| Guest user | ไม่มี token | MTC-PROMO-04, MTC-EMPTY-01 | เปิด incognito | ทดสอบ guest checkout |
| Product in stock / สั่งได้ | slug + `allow_add_to_cart=true` | MTC-CHK-13, MTC-CART-06 | จาก ERP listing | — |
| Product สั่งไม่ได้ | `allow_add_to_cart=false` | MTC-PDP-05 | ขอจาก dev/หา product หมด | — |
| Product slug ปลอม | slug ไม่มีจริง | MTC-CHK-12 | แก้ sessionStorage/payload | API-level |
| Product qty > 10 | ใส่จนรวม 11 | MTC-CART-06 | เพิ่มในตะกร้า | boundary 10/11 |
| Product + attachment/ป้าย | สินค้า amount≥2 | MTC-CHK-13, MTC-CHK-14 | กรอก message card | count>attachments |
| Valid coupon (amount) | code + tag `discount=amount` | MTC-PROMO-09 | ทีม dev | — |
| Valid coupon (percent) | code + tag `discount=percent` | MTC-PROMO-09 | ทีม dev | — |
| Coupon มี discount_min/max | code + tag `discount_min`,`discount_max` | MTC-PROMO-05/06 | ทีม dev | boundary ราคา |
| Coupon campaign | code + tag `discount_campaign` + สินค้า tag ตรง | MTC-PROMO-09/10 | ทีม dev | subset matching |
| Invalid / used coupon | code หมดอายุ + code ที่ user ใช้แล้ว (UserCoupon) | MTC-PROMO-07 | ทีม dev set UserCoupon | ต้อง login |
| Shipping ใน 6 จังหวัด | location_id กทม./ปริมณฑล | MTC-PAY-04, MTC-CHK-* | ERP `/location/province` | ค่าส่งฟรี |
| Shipping นอก 6 จังหวัด | วัดต่างจังหวัด | MTC-SHIP-02 | จาก wat search | → LINE |
| Location allow_delivery=false | location ที่มีค่าส่งพิเศษ | MTC-SHIP-01 | ขอจาก dev | modal ติดต่อทีม |
| Payment method 1 | bank transfer / QR (bank_id 1-3,4) | MTC-PAY-05/06/07 | flow checkout | — |
| Payment method 2 | credit card (method_id=2) | MTC-PAY-04 | flow checkout | fee env% |
| Payment sandbox / 2C2P | 2C2P test merchant/secret + บัตรทดสอบ | MTC-PAY-10, MTC-ORD-02 | `2C2P_*` env (test) | **ห้ามบัตรจริง** |
| Tracking ID จริง | tracking_id (sha256) | MTC-TRK-04 | จาก order ที่สร้าง | microservice |
| Order code + เบอร์/อีเมล | order_code + phone_or_email | MTC-TRK-02 | จาก order จริง | path ที่ 2 |
| Order ยังไม่จ่าย | status_payment=0 | MTC-PAY-05..09, MTC-TRK-04 | สร้าง order ใหม่ | — |
| Order จ่ายแล้ว | status_payment=1/2 | MTC-TRK-04, MTC-PAY-08 | หลังแจ้งชำระ | — |
| Slip upload test file | รูป jpg/png | MTC-PAY-05/06 | เตรียมไฟล์ | media upload |
| Mock API responses | 422 / 500 / 401 / timeout | MTC-API-01/02, MTC-SESS-01 | `page.route` / MSW | network/error path |

---

# Step 6 — Final Gap Recommendation

### 1. Module ที่ coverage ดีแล้ว
- **Home, Category Listing (CAT-01/03/04/05), Product Detail (PDP-01/02/03), Cart empty/persist (CART-01/03/04)** — flow หลัก positive ครอบคลุมพอใช้
- **Email validation (CHK-03)** ตรง code

### 2. Module ที่ coverage ยังไม่พอ (ต้องเสริมเร่งด่วน)
- **Checkout** — ขาดกฎ delivery datetime (past/<4ชม/>30วัน), slug invalid, message card count
- **Coupon** — ขาด min/max, ใช้ซ้ำ, guest, amount/percent, campaign, re-validate
- **Payment / Upload slip** — ขาด fee env%, สลิปบังคับ, status, partial remain
- **Validation / Security** — ขาด FE/BE inconsistency, consent bypass
- **API Error / Session / Race** — ไม่มี TC เลย

### 3. High priority missing test cases (ต้องทำก่อน)
`MTC-CHK-09, MTC-CHK-10, MTC-CHK-12, MTC-CHK-13, MTC-AUTH-03, MTC-AUTH-04, MTC-PROMO-04, MTC-PROMO-05, MTC-PROMO-07, MTC-PROMO-10, MTC-CART-06, MTC-SHIP-01, MTC-PAY-04, MTC-PAY-05, MTC-SEC-01, MTC-API-01, MTC-API-02, MTC-SESS-01, MTC-LOAD-01`

### 4. Test cases ที่ต้องเพิ่มก่อน execute regression
- Critical path เดิม (Round 1) + **delivery datetime rules (MTC-CHK-09/10/11)** + **double submit (MTC-LOAD-01)** + **coupon re-validate (MTC-PROMO-10)** + **payment fee (MTC-PAY-04)**
- เหตุผล: เป็น logic ที่เปลี่ยน "สั่งได้/ไม่ได้" และ "ยอดเงิน" โดยตรง

### 5. Test data ที่ต้องขอจากทีม dev
- ค่า env `CREDIT_CARD_SERVICE_FEE_PERCENTAGE`, `EXCLUDED_TAGS`
- Test user + `web_user_token` ที่ login ได้
- Coupon ครบชนิด: amount, percent, มี discount_min/max, campaign, used, expired
- Location ที่ `allow_delivery=false`
- 2C2P sandbox (merchant/secret/บัตรทดสอบ)
- ตัวอย่าง `tracking_id` + `order_code`+เบอร์ของ order จริง
- Spec/endpoint ของ tracking microservice (`/track-order`)

### 6. ข้อจำกัดที่ยัง `Not verifiable from code`
- **Tracking microservice** (`/track-order`) — source ไม่อยู่ใน repo → ตรวจ response/behavior จริงไม่ได้
- **มีกล่อง search UI หรือไม่** — backend รองรับ `keyword` แต่ต้อง execute หน้าเว็บยืนยัน
- **ค่า env จริง** (fee %, excluded tags, min/max price default) — ต้องขอจาก dev
- **XSS/SQLi sanitize** — ไม่พบ explicit escape; ต้อง execute security test
- **2C2P gateway behavior** — ต้องใช้ sandbox จริง
- **email/SMS ส่งจริง** — เป็น queue job ต้องตรวจที่ mail server

### 7. สิ่งที่ควรทำต่อใน Round 3
1. ออกแบบ **detailed test cases** (steps/expected สมบูรณ์) จาก MTC ทั้งหมด พร้อม data fixtures
2. **Automation Recommendation** (POM, data-driven, mock payment/API) — เลื่อนมาจาก Round 1
3. ทำ **API-level test suite** สำหรับ FE/BE inconsistency + bypass (consent/phone) แยกจาก UI test
4. ประสาน dev เพื่อ **ปิด defect จริง**: consent ที่ BE, FE/BE phone regex, cleanup messageCard keys
5. ขอ access **tracking microservice spec** เพื่อปิด gap TC-TRK
6. ยืนยัน/ปิด DEF-001 (search UI), DEF-003 (ริบบิ้น — ผิด), DEF-004 (วันที่ — ผิด) กับ PO อย่างเป็นทางการ
