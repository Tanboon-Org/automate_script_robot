# QA — แผนที่ Module ทั้งเว็บที่ต้องทดสอบ (Full-Site Test Module Map)
## ระบบ: หรีด ณ วัด (Wreath Na Wat)

| | |
|---|---|
| **อ้างอิงโค้ดจริง** | `/home/sukawit1909/Web/WNW` (frontend = Next.js 14 App Router, backend = Laravel ERP) |
| **วันที่** | 2026-06-29 |
| **ขอบเขต** | สำรวจทั้งเว็บ (47 routes + API + backend) เพื่อ list module ที่ต้องทำ test ไม่เฉพาะ order flow |
| **สถานะ coverage** | ✅ มีแล้ว · 🟡 มีบางส่วน · ❌ ยังไม่มีเลย |

> **สรุปผู้บริหาร:** ปัจจุบัน test ~46 ไฟล์ครอบคลุม **เฉพาะ order flow** (home → category → product → cart → checkout → payment → tracking) + unit date logic เท่านั้น
> ยังมี **อีก ~10 กลุ่ม module ที่ยังไม่ถูกทดสอบเลย** โดยกลุ่มใหญ่ที่สุดคือ **ระบบ Account/Auth ทั้งหมด** และ **ตัวออกแบบป้ายหรีด (Message Card Customizer)**

---

## ภาพรวมสถานะตาม module group

| # | Module Group | Coverage | Priority | จำนวนหน้า/endpoint โดยประมาณ |
|---|---|---|---|---|
| A | **Account / Auth** (login, register, ยืนยันอีเมล, ลืม/รีเซ็ตรหัส, ข้อมูลผู้ใช้, ประวัติออเดอร์) | ❌ ยังไม่มีเลย | 🔴 สูง | 6 หน้า + 8 API |
| B | **Message Card / ป้ายหรีด Customizer + อัปโหลดโลโก้/สลิป** | 🟡 มีแค่ ribbon modal | 🔴 สูง | 3 API + modal |
| C | **Coupon / Promotion** | 🟡 โครงมี, BLOCKED รอ data | 🔴 สูง | 9 เคส |
| D | **Checkout business rules** (delivery datetime, slug, message-card count) | 🟡 positive only | 🔴 สูง | ~10 เคส |
| E | **Payment เชิงลึก** (fee env%, สลิป, bank map, 2C2P, partial, fail) | 🟡 1 ไฟล์ | 🔴 สูง | ~10 เคส |
| F | **Product Discovery** (filter/sort/search/pagination, wizard, express, promotion, donate, near-temple/me) | 🟡 listing บางส่วน | 🟠 กลาง | 8 หน้า |
| G | **Content / SEO pages** (บทความ, บริการงานศพ x4, about, faq, นโยบาย ฯลฯ) | ❌ ยังไม่มีเลย | 🟡 ต่ำ-กลาง | ~15 หน้า |
| H | **LINE / B2B / OpenLine flows** (3 ตัวแปร cookie + redirect) | ❌ ยังไม่มีเลย | 🟠 กลาง | 6 หน้า |
| I | **Tracking** (order_code+เบอร์, status branch, tax invoice, quotation) | 🟡 3 ไฟล์ | 🟠 กลาง | 2 หน้า |
| J | **Contact / Corporate lead pages** (reveal toggle, accordion) | ❌ ยังไม่มีเลย | 🟡 ต่ำ | 2 หน้า |
| K | **Global components** (header nav, announcement bar, mini-cart, footer, floating contact, cookie, [...slug] router, 404) | 🟡 บางส่วน | 🟠 กลาง | ทั้งเว็บ |
| L | **Cross-cutting** (API error, session 401, FE/BE inconsistency, security bypass, race, responsive, SEO/JSON-LD) | ❌ เกือบไม่มี | 🔴 สูง | ทุกหน้า |

---

# A. Account / Auth — ❌ ยังไม่มี test เลย (Priority 🔴)

> โค้ด: `src/components/layout/Header/NavBar/{LoginForm,RegisterForm,AuthModal,AuthTab}.tsx`, `src/store/slices/auth.ts`, `src/api/user/`, หน้า `user-confirm-email`, `forget-password`, `user-reset-password`, `user-infos`

### A1. Login (modal ใน header)
- **API:** `POST /web/login/` → `GET /web/user`
- **ฟิลด์:** email, password, rememberMe (checkbox)
- **ต้องทดสอบ:**
  - login ถูกต้อง → "เข้าสู่ระบบสำเร็จ" → redirect `/user-infos` + sync cart (`synUserCart`)
  - รหัส/อีเมลผิด → "รหัสหรืออีเมลผู้ใช้ไม่ถูกต้อง"
  - อีเมลยังไม่ยืนยัน → "อีเมลผู้ใช้ ยังไม่ได้ยืนยันตัวตน"
  - **rememberMe เช็ค → token ลง localStorage / ไม่เช็ค → sessionStorage** (persist ข้ามรีเฟรช)
  - ปุ่ม disable ระหว่าง loading (กันกดซ้ำ)
  - cart ของ guest ก่อน login → หลัง login merge ไม่หาย

### A2. Register (modal ใน header)
- **API:** `POST /web/register`
- **ฟิลด์:** email, password, privacy_policy_accepted
- **กฎ password (สำคัญ):** 8–16 ตัว, ต้องมี **พิมพ์ใหญ่ + พิมพ์เล็ก + ตัวเลข + อักขระพิเศษ + ห้ามเว้นวรรค**
- **ต้องทดสอบ:**
  - สมัครสำเร็จ → "ลงทะเบียนสำเร็จ / กรุณาตรวจสอบอีเมลเพื่อยืนยัน" (ไม่ auto-login)
  - email ซ้ำ → error จาก backend ใต้ช่อง email
  - password แต่ละกฎที่ขาด (ครบทุกข้อความ error 7 แบบ)
  - ไม่ติ๊ก privacy → "กรุณายอมรับนโยบายความเป็นส่วนตัว"
  - toggle show/hide password
  - กันกดซ้ำระหว่าง loading

### A3. ยืนยันอีเมล — `/user-confirm-email?k={token}`
- **API:** `POST /web/confirm-email/{token}`
- **ต้องทดสอบ:**
  - token ถูก → "ยืนยันอีเมลสำเร็จ" + countdown 5 วิ → redirect `/`
  - **ไม่มี token / token ว่าง / token ผิด → ปัจจุบัน "เงียบ" ไม่มีข้อความ (ควร flag เป็น UX bug)**
  - token หมดอายุ / ยืนยันซ้ำ
  - navigate ออกระหว่าง countdown (timer ต้อง clear)

### A4. ลืมรหัสผ่าน — `/forget-password`
- **API:** `POST /web/forgot-password`
- **ต้องทดสอบ:**
  - ส่งสำเร็จ → "ส่งลิงก์สำเร็จ กรุณาตรวจสอบอีเมล"
  - error → "เกิดข้อผิดพลาดในการส่งลิงก์..."
  - **ไม่มี client validation เลย** (ช่องว่าง/ไม่ใช่อีเมล ส่งตรงไป backend) → ทดสอบ negative
  - กันกดซ้ำ

### A5. รีเซ็ตรหัสผ่าน — `/user-reset-password?k={token}`
- **API:** `POST /web/new-password`
- **ต้องทดสอบ:**
  - ไม่มี token → `alert('Token is missing in the URL')`
  - รีเซ็ตสำเร็จ → "เปลี่ยนรหัสผ่านสำเร็จแล้ว" (ไม่ redirect)
  - token ผิด/หมดอายุ → error
  - **🐞 BUG: placeholder เขียน "กรอกรหัสผ่านเดิม" แต่จริงต้องกรอกรหัส*ใหม่*** → flag
  - **ไม่บังคับ complexity ฝั่ง FE** (ต่างจากตอน register) → ตรวจว่า BE บังคับไหม

### A6. ข้อมูลผู้ใช้ — `/user-infos` (protected route)
- **API:** `GET/PATCH /web/user`, `PATCH /web/user/change-password`
- **3 ส่วนย่อย:**
  - **ข้อมูลส่วนตัว:** name (required), phone, address, email (disabled), EDM checkbox
  - **ข้อมูลใบกำกับภาษี:** issue_to*, branch_name, tax_id* (max 13 หลัก, บล็อกพิมพ์เกิน), email_for_receipt*, address*
  - **เปลี่ยนรหัสผ่าน (modal):** currentPassword*, newPassword (complexity เท่า register); รหัสเดิมผิด → "รหัสเดิมไม่ถูกต้อง"
- **ต้องทดสอบ:** เข้าโดยไม่ login (หน้าว่าง — ควร redirect?), update แต่ละ section, tax_id boundary 13, logout → clear state → `/`, badge จำนวน pending orders

### A7. ประวัติออเดอร์ (ใน user-infos) — `OrdersSection`
- **ต้องทดสอบ:** pending vs completed, empty state "- ยังไม่มีรายการสั่งซื้อ -", ปุ่ม copy รหัสออเดอร์ (`navigator.clipboard`) → "คัดลอกเลขออเดอร์สำเร็จ" 1.5 วิ

---

# B. Message Card / ป้ายหรีด Customizer + อัปโหลด — 🟡 มีแค่ ribbon modal (Priority 🔴)

> โค้ด: `src/components/pages/checkout/{MessageCardModal,MessageCardForWreath}.tsx`, `pages/api/{card-preview,card-final,card-size,media}.ts`, `useFuneralCard.ts`

### B1. ตัวออกแบบป้าย (MessageCardModal)
- **อินพุตที่ผู้ใช้คุม:** โทนพื้น (ขาว 'w'/ดำ 'b'), ข้อความบรรทัด 1 (**required**), บรรทัด 2 (optional), รูปแบบป้าย (1/2/3), ตำแหน่งโลโก้ (ซ้าย/ขวา), อัปโหลดโลโก้
- **API:** `GET /api/card-preview` (debounce 888ms, real-time), `GET /api/card-final` (save), `GET /api/card-size` (default ขนาด/พื้นหลัง)
- **localStorage:** `messageCardModal-{wreathNumber}-{productCode}`
- **ต้องทดสอบ:**
  - preview อัปเดตเมื่อเปลี่ยน tone/format/align/ข้อความ (debounce)
  - บรรทัด 1 ว่าง/มีแต่ space → ปุ่มบันทึก disable + ข้อความ error
  - ปุ่ม disable ระหว่าง preview loading / กรณี preview error
  - บันทึก → เก็บ finalId + finalUrl ลง localStorage
  - หลายพวงหรีด (2+) → แต่ละพวงมี data แยก validate แยก
  - ลบสินค้า → key `messageCardModal-*` ถูกล้าง (กันข้อมูลป้ายเก่ารั่ว)

### B2. อัปโหลดโลโก้ (media)
- **API:** `POST /api/media` → ERP `/media/temporary-order-file`
- **กฎ:** `accept="image/*"`, **โลโก้ max 20×20cm (~288×288px) เช็คฝั่ง client**
- **ต้องทดสอบ:** รูปใหญ่เกิน → toast "รูปมีขนาดใหญ่เกินไป...", อัปโหลดล้มเหลว → toast, ไฟล์ไม่ใช่รูป, ลบแล้วอัปใหม่, ไฟล์ใหญ่มาก (timeout), response ขาด field `url`/`id`

### B3. validateMessageCards ตอน submit checkout
- count ข้อความป้าย ต้อง = จำนวนพวงหรีด ทุกชิ้น มิฉะนั้น submit ถูก disable → "กรุณากรอกข้อความป้ายให้ครบทุกพวงหรีด"
- payload `attachments[]` ส่ง logo_id/card_id/attached_message_1/2 ถูกต้อง

---

# C. Coupon / Promotion — 🟡 BLOCKED รอ test data (Priority 🔴)

> ดูเอกสาร `QA-Coupon-TestData-Request.md` — 8 เคสรอ `web_user_token` + คูปอง 7 แบบจาก dev
> Backend: `StoreController::validate_coupon` (1356–1477), `discountAmount` (1654–1846)

- **ต้องทดสอบ:** ต้อง login ก่อน (guest → "ต้องล๊อคอินก่อนค่ะ"), case-insensitive (strtoupper), ช่วง min/max **strict** (`> min && < max`, ขอบพอดี = ใช้ไม่ได้), amount vs percent, campaign (tag subset ของสินค้า), ใช้ซ้ำ (UserCoupon) → reject, **re-validate ตอนกดสั่ง (WME01)** — ผ่านตอนคำนวณแต่ fail ตอน order

---

# D. Checkout business rules — 🟡 positive ครอบแล้ว, negative ขาด (Priority 🔴)

> Backend Rules: `PossibleDeliveryDateTime.php`, `ProductSlugExists.php`, `WebUserExists.php`

- **วัน-เวลาส่ง:** อดีต → reject · < 4 ชม. → reject · > 30 วัน → reject (boundary ทั้ง 3) — **ยังไม่มี TC**
- **slug สินค้าไม่มีจริง** (cart เก่า/ถูกลบ) → 404 "ไม่พบสินค้าตาม slug"
- **attached_message > 255 ตัว** → reject
- **สมัครสมาชิกตอน checkout:** email ซ้ำ (add_to_new_user=1), web_user_token ผิด, password < 8 / ไม่ match
- **required_without_all:** ต้องมีอย่างน้อย 1 ใน {ชื่อผู้เสียชีวิต / ศาลา / เบอร์}; location_id ต้อง `exists`

---

# E. Payment เชิงลึก — 🟡 1 ไฟล์ (Priority 🔴)

> Backend: `OrderController::accept_payment_infos`, `get_2c2p_payment_infos`, `StoreController::get_total_payment`

- **credit card fee = total × env% (`CREDIT_CARD_SERVICE_FEE_PERCENTAGE`)** — assert จาก env ไม่ hardcode
- **bank_id map → payment.type** (0=2C2P, 1=BBL, 2=KBANK, 3=KTB, 5=Paypal, 6=QR)
- **media_id required_with bank_id** — โอน/QR ต้องแนบสลิป
- **transfer_date (Y-m-d) / transfer_time (H:i)** ผิดรูปแบบ → reject
- **ชำระบางส่วน → merge_order_item.remain = total − price**
- **status_payment** โอน=1 / บัตร=2 หลังแจ้งชำระ
- **2C2P:** JWT HS256, amount zero-pad 12 หลัก, currency 764, HMAC hash
- **payment_fails** callback → ส่งเมล fail
- **หน้าแยก** `/payment/{success,thankyou,fail}/[tracking_id]` render ถูกตาม route + email ยืนยัน (`SendOrderCreatedEmailJob`)

---

# F. Product Discovery — 🟡 listing บางส่วน (Priority 🟠)

> `src/app/products`, `products-special`, `product-express`, `wreath-promotion`, `wreath-donate`, `servicelocation`, `wreath-nearme` · util `src/utils/filter.ts`

| Module | Route | ต้องทดสอบ |
|---|---|---|
| Product listing | `/ร้านพวงหรีด/[category]` | filter (tag/category, and/or operand), **sort** (`แนะนำ→recommend`, `ช่วงราคา→price`), **search `?keyword=`** (ไม่มีกล่อง UI), pagination 15/หน้า, คงค่าใน URL, EXCLUDED_TAGS ไม่โผล่ |
| Product detail | `/พวงหรีด/[slug]` | **`allow_add_to_cart=false` → ซ่อน Buy Now + แสดง LINE**, ราคา promotion vs regular, related products, recent view |
| Wizard/แนะนำเฉพาะคุณ | `products-special` | อ่าน cookie `wizard_answers` (key_1..4), load more 20/หน้า, tag จากคำตอบ |
| ส่งด่วน | `product-express` (`/พวงหรีดด่วน`) | ปุ่ม LINE, รูป desktop/mobile |
| โปรโมชั่น | `wreath-promotion` (`/สินค้าราคาพิเศษ`) | filter tag promotion, pagination |
| บริจาค | `wreath-donate` | สินค้า tag บริจาค 16/หน้า |
| ใกล้วัด / ใกล้ฉัน | `servicelocation/[slug]`, `wreath-nearme` | location selector ตามจังหวัด |

---

# G. Content / SEO pages — ❌ ยังไม่มี (Priority 🟡 smoke)

> ส่วนใหญ่ static — ทำ **smoke test** (โหลด 200, มี title/meta/og/canonical, breadcrumb, ข้อมูลติดต่อ, responsive)

- **บทความ:** `/บทความ`, `/บทความ/[category]`, `/บทความ/[slug]`, `/ผู้เขียน/[slug]` — มี category filter + pagination 20/หน้า + JSON-LD BreadcrumbList
- **บริการงานศพ (static):** `service-funeral`, `all-service` (`-crematory`, `-pet`, `-relics` คืน 404 บน staging — ตัดออกจาก scope)
- **ข้อมูล:** `about-us`, `how-to-order`, `faqs`, `privacy-policy`, `compensation-policy`, `flower-shop`, `review-wreath`
- **ต้องทดสอบเพิ่ม:** dynamic `[...slug]` router map ถูกต้อง (ตาม switch), Thai URL decode, slug มั่ว → 404 (`NotfoundPage`)

---

# H. LINE / B2B / OpenLine — ❌ ยังไม่มี (Priority 🟠)

> `src/app/{line,lineb2b,line-event}` + `{openline,openlineb2b,openline-event}/[slug]`

| หน้า | cookie | QR ชี้ไป | redirect ปลายทาง |
|---|---|---|---|
| `/line` | `user_id` (30 วัน) | `/openline/{uuid}` | `page.line.me/wreathnawat` |
| `/lineb2b` | `user_id_b2b` | `/openlineb2b/{uuid}` | `line.me/R/ti/p/@237rjmhp` |
| `/line-event` | `user_id_event` | `/openline-event/{uuid}` | `line.me/R/ti/p/@175ctrfd` |

- **ต้องทดสอบ:** สร้าง UUID + set cookie ครั้งแรก, persist ข้ามรีเฟรช, QR render, slug callback set cookie ถูกค่า, redirect ปลายทางถูกต้องตามตัวแปร, **3 cookie แยกกันไม่ชนกัน**

---

# I. Tracking — 🟡 3 ไฟล์ (Priority 🟠)

> `src/components/pages/tracking/page.tsx`, ERP `OrderController::get_order_infos`

- **ค้น 2 ทาง:** (1) `tracking_id` · (2) `order_code` + `phone_or_email_address` — path ที่ 2 ยังขาด
- **branch ตาม status_payment:** 0/1 → `ResultNotpayment`; 2/3/4 → `Result`
- **notFound** → ไม่ leak ข้อมูล
- **tax invoice module** (flag `NEXT_PUBLIC_ENABLED_TAX_INVOICE_MODULE=y`) → fetch hash + แสดงฟอร์ม
- **`/tracking/quotation`** — flow ใบเสนอราคา (ยังไม่ได้แตะ)

---

# J. Contact / Corporate — ❌ ยังไม่มี (Priority 🟡)

- **`/ติดต่อเรา`:** reveal-on-click 3 ตัว (LINE/โทร/อีเมล) → เผยลิงก์ถูก, ปุ่มไป `/line`, tel:/mailto:
- **`/ลูกค้าองค์กร`:** accordion FAQ 4 ข้อ (toggle), 6 ปุ่ม contact (ไป `/lineb2b`, tel, mailto), gallery 20 รูป, ข้อมูลเอกสารเครดิต/ใบกำกับภาษี (ไม่มี form submit จริง)

---

# K. Global components — 🟡 บางส่วน (Priority 🟠)

> `src/components/layout/Header/*`, `Footer/*`

- **Header:** NavBar เมนู (✅ บางส่วน), **AnnouncementBar** (`/announcement/active`) — โหลด/ปิดได้, **mini-cart `ShoppingCart`** (badge จำนวน, dropdown), **AuthModal** (ดูกลุ่ม A)
- **Footer:** `BackToTop`, **`FloatingContactButton`**, **`StickyBars`** (มือถือ) — แสดง/คลิกถูก
- **Cookie consent** (✅ มี TC-HOME-02 แล้ว)
- **Responsive:** desktop vs mobile nav (hamburger), CartSummaryMobile, datepicker mobile

---

# L. Cross-cutting / Non-functional — ❌ เกือบไม่มี (Priority 🔴)

> `src/api/instance.ts` interceptors, FE/BE validation เทียบกัน

- **API error handling:** ERP คืน 422/500/timeout → proxy `{error:true}` → modal ไม่ crash (`pages/api/*` catch)
- **Session/401:** ERP_API interceptor → `clearStorage()` + reload เมื่อ token หมด
- **FE/BE inconsistency:** phone FE `^0\d{9}$` vs BE (+66/เว้นวรรค); line_id FE `^[a-z0-9_-]{,20}$`
- **Security bypass (API-level):** consent privacy BE ไม่ enforce (PDPA เสี่ยง), phone bypass, XSS/SQLi ในป้าย/ศาลา
- **Race/double-submit:** กดชำระรัว → `isSubmitting` ต้องบล็อก ไม่สร้างออเดอร์ซ้ำ
- **SEO/structured data:** JSON-LD, sitemap (`pages/sitemap/*`), canonical, og tags
- **Responsive / cross-browser:** clipboard API, datepicker, file upload บนมือถือ

---

# ลำดับแนะนำ (Roadmap)

### รอบถัดไป — ทำได้เลย ไม่ต้องรอ data
1. **A. Account/Auth ทั้งชุด** (login/register/confirm/forget/reset/user-infos) — gap ใหญ่สุด, ใช้ user ที่มีอยู่
2. **D. Checkout negative rules** (delivery datetime past/<4ชม/>30วัน, slug invalid, message count)
3. **L. double-submit + API error + session 401** (เสี่ยงสูง กระทบเงิน/ออเดอร์ซ้ำ)
4. **B. Message Card Customizer** (preview/validate/upload + cleanup localStorage)

### รอ data จาก dev (ส่ง `QA-Coupon-TestData-Request.md`)
5. **C. Coupon 8 เคส** + **E. Payment fee/slip/2C2P sandbox**

### เสริม coverage กว้าง
6. **F. Product discovery** (filter/sort/search/wizard), **H. LINE flows**, **I. Tracking path 2 + quotation**
7. **G. Content smoke** + **J. Contact/Corporate** + **K. Global components**

### ประสาน dev ปิด defect (พบจากโค้ด)
- ยืนยันอีเมล token ผิด = เงียบ (A3), placeholder reset-password ผิด (A5)
- consent PDPA ฝั่ง BE, FE/BE phone regex, cleanup messageCard keys
