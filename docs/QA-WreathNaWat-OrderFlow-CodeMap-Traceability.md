# QA Code Map & Traceability Matrix — Order Flow: หรีด ณ วัด (Wreath Na Wat)

| | |
|---|---|
| **ระบบ** | หรีด ณ วัด (Wreath Na Wat) — ร้านขายพวงหรีด/ดอกไม้งานศพออนไลน์ |
| **อ้างอิง Test Plan** | `QA-WreathNaWat-OrderFlow-TestPlan.md` |
| **ขอบเขตรอบนี้** | Code Map (Step 0–3) + Traceability Matrix (Step 4) + Initial Summary (Step 5) |
| **วันที่** | 2026-06-25 |
| **ผู้จัดทำ** | Senior QA Automation Engineer / Test Architect |

> **วิธีการ:** วิเคราะห์จาก source code จริง (Frontend Next.js + Backend Laravel) เท่านั้น — ไม่เดา behavior ที่ไม่พบในโค้ด รอบนี้ **ไม่ทำ** Missing Test Cases เชิงลึก / Gap Analysis ละเอียด / Automation Recommendation

---

## สรุปสถาปัตยกรรมที่พบ

- **Frontend** = Next.js (App Router) + Redux Toolkit + react-hook-form/yup
- **Backend** = Laravel 2 ตัว:
  - `erp` → หัวใจของ order flow (order / product / payment / coupon / total-payment)
  - `web` → CMS / category / article / sitemap
- Frontend **ไม่เรียก ERP โดยตรงจาก client** แต่ผ่าน **Next.js API routes** (`/pages/api/*`) ที่แนบ `NEXT_PUBLIC_ERP_KEY` เป็น Bearer token (BFF pattern)
- **Order Tracking เป็น microservice แยก** (`NEXT_PUBLIC_ORDER_TRACKING_URL` → `/track-order`) — ไม่อยู่ใน source ที่ให้มา

> ⚠️ **ข้อค้นพบสำคัญ:** Test Plan เดิมจัดทำจากการ fetch HTML แบบ static จึงคลาดเคลื่อนจาก code จริงหลายจุด โดยเฉพาะ **DEF-003 (ข้อความริบบิ้น)** และ **DEF-004 (วันที่จัดส่ง)** ซึ่ง **มีอยู่จริงในโค้ด**

---

# Step 0 — Identify Relevant Files

## 0.1 Frontend Relevant Files

| Area | File Path | Why Relevant |
|---|---|---|
| Routing (catch-all) | `frontend/src/app/[...slug]/page.tsx` | Router หลัก map Thai slug → product list/detail/tracking ฯลฯ |
| Routing/Redirect | `frontend/middleware.ts` | redirect (matcher ครอบทุก path ยกเว้น api/_next) |
| Home | `frontend/src/app/page.tsx`, `src/components/pages/home/*`, `src/components/layout/Header/NavBar` | หน้าแรก + เมนูหมวด |
| Product Listing | `frontend/src/app/products/page.tsx`, `src/components/pages/products/{ProductSection,Card,Filter,FilterUsingQueryParamOnly,Pagination,LoadMoreButton}.tsx` | listing + filter + sort + paginate |
| Filter logic | `frontend/src/utils/filter.ts` | `buildApiFilterParams`, `parseCurrentFiltersFromUrl` |
| Product Detail | `frontend/src/app/products/[slug]/page.tsx`, `src/components/pages/products/{ProductDetail,ProductDetailInfo,ProductImage,ProductSimilar}.tsx` | หน้า PDP |
| Add to Cart / Qty | `frontend/src/components/pages/products/AddItemButton.tsx` | ปุ่ม +/− จำนวน, limit 10, ลบเมื่อ qty<1 |
| Buy Now | `frontend/src/components/pages/products/ProductButton.tsx` | "ซื้อทันที" → set `sessionStorage.checkoutProduct` → `/checkout` |
| Cart | `frontend/src/app/cart/page.tsx`, `src/components/pages/cart/{CartItem,CartSummary}.tsx` | หน้าตะกร้า + empty state |
| Cart state | `frontend/src/store/slices/cart.ts`, `src/hooks/useCart.ts` | Redux thunk; guest vs login cart |
| Cart persistence | `frontend/src/utils/storage.ts` (`CartStorage`, `CartLoginStorage`) | เก็บ cart ใน `localStorage['cart']` / `['cartLogin']` |
| Checkout (UI) | `frontend/src/components/pages/checkout/CheckoutForm.tsx` | ฟอร์มทั้งหมด, payment method, coupon, message card gate |
| Checkout (logic) | `frontend/src/contexts/checkout/index.tsx` | สร้าง payload, เรียก order/total-payment, redirect หลังสั่ง |
| Message Card (ริบบิ้น) | `frontend/src/components/pages/checkout/{MessageCardForWreath,MessageCardModal}.tsx`, `src/hooks/useFuneralCard.ts` | **ช่องข้อความบนพวงหรีด (มีจริง)** เก็บใน `localStorage['messageCardModal-{n}-{code}']` |
| Validation | `frontend/src/utils/validation/checkout.ts`, `src/contexts/validation.ts`, `src/contexts/checkout/type.d.ts` | yup schema (delivery_date, phone, email, wat ฯลฯ) |
| Checkout API client | `frontend/src/api/order/index.ts`, `src/api/payment/index.tsx`, `src/api/checkout/index.ts` | `submitOrder`, `validateCoupon`, `getTotalPayment`, `acceptPayment` |
| Next API (proxy → ERP) | `frontend/pages/api/{order,total-payment,validate-coupon,accept-payment,payment-fails,get-order,get-2c2p-info,accept-2c2p,location,card-*}.ts` | BFF layer แนบ ERP key |
| Payment / Order Success | `frontend/src/app/payment/[tracking_id]/page.tsx`, `payment/2c2p/[tracking_id]`, `payment/success/[tracking_id]`, `payment/thankyou`, `payment/fail/[tracking_id]` | upload สลิป/QR + 2C2P + success |
| Tracking | `frontend/src/app/tracking/page.tsx`, `src/components/pages/tracking/{page,result,result-notpayment}.tsx`, `src/api/tracking/index.ts` | ติดตามสถานะ (microservice แยก) |
| Auth | `frontend/src/hooks/useAuth.ts`, `src/store/slices/auth.ts`, `src/app/{forget-password,user-reset-password,user-confirm-email}/page.tsx` | login เป็น state/modal — **ไม่มี route `/login`** |
| API instance | `frontend/src/api/instance.ts` | `ERP_API`, `BACKEND_API`, `TRACK_ORDER_API`, interceptors (401→clear) |
| Province/ต่างจังหวัด | `frontend/pages/api/location.ts`, `CheckoutForm.onChangeWat` | จำกัด 6 จังหวัด, นอกนั้น → LINE modal |

## 0.2 Backend Relevant Files (Laravel `erp` เป็นหลัก)

| Area | File Path | Why Relevant |
|---|---|---|
| Routes (API) | `backend/erp/routes/api.php` | นิยาม endpoint order/store/product/option/media |
| Order | `backend/erp/app/Http/Controllers/OrderController.php` | `store`, `show_by_tracking_id`, `accept_payment_infos`, `payment_fails`, `get_2c2p_payment_infos` |
| Total Payment + Coupon | `backend/erp/app/Http/Controllers/StoreController.php` | `get_total_payment`, `validate_coupon`, `discountAmount`, `processDiscountByCouponCode` |
| Product/Listing/Sort/Filter | `backend/erp/app/Http/Controllers/StoreController.php` (`_products`, `process_*_condition`) | query สินค้า + filter ราคา/tag + keyword |
| Product Filters | `backend/erp/app/Http/Controllers/ProductFilterController.php` | config ตัวกรอง |
| Location/ค่าส่ง | `backend/erp/app/Http/Controllers/LocationController.php` (`location_delivery_fee`, `provinces`) | คำนวณค่าจัดส่งตาม location_id |
| Models | `backend/erp/app/Models/{web_order,product,payment,promotion_item,UserCoupon,customer,location,option}.php` | entity ที่เกี่ยวกับ order/coupon |
| Validation rules | (อ้างใน OrderController) `WebUserExists`, `ProductSlugExists`, `PossibleDeliveryDateTime` | custom rule ตอน create order |
| Email jobs | `backend/erp/app/Jobs/{SendOrderCreatedEmailJob,SendPaymentAcceptedEmailJob}.php` | ส่งเมลยืนยันหลังสั่ง/หลังชำระ |
| Migrations | `backend/web/database/migrations/*` (web_users, user_profiles, product_filters, control_product_list) | schema ฝั่ง web (CMS/user) |
| Config/ENV | `backend/erp/.env`, `config/*` | `STORE_ID`, `CREDIT_CARD_SERVICE_FEE_PERCENTAGE`, `2C2P_*`, `EXCLUDED_TAGS`, `ORDER_TRACKING_ID_HASH_KEY` |
| Category/Article (web) | `backend/web/app/Http/Controllers/{ProductCategoryController,ProductFilterController}.php` | `/product-category` ที่ FE `getProductPageBySlug` เรียก |

> `track-order` (tracking microservice) และ `/order-by-reference-key` → **Not found in code** (คนละ service)

---

# Step 1 — Actual User Flow Map

| Step | User Action | Frontend Page / Component | API Called | Expected System Behavior (จาก code) | Code Reference |
|---|---|---|---|---|---|
| 1 | เปิด Home | `src/app/page.tsx`, `NavBar` | `getControlProductList`, `getProductListByTag` (ERP) | แสดงแบนเนอร์ + สินค้าตาม section | `src/app/page.tsx` |
| 2 | เลือกหมวด/แบนเนอร์ | `NavBar`, catch-all `[...slug]` | — (route map) | นำทางไป listing ตาม slug | `src/app/[...slug]/page.tsx` |
| 3 | ดู Listing + Filter/Sort/Page | `app/products/page.tsx` → `ProductSection`,`Filter`,`Pagination` | `getProductList` → `ERP /store/{STORE_ID}/products?...&perpage=&keyword=` | กรอง/เรียง/แบ่งหน้าผ่าน query param | `app/products/page.tsx:48-73`, `api/product/index.ts:getProductList` |
| 3b | ค้นหา (keyword) | — (ไม่พบกล่อง UI ชัดเจน) | `?keyword=` ส่งต่อเข้า ERP | listing กรองด้วย keyword | `app/products/page.tsx:62-68` |
| 4 | เปิด PDP | `app/products/[slug]/page.tsx` → `ProductDetail` | `getProductBySlug` → `ERP /store/{STORE_ID}/product-by-slug/{slug}` | แสดงชื่อ/ราคา/ไซซ์/รูป/breadcrumb | `api/product/index.ts:getProductBySlug` |
| 5 | เพิ่มลงตะกร้า | `AddItemButton` → `useCart.addProductItemToCart` | — (เก็บ local) / login → `updateUserInfo` (BE) | guest→`localStorage['cart']`; limit รวม ≤10 | `slices/cart.ts:10-67`, `AddItemButton.tsx:39-92`, `storage.ts:71-119` |
| 6 | ซื้อทันที | `ProductButton.navigateToCheckout` | — | set `sessionStorage['checkoutProduct']` → `router.push('/checkout')` (ข้าม cart) | `ProductButton.tsx:85-102` |
| 7 | เปิด Cart | `app/cart/page.tsx` → `CartItem`,`CartSummary` | — (อ่าน local/Redux) | empty → "คุณยังไม่มีสินค้าในตะกร้า"; แก้ qty/ลบ | `app/cart/page.tsx`, `cart/CartItem.tsx` |
| 8 | ไป Checkout | `CartSummary` (ProductButton context=cart) | — | set `sessionStorage['checkoutProduct']` → `/checkout` | `ProductButton.tsx:88-102` |
| 8b | ต่างจังหวัด | `CheckoutForm.onChangeWat` | — | จังหวัดนอก 6 จังหวัด → modal + ลิงก์ `/line` | `CheckoutForm.tsx:243-258` |
| 9 | กรอกข้อมูลจัดส่ง+ผู้สั่ง | `checkout/CheckoutForm.tsx` | `getTotalPayment` → `POST /api/total-payment` → `ERP GET /order/total-payment` | คำนวณ subtotal+ค่าส่ง+ส่วนลด+fee real-time | `contexts/checkout/index.tsx:fetchDeliveryFee`, `pages/api/total-payment.ts` |
| 10 | กรอกข้อความริบบิ้น | `MessageCardForWreath` → `MessageCardModal` | `cardPreview`/`cardFinal` (`/api/card-preview`,`/api/card-final`) | เก็บ `localStorage['messageCardModal-{n}-{code}']`; ต้องมี `attachedMessage1` | `CheckoutForm.tsx:38-65,867`, `api/checkout/index.ts` |
| 11 | ใส่โค้ดส่วนลด | `CheckoutForm.handleValidateCoupon` | `validateCoupon` → `POST /api/validate-coupon` → `ERP /order/validate-coupon` | ตรวจคูปอง (**ต้อง login**), แสดง error/หักส่วนลด | `CheckoutForm.tsx:586-630`, `StoreController.php:1356` |
| 12 | เลือกวิธีชำระ + กดชำระเงิน | `CheckoutForm.onSubmit` → `handleProceedButton` → `onCreateOrder` | `submitOrder` → `POST /api/order` → `ERP POST /order` | สร้างออเดอร์ (status_payment=0), คืน `tracking_id`, clear cart, ส่งเมล | `contexts/checkout/index.tsx:onCreateOrder`, `OrderController.php:104` |
| 13 | ไปหน้าชำระเงิน | redirect | — | method 1→`/payment/{tracking_id}` (QR/โอน); method 2→`/payment/2c2p/{tracking_id}` | `contexts/checkout/index.tsx:~258-275` |
| 14 | แจ้งชำระ/อัปสลิป | `app/payment/[tracking_id]/page.tsx` | `getOrderPayment`, `acceptPayment`, `submitFile` | upload สลิป → `ERP /order/accept-payment-infos` → status_payment=1/2 | `payment/[tracking_id]/page.tsx`, `OrderController.php:965` |
| 15 | บัตรเครดิต (2C2P) | `app/payment/2c2p/[tracking_id]/page.tsx` | `get2C2PPayment`, `/api/accept-2c2p` | สร้าง paymentToken → redirect 2C2P gateway | `OrderController.php:855`, `pages/api/accept-2c2p.ts` |
| 16 | Order Success | `app/payment/success/[tracking_id]/page.tsx`, `payment/thankyou` | — | แสดงผลสำเร็จ | `app/payment/success/[tracking_id]/page.tsx` |
| 17 | Tracking | `app/tracking/page.tsx` → `result`/`result-notpayment` | `TrackingOrder` → `TRACK_ORDER_API GET /track-order` (microservice) | ค้นด้วย `tracking_id` หรือ `order_code`+`phone_or_email_address` | `api/tracking/index.ts`, `app/tracking/page.tsx` |

---

# Step 2 — Backend API / Logic Map

| Step | Module | API Endpoint | Method | Controller/File | Request / Validation | Response / Status | Business Rule | Error Handling |
|---|---|---|---|---|---|---|---|---|
| Product list | Product | `/store/{store_id}/products` | GET | `StoreController::products/_products` | perpage, tag_values, price_ranges, keyword, random_order | JSON list + paginate | filter ราคา/tag, exclude `EXCLUDED_TAGS` | 404 product-by-slug |
| Product detail | Product | `/store/{store_id}/product-by-slug/{slug}` | GET | `StoreController::product_by_slug` | slug | product object | slug→id, ลอง slug ไม่มี id ก่อน | null ถ้า 404 |
| Related | Product | `/product/related/{id}` | GET | `ProductController::relatedProducts` | id | list | — | — |
| Total payment | Checkout | `/order/total-payment` | GET (body) | `StoreController::get_total_payment` | cart[], coupon_code, self_pickup, delivery.location_id/date/time, payment_method_id | `summary_infos{total_product_price, delivery_price, discount, credit_card_service_fee, total_payment, ...}` | **total = (สินค้า+ค่าส่ง−ส่วนลด)−(self_pickup+2get100); method_id==2 → +fee = total×`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`/100**; ค่าส่งจาก `location_delivery_fee(location_id)` | คืน 0 ทุกค่าถ้า cart ว่าง |
| Validate coupon | Promotion | `/order/validate-coupon` | POST | `StoreController::validate_coupon` | coupon_code, cart[], web_user_token | `_infos{error, error_message, ...}` | **uppercase; ต้องมีในร้าน; ต้อง login (web_user_token→backend_user_id); ห้ามใช้ซ้ำ (UserCoupon); ต้อง applicable กับตะกร้า** | error_message ไทยตามกรณี |
| Create order | Order | `/order` | POST | `OrderController::store` | ดูกฎ validate ละเอียดด้านล่าง | 201 `{order, web_order}` หรือ 422 `{message, messages, errorKeys}` | สร้าง `web_order`→`order`; code `O-%010d`; `tracking_id=sha256(...)`; status_payment=0; บันทึก order_meta (subtotal/discount/total/fee) | 422 validation, 500 exception (rollback) |
| Coupon ต้อง token | Order | (ภายใน store) | — | `OrderController::store` | `customer.web_user_token` **required_with coupon_code** | 422 | ใช้คูปอง = ต้องส่ง token | "Web User Token จำเป็นต้องระบุถ้าต้องการใช้คูปอง" |
| Order by tracking | Order | `/order/infos/{tracking_id}` | GET | `OrderController::show_by_tracking_id` | tracking_id | order + payments(meta) | map paymentMeta→key:value | 404 not found |
| 2C2P info | Payment | `/order/get-2c2p-payment-infos/{tracking_id}` | GET | `OrderController::get_2c2p_payment_infos` | tracking_id | paymentToken + hash + url | amount = payment_total (pad 12, x100); HMAC-SHA256 | 404 not found |
| Accept payment | Payment | `/order/accept-payment-infos` | POST | `OrderController::accept_payment_infos` | bank_id in 0–6, price≥0, media_id required_with bank_id, transfer_date Y-m-d, transfer_time H:i | 200 `{payment}` / 422 | **status_payment = bank_id ว่าง?2(บัตร):1(รอตรวจ)**; map bank_id→payment.type; สร้าง `merge_order_item` (remain) | 404 order/media; 422 validation; 400 exception |
| Payment fail | Payment | `/order/payment-fails` | POST | `OrderController::payment_fails` | success(bool), tracking_id | 200 ok / 404 | ส่งเมลแจ้ง fail | 404, 422 |
| Province | Shipping | `/location/province` | GET | `LocationController::provinces` | without_districts, excluded | list | — | — |
| Register | Auth | `/user/register` | POST | `UserController::register` | — | — | สมัครสมาชิก | — |
| Login | Auth | `/user/login` | POST | `UserController::login` | — | token | Sanctum | — |
| Tracking (self) | Tracking | `/track-order` | GET | **Not found in code** (microservice แยก) | tracking_id / order_code+phone_or_email | `ITrackOrderResponse` | — | 404/500 |

### กฎ validate ตอน Create Order (`OrderController::store`) — สำคัญสำหรับ Test Data

| Field | Rule | หมายเหตุ |
|---|---|---|
| `general.from_ip_address/user_device/browser/user_agent` | required | FE เติมอัตโนมัติ (`ipify` + `detect-browser`) |
| `delivery.location_id` | required, integer, exists:ab_locations,id | id ของวัด |
| `delivery.deceased_name` / `temple_hall` / `phone_number` | **required_without_all** | ต้องมีอย่างน้อย 1 ใน 3 |
| `delivery.delivery_date` | required, **date_format:Y-m-d** | **มีวันที่จัดส่ง (ขัดกับ DEF-004)** |
| `delivery.delivery_time` | required, H:i | — |
| `cart.*.slug` / `count` | required / integer min:1 | — |
| `cart.*.attachments.*.attached_message_1` | **required, max:255** | **ข้อความริบบิ้นบรรทัด 1 บังคับ (ขัดกับ DEF-003)** |
| `cart.*.attachments.*.attached_message_2` | string, max:255 | บรรทัด 2 optional |
| `cart.*` | count ≤ จำนวน attachments | ต้องกรอกป้ายครบทุกพวงหรีด |
| `payment.method_id` | required, **in:1,2** | 1=โอน/QR, 2=บัตรเครดิต |
| `customer.web_user_token` | required_with coupon_code | คูปองต้อง login |
| `customer.full_name` | required | — |
| `customer.phone_number` | required, alpha_num, max:14, **regex (รองรับ +66/เว้นวรรค/เบอร์บ้าน)** | **เข้มน้อยกว่า FE** |
| `customer.email_address` | required, email, unique-check ถ้า add_to_new_user | — |
| `customer.add_to_new_user` | required, boolean | — |
| `customer.password` | required_if add_to_new_user=1, min:8 | — |

---

# Step 3 — Business Rules / Validation / Status Map

| Area | Rule Type | Rule / Behavior (จาก code) | Frontend Reference | Backend Reference | Notes |
|---|---|---|---|---|---|
| Required field (จัดส่ง) | Form/API | วัด(`wat.id`) required; date+time required; ≥1 ใน {ผู้เสียชีวิต, ศาลา, เบอร์} | `validation/checkout.ts`, `CheckoutForm:validateAtLeastOneRequired` | `OrderController:store` (required_without_all) | สอดคล้อง FE/BE |
| Email | Validation | FE: `.email()`; BE: `email` + unique ถ้าสมัครสมาชิก | `validation/checkout.ts` | `OrderController:store` | — |
| Phone (ผู้สั่ง) | Validation | **FE: `^0\d{9}$` (เข้ม 10 หลักขึ้นต้น 0); BE: regex รองรับ +66/เว้นวรรค/เบอร์บ้าน** | `validation/checkout.ts:customer_phone_number` | `OrderController:store:customer.phone_number` | **Inconsistency FE↔BE** |
| Phone (ติดต่อจัดส่ง) | Validation | nullable, `^$|^0\d{9}$` | `validation/checkout.ts:phone_number` | required_without_all | — |
| Price calculation | Business | total = (สินค้า + ค่าส่ง − ส่วนลด) − (self_pickup + 2get100) | `fetchDeliveryFee` | `StoreController:get_total_payment:~1610` | คำนวณที่ BE เท่านั้น |
| Shipping calc | Business | ค่าส่งจาก `location_delivery_fee(location_id)`; `allow_delivery=false` → modal ติดต่อทีม | `contexts/checkout:fetchDeliveryFee` | `LocationController::location_delivery_fee` | กทม.+ปริมณฑลฟรี |
| ต่างจังหวัด | Business | นอก {กทม,นนทบุรี,ปทุมธานี,สมุทรปราการ,สมุทรสาคร,นครปฐม} → disable + LINE | `CheckoutForm:onChangeWat:248` | (ค่าส่งคำนวณจาก location) | hardcoded 6 จังหวัด |
| Credit card fee | Business | method_id==2 → +`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`% (env ไม่ hardcode 3) | `handlePaymentActive`, `creditCardServiceFee` | `get_total_payment:~1625` | Test Plan สมมติ 3% — **ต้องยืนยันค่า env** |
| Coupon rule | Business | uppercase, มีในร้าน, **ต้อง login**, ห้ามใช้ซ้ำ, ต้อง applicable | `handleValidateCoupon` | `validate_coupon:1356`, `discountAmount` | **Guest ใช้คูปองไม่ได้** |
| Qty / inventory | Business | รวมในตะกร้า ≤ **10 ชิ้น**; qty<1 → ลบสินค้า; ไม่พบ stock check | `AddItemButton:46-92`, `CheckoutForm:107` | — (ไม่พบ stock validate) | limit เป็น UI rule |
| Message card (ริบบิ้น) | Business/Validation | ต้องกรอก `attachedMessage1` ทุกพวงหรีด ก่อนกดชำระ | `validateMessageCards:38`, `MessageCardModal` | `attached_message_1 required` | **มีจริง ขัดกับ DEF-003** |
| Payment status | Status | status_payment: 0=รอชำระ, 1=รอตรวจสอบ, 2=ตรวจแล้ว/บัตร | — | `store:status_payment=0`, `accept_payment_infos` | tracking ใช้ status_payment 0–4 |
| Order status | Status | status_order=0(เปิดขาย), status_delivery=0(draft), status_print=0 | — | `OrderController:store` | — |
| Tracking status | Status | tracking page เลือก component ตาม `status_payment` (0/1→notpayment, 2/3/4→result) | `app/tracking/page.tsx:140-160` | microservice | — |
| Payment method map | Business | bank_id 0=2c2p,1=BBL,2=KBANK,3=KTB,4=QR,5=Paypal,6=QR | `payment/[tracking_id]` | `accept_payment_infos:switch` | comment ใน code สลับกันชวนสับสน |
| Auth/permission | Auth | ERP routes ใช้ `auth:sanctum` + `role:admin` แต่ FE proxy แนบ `NEXT_PUBLIC_ERP_KEY` (service token) | `instance.ts`, `pages/api/*` | `routes/api.php` | guest checkout ทำได้ผ่าน service key |
| 401 handling | Error | interceptor: 401 → `clearStorage()` (+reload ใน ERP_API) | `api/instance.ts` | — | — |
| Order create error | Error | 422 → `{message, errorKeys}` แสดงผ่าน `openErrorModal` | `onCreateOrder:catch` | `store:validator->fails` | — |
| Search box (UI) | — | `?keyword=` รองรับใน listing แต่ **ไม่พบกล่อง search UI** | `app/products/page.tsx:62` | `StoreController` keyword | DEF-001 partial |
| `/login` route | — | **ไม่มี** route `/login` (login เป็น state/modal ผ่าน `useAuth`) | `src/app/*` (ไม่มี login dir) | `/user/login` (API มี) | DEF-002 — UI ไม่มีหน้า แต่ API มี |

---

# Step 4 — Traceability Matrix

| Test Case ID | Module | Summary | Frontend Evidence | Backend Evidence | API Endpoint | Validation / Business Rule | Validity | Issue Found | Recommendation |
|---|---|---|---|---|---|---|---|---|---|
| TC-HOME-01 | Home | คลิกเมนูหมวด | `NavBar`, `[...slug]/page.tsx` | `web` ProductCategory | — (route) | slug map | **Valid** | เมนูหลัก `href="#"` (DEF-005) ต้อง execute ยืนยัน | ตรวจ dropdown render หมวดย่อยเป็น URL จริง |
| TC-HOME-02 | Home | แบนเนอร์/โซเชียล | `home/*`, `Footer` | — | — | — | **Not Verifiable from Code** | ลิงก์ภายนอก | ตรวจ URL ปลายทาง |
| TC-CAT-01 | Category | แสดงสินค้า | `products/page.tsx`,`Card.tsx` | `StoreController::_products` | `/store/{id}/products` | listing | **Valid** | — | smoke |
| TC-CAT-02 | Category | Sort 4 แบบ | `Filter`, `filter.ts` | `_products` (order_by/price) | `/store/{id}/products?...` | sort param | **Partially Valid** | ต้องยืนยันชื่อ param sort จริง (`random_order`/price) | map ค่า sort↔query ใน `filter.ts` |
| TC-CAT-03 | Category | Filter + ล้าง | `FilterUsingQueryParamOnly`, `filter.ts` | `process_*_condition` | `/store/{id}/products` | filter ราคา/tag | **Valid** | — | — |
| TC-CAT-04 | Category | Pagination | `Pagination.tsx`,`LoadMoreButton` | `_products` paginate | `?perpage=&page=` | boundary | **Partially Valid** | ต้องยืนยันว่าเป็น page หรือ load-more | ตรวจ disabled หน้าแรก/สุดท้าย |
| TC-CAT-05 | Category | Empty result | `ProductSection` (empty) | `_products` คืน [] | — | empty state | **Not Verifiable from Code** | ต้อง execute | ตรวจ empty UI |
| TC-PDP-01 | PDP | แสดงข้อมูล | `ProductDetail`,`ProductDetailInfo` | `product_by_slug` | `/store/{id}/product-by-slug/{slug}` | — | **Valid** | — | assert ราคาตรง listing |
| TC-PDP-02 | PDP | เพิ่มลงตะกร้า | `AddItemButton`,`useCart`,`cart.ts` | login: `updateUserInfo` | — / `/user` | limit ≤10, toast | **Valid** | — | critical path |
| TC-PDP-03 | PDP | ซื้อทันที | `ProductButton.navigateToCheckout` | — | — | → `/checkout` ตรง (ข้าม cart) | **Valid** | Buy Now ไม่ผ่านหน้า cart | ระบุความต่างจาก add-to-cart |
| TC-PDP-04 | PDP | **ข้อความริบบิ้น** | `MessageCardForWreath`,`MessageCardModal`,`validateMessageCards` | `attached_message_1 required` | `/api/card-preview`,`/order` | บังคับกรอกทุกพวงหรีด | **Invalid (สมมติฐานผิด)** | **DEF-003 ผิด — ช่องริบบิ้นมีจริง (อยู่หน้า Checkout ไม่ใช่ PDP)** | แก้ TC ให้หาช่องที่ Checkout; ปิด DEF-003 |
| TC-CART-01 | Cart | Empty state | `cart/page.tsx`,`CartItem` | — | — | empty msg | **Valid** | — | — |
| TC-CART-02 | Cart | แก้ qty/ลบ | `AddItemButton`(cart mode) | — | — | qty<1→ลบ, รวม≤10 | **Valid** | qty แก้ที่ cart (ไม่ใช่ PDP) | ตรวจ subtotal อัปเดต |
| TC-CART-03 | Cart | Persist refresh | `CartStorage` (localStorage) | login→BE | — | `localStorage['cart']` | **Valid** | — | ตรวจ guest vs login |
| TC-CART-04 | Cart | ไป Checkout | `ProductButton`(cart) | — | — | set sessionStorage→`/checkout` | **Valid** | — | critical |
| TC-CART-05 | Cart | ต่างจังหวัด→LINE | `CheckoutForm:onChangeWat` | — | `/line` | นอก 6 จังหวัด | **Partially Valid** | trigger อยู่ตอนเลือกวัดใน checkout ไม่ใช่ปุ่ม cart | ปรับ step ให้ตรง flow จริง |
| TC-PROMO-01 | Promotion | โค้ดถูกต้อง | `handleValidateCoupon` | `validate_coupon` | `/order/validate-coupon` | **ต้อง login** | **Partially Valid** | **Guest ใช้คูปองไม่ได้ (web_user_token ว่าง→error)** | เพิ่ม precondition: ต้อง login |
| TC-PROMO-02 | Promotion | โค้ดผิด/หมดอายุ | `setCouponCodeError` | `validate_coupon` (cases) | `/order/validate-coupon` | error ไทยตามกรณี | **Partially Valid** | "ใช้ซ้ำ" ต้อง login จึงทดสอบได้ | data-driven ตาม 4 กรณี (ตรวจ login) |
| TC-PROMO-03 | Promotion | validation ว่าง/case | `handleValidateCoupon` | `strtoupper`, empty check | `/order/validate-coupon` | **uppercase เสมอ** | **Valid** | code ถูกแปลงเป็นพิมพ์ใหญ่ทั้งหมด | assert case-insensitive |
| TC-CHK-01 | Checkout | Happy path | `CheckoutForm.onSubmit`,`onCreateOrder` | `OrderController::store` | `/api/order`→`/order` | ทุก required + message card | **Valid** | ต้องกรอกริบบิ้น+เลือกวัด+วันที่ | critical; เพิ่ม message card ใน data |
| TC-CHK-02 | Checkout | required ว่าง | `validation/checkout.ts`,`getValidationErrors` | `store` validator | `/order` | 7 ฟิลด์ + wat + date | **Partially Valid** | TC ขาด "วัด" และ "ข้อความริบบิ้น" ในชุด required | เพิ่ม field wat/date/ribbon |
| TC-CHK-03 | Checkout | email | yup `.email()` | `email` rule | `/order` | — | **Valid** | — | — |
| TC-CHK-04 | Checkout | phone | `^0\d{9}$` | regex รองรับ +66 | `/order` | **FE≠BE** | **Partially Valid** | **FE reject `+66...` แต่ BE รับ** → inconsistency | ทดสอบทั้ง 2 ชั้น; รายงาน inconsistency |
| TC-CHK-05 | Checkout | consent บังคับ | `privacy_policy_accepted` (yup boolean) | **ไม่พบ required ที่ BE** | — | gate ที่ FE | **Partially Valid** | **BE ไม่ enforce consent** → bypass ผ่าน API ได้ | ตรวจ FE block + แจ้งความเสี่ยง BE |
| TC-CHK-06 | Checkout | คำนวณยอด | `fetchDeliveryFee` | `get_total_payment` | `/order/total-payment` | สูตร total | **Valid** | คำนวณที่ BE | assert ยอดจาก response |
| TC-CHK-07 | Checkout | XSS/SQLi | input fields | Eloquent (parameterized) + validate | `/order` | sanitize | **Not Verifiable from Code** | ไม่พบ explicit sanitize/escape | execute security test |
| TC-CHK-08 | Checkout | boundary ข้อความ | InputField | `max:255` (ศาลา/ป้าย) | `/order` | maxlength 255 | **Partially Valid** | BE จำกัด 255; FE maxlength ต้องยืนยัน | ตรวจ trim + 255 |
| TC-PAY-01 | Payment | QR/โอน | `payment/[tracking_id]/page.tsx` | `accept_payment_infos` | `/api/get-order`,`/api/accept-payment` | upload สลิป | **Valid** | order success = หน้านี้ | หยุดก่อน submit จริง |
| TC-PAY-02 | Payment | บัตร +3% | `handlePaymentActive`(2),`creditCardServiceFee` | `get_total_payment` (env %) | `/order/total-payment` | fee=total×env% | **Partially Valid** | **% มาจาก env ไม่ใช่ 3 ตายตัว** | ยืนยัน `CREDIT_CARD_SERVICE_FEE_PERCENTAGE` |
| TC-PAY-03 | Payment | ไม่ทำจริง | `payment/2c2p/[tracking_id]` | `get_2c2p_payment_infos` | `/api/accept-2c2p` | gateway 2C2P | **Valid** | — | mock/หยุดก่อน gateway |
| TC-ORD-01 | Order Success | หน้ายืนยัน | `payment/success/[tracking_id]`,`thankyou` | `SendOrderCreatedEmailJob` | — | tracking_id + email | **Valid** | success page มีจริง | ตรวจเลขออเดอร์/เมล |
| TC-TRK-01 | Tracking | ติดตามสถานะ | `tracking/page.tsx`,`result*` | **microservice** `/track-order` | `TRACK_ORDER_API` | tracking_id หรือ order_code+ติดต่อ | **Partially Valid** | tracking เป็น service แยก (ไม่อยู่ใน source) | ขอ spec/endpoint tracking service |
| TC-AUTH-01 | Auth | สมัครตอน checkout | `add_to_new_user`,`password` | `register_new_web_user` | `/order` | add_to_new_user=1 → สร้าง user | **Valid** | สมัครได้จริงตอนสั่ง | ตรวจ login ภายหลัง |
| TC-SRCH-01 | Search | ค้นหา | `?keyword=` (`products/page.tsx`) | `StoreController` keyword | `/store/{id}/products?keyword=` | — | **Partially Valid** | **DEF-001 partial — backend รองรับ keyword แต่ไม่พบกล่อง UI** | ตรวจว่ามี UI search หรือไม่ |
| TC-ERR-01 | Error | 404 | `app/not-found.tsx`,`[...slug]` notFound | — | — | — | **Valid** | มี custom not-found | — |
| TC-ERR-02 | Error | Responsive | `CartSummaryMobile`, `*Mobile` | — | — | — | **Not Verifiable from Code** | ต้อง execute | multi-viewport |

---

# Step 5 — Initial Review Summary

| Metric | Count | Notes |
|---|---:|---|
| Total Test Cases | 30 | TC-HOME-01 .. TC-ERR-02 |
| Valid | 13 | ตรงกับ code โดยตรง |
| Partially Valid | 11 | precondition/ขอบเขต/inconsistency ต้องเสริม |
| Invalid | 1 | TC-PDP-04 (สมมติฐาน DEF-003 ผิด) |
| Not Verifiable from Code | 5 | ต้อง execute จริง / service แยก (HOME-02, CAT-05, CHK-07, ERR-02, บางส่วนของ TRK) |
| Duplicate | 0 | — |
| Too Broad | 0 | — |
| Missing Preconditions | — | เด่นที่ TC-PROMO-01/02 (ต้อง login), TC-CHK-01/02 (ต้องมี message card + วัด) |
| Missing Test Data | — | TC-PROMO (coupon test), TC-PAY (sandbox), TC-TRK (tracking_id จริง) |

## จุดที่ต้องตรวจสอบต่อในรอบ Gap Analysis

1. **ปิด/แก้ Defect ที่ขัดกับ code:**
   - **DEF-003 (ริบบิ้น) → ไม่จริง** — `MessageCardForWreath`/`MessageCardModal` + `attached_message_1 (required)` ที่ BE มีครบ (อยู่หน้า Checkout ไม่ใช่ PDP)
   - **DEF-004 (วันที่จัดส่ง) → ไม่จริง** — `delivery_date` required ทั้ง FE (yup `dd-mm-yyyy`) และ BE (`date_format:Y-m-d`) + มี datepicker (เวลาเป็น slot 17/18/19:00)
   - **DEF-001 (search) → partial** — backend รองรับ `?keyword=` แต่ต้องยืนยันว่ามีกล่อง UI หรือไม่

2. **Inconsistency FE↔BE ที่ต้องสร้าง TC เพิ่ม:**
   - เบอร์โทรผู้สั่ง: FE `^0\d{9}$` (เข้ม) vs BE รับ `+66`/เว้นวรรค/เบอร์บ้าน
   - Consent (privacy policy): บังคับเฉพาะ FE — **BE ไม่ enforce** (เสี่ยง bypass ผ่าน API)

3. **Business rule ที่ Test Plan ยังไม่ครอบคลุม:** limit ตะกร้า **≤10 ชิ้น**; คูปอง **ต้อง login**; คูปอง **แปลงเป็น uppercase**; ค่าบัตรเครดิต **มาจาก env ไม่ใช่ 3% ตายตัว**; จำกัดจัดส่ง **6 จังหวัด hardcoded**; `allow_delivery=false` → modal ติดต่อทีม

4. **ต้องขอจากทีม dev ก่อน execute:** ค่า env `CREDIT_CARD_SERVICE_FEE_PERCENTAGE`, spec ของ tracking microservice (`/track-order`), coupon test code (พร้อมบัญชี login), payment sandbox (2C2P), ตัวอย่าง `tracking_id`

5. **พื้นที่ที่ code มี logic แต่ Test Plan ขาด coverage:** หน้า `/payment/success`, `/payment/thankyou`, `/payment/fail` (TC ครอบเฉพาะ ORD-01 กว้าง ๆ); flow สมัครสมาชิก→`register_new_web_user`; upload สลิป + `merge_order_item` (ยอดคงค้าง remain)
