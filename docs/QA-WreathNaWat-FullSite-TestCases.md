# Full-Site Test Cases — Module ที่ยังไม่ถูกทดสอบ
## ระบบ: หรีด ณ วัด (Wreath Na Wat)

---

## 1. Document Information

| Field | Value |
|---|---|
| Project | Wreath Na Wat (หรีด ณ วัด) |
| Document Name | Full-Site Test Cases (นอกเหนือ Order Flow) |
| Source | `QA-WreathNaWat-FullSite-TestModules.md` + สำรวจ code จริงที่ `/home/sukawit1909/Web/WNW` |
| Environment | Staging (`wnw2025-frontend.dev-app-bit.com`) — **ห้าม payment จริง** |
| Date | 2026-06-29 |
| Prepared By | Senior QA Automation Engineer |

---

## 2. Scope & ความสัมพันธ์กับเอกสารเดิม

เอกสารนี้ออกแบบ test case **เฉพาะ module ที่ยังไม่มี/มีบางส่วน** ตาม Full-Site Map:

| กลุ่ม | Prefix | สถานะเดิม |
|---|---|---|
| A. Account / Auth | `TC-LOGIN / TC-REG / TC-CFM / TC-FGT / TC-RST / TC-USER / TC-OH` | ❌ ใหม่ทั้งหมด |
| B. Message Card / ป้ายหรีด Customizer | `TC-CARD` | 🟡 มีแค่ ribbon modal |
| F. Product Discovery (เพิ่มเติม) | `TC-DISC` | 🟡 listing บางส่วน |
| G. Content / SEO | `TC-CMS` | ❌ ใหม่ |
| H. LINE / B2B / OpenLine | `TC-LINE` | ❌ ใหม่ |
| I. Tracking (เพิ่มเติม) | `TC-TRK2` | 🟡 |
| J. Contact / Corporate | `TC-CT` | ❌ ใหม่ |
| K. Global Components | `TC-GBL` | 🟡 |
| L. Cross-cutting / Non-functional | `TC-XAPI / TC-XSESS / TC-XSEC / TC-XPERF` | ❌ เกือบไม่มี |

> **Order flow** (home/category/product/cart/checkout/coupon/payment/tracking-basic) อยู่ใน `QA-WreathNaWat-Checkout-OrderFlow-Final-TestCases.md` แล้ว — ไม่ทำซ้ำที่นี่

---

## 3. Test Data เพิ่มเติม (นอกจาก TD-01..24 เดิม)

| TD ID | Data Type | Required Data | ใช้กับ | Setup |
|---|---|---|---|---|
| TD-30 | Registered+verified user | email+password ที่ยืนยันแล้ว | TC-LOGIN-01, TC-USER-* | dev/สมัครเอง |
| TD-31 | Unverified user | email ที่ `email_verified_at=NULL` | TC-LOGIN-04 | dev |
| TD-32 | New email (ยังไม่เคยสมัคร) | email สดใหม่ | TC-REG-01 | mailbox ทดสอบ |
| TD-33 | Confirm token (valid/expired) | token จากเมล + token หมดอายุ | TC-CFM-01/03 | dev/inbox |
| TD-34 | Reset token (valid/expired/used) | token จาก forgot-password | TC-RST-* | flow forgot |
| TD-35 | Logo image (เล็ก/ใหญ่เกิน) | รูป <288px และ >288px, ไฟล์ non-image | TC-CARD-06/07/08 | เตรียมไฟล์ |
| TD-36 | สินค้า amount≥2 (หลายพวง) | สินค้า + จำนวน 2+ | TC-CARD-05, TC-CHK message count | cart |
| TD-37 | wizard cookie | `wizard_answers` (key_1..4) | TC-DISC-05 | set cookie |
| TD-38 | บทความ + ผู้เขียน | article slug + author slug จริง | TC-CMS-01..04 | ERP |
| TD-39 | Order ของ login user | order ผูกกับ web_user (pending+completed) | TC-OH-01/02 | dev |

---

## 4. Test Cases

> Status เริ่มต้น = **Not Run** • payment/transaction ทุกเคส = หยุดก่อนยืนยันจริง
> Level: UI / API / Integration / Manual • Code path อ้าง `/home/sukawit1909/Web/WNW`

---

## A. ACCOUNT / AUTH

### A.1 Login (modal ใน header) — `LoginForm.tsx`, `auth.ts`, `POST /web/login/`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-LOGIN-01 | login สำเร็จ | UI | Positive | High | TD-30 | 1.เปิด AuthModal 2.กรอก email+password ถูก 3.กด เข้าสู่ระบบ | modal ปิด, modal สำเร็จ "เข้าสู่ระบบสำเร็จ", redirect `/user-infos`, header แสดงชื่อผู้ใช้ | `LoginForm.tsx:62-81` | Not Run |
| TC-LOGIN-02 | ฟิลด์ว่าง | UI | Validation | Medium | — | 1.เว้น email/password 2.กดเข้าสู่ระบบ | error "กรุณาระบุอีเมลและรหัสผ่าน", ไม่ยิง API | `LoginSchema` | Not Run |
| TC-LOGIN-03 | รหัส/อีเมลผิด | UI | Negative | High | TD-30 | กรอก password ผิด → submit | error "รหัสหรืออีเมลผู้ใช้ไม่ถูกต้อง", status=failed | `auth.ts:127-146` | Not Run |
| TC-LOGIN-04 | อีเมลยังไม่ยืนยัน | UI | Negative | High | TD-31 | login ด้วย user ที่ยังไม่ยืนยัน | error "อีเมลผู้ใช้ ยังไม่ได้ยืนยันตัวตน / กรุณาตรวจสอบอีเมล" | `LoginForm.tsx` | Not Run |
| TC-LOGIN-05 | Remember Me = ON | UI | Functional | Medium | TD-30 | ติ๊ก rememberMe → login → ปิด browser → เปิดใหม่ | token อยู่ใน **localStorage**, ยัง login ค้าง | `auth.ts:132 setAccessToken(token,true)` | Not Run |
| TC-LOGIN-06 | Remember Me = OFF | UI | Functional | Medium | TD-30 | ไม่ติ๊ก → login → refresh tab | token อยู่ใน **sessionStorage** เท่านั้น | `auth.ts:132` | Not Run |
| TC-LOGIN-07 | guest cart sync หลัง login | Integration | Positive | Medium | TD-30 + มีของในตะกร้า (guest) | เพิ่มสินค้าแบบ guest → login | cart merge จาก `user.cart` ไม่หาย (`synUserCart`) | `LoginForm.tsx:64-66` | Not Run |
| TC-LOGIN-08 | กันกดซ้ำ | UI | Race | Low | TD-30 | กดปุ่มเข้าสู่ระบบรัว | ปุ่ม disable ("กำลังเข้าสู่ระบบ"), ยิง API ครั้งเดียว | `LoginForm.tsx` | Not Run |

### A.2 Register (modal) — `RegisterForm.tsx`, `POST /web/register`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-REG-01 | สมัครสำเร็จ | UI | Positive | High | TD-32 | กรอก email ใหม่ + password ผ่านกฎ + ติ๊ก privacy → สมัคร | modal สำเร็จ "ลงทะเบียนสำเร็จ / กรุณาตรวจสอบอีเมลเพื่อยืนยัน", **ไม่ auto-login** | `RegisterForm.tsx:46-55` | Not Run |
| TC-REG-02 | email ซ้ำ | UI | Negative | High | TD-30 | สมัครด้วย email ที่มีแล้ว | error จาก backend ใต้ช่อง email | `auth.ts:41-56` | Not Run |
| TC-REG-03 | password สั้น (<8) | UI | Boundary | High | — | password 7 ตัว | "รหัสผ่านต้องมีความยาวเกิน 8 ตัวอักษร" | `validation/checkout.ts:74-83` | Not Run |
| TC-REG-04 | password ยาว (>16) | UI | Boundary | Medium | — | password 17 ตัว | "รหัสผ่านมีความยาวเกิน 16 ตัวอักษร" | เดียวกัน | Not Run |
| TC-REG-05 | ขาดพิมพ์ใหญ่ | UI | Validation | Medium | — | password ไม่มี A-Z | "รหัสผ่านต้องมีตัวอักษรพิมพ์ใหญ่อย่างน้อย 1 ตัว" | เดียวกัน | Not Run |
| TC-REG-06 | ขาดพิมพ์เล็ก | UI | Validation | Medium | — | ไม่มี a-z | "...พิมพ์เล็กอย่างน้อย 1 ตัว" | เดียวกัน | Not Run |
| TC-REG-07 | ขาดตัวเลข | UI | Validation | Medium | — | ไม่มี 0-9 | "...ตัวเลขอย่างน้อย 1 ตัว" | เดียวกัน | Not Run |
| TC-REG-08 | ขาดอักขระพิเศษ | UI | Validation | Medium | — | ไม่มี special char | "...อักขระพิเศษอย่างน้อย 1 ตัว" | เดียวกัน | Not Run |
| TC-REG-09 | มีช่องว่าง | UI | Validation | Medium | — | password มี space | "รหัสผ่านต้องไม่มีช่องว่าง" | เดียวกัน | Not Run |
| TC-REG-10 | email format ผิด | UI | Validation | Medium | — | "abc", "a@", มี space | "กรุณากรอกอีเมลที่ถูกต้อง" / "ไม่สามารถใส่ค่าว่างใน Email ได้" | เดียวกัน | Not Run |
| TC-REG-11 | ไม่ติ๊ก privacy | UI | Validation | High | — | กรอกครบ ไม่ติ๊ก → สมัคร | "กรุณายอมรับนโยบายความเป็นส่วนตัว" | `RegisterSchema` | Not Run |
| TC-REG-12 | toggle show password | UI | Functional | Low | — | คลิก eye icon | สลับ password ↔ text | `RegisterForm.tsx` | Not Run |
| TC-REG-13 | privacy link เปิดแท็บใหม่ | UI | Functional | Low | — | คลิกลิงก์นโยบาย | เปิด `/นโยบายความเป็นส่วนตัว/` target=_blank | `RegisterForm.tsx` | Not Run |

### A.3 ยืนยันอีเมล — `/user-confirm-email?k={token}`, `POST /web/confirm-email/{token}`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-CFM-01 | token ถูก | UI | Positive | High | TD-33 valid | เปิดลิงก์จากเมล | "ยืนยันอีเมลสำเร็จ" + countdown 5→0 → redirect `/` | `user-confirm-email/Content.tsx:16-35` | Not Run |
| TC-CFM-02 | ไม่มี token | UI | Negative | Medium | — | เปิด `/user-confirm-email` ไม่มี `k` | **🐞 หน้าเงียบ ไม่มีข้อความ** (ควรมี error) — flag UX | เดียวกัน | Not Run |
| TC-CFM-03 | token ผิด/หมดอายุ | UI | Negative | Medium | TD-33 expired | เปิดลิงก์ token ปลอม | API fail → ปัจจุบันเงียบ — flag | เดียวกัน | Not Run |
| TC-CFM-04 | ยืนยันซ้ำ | API | Negative | Low | TD-33 used | เรียก confirm ซ้ำ | idempotent หรือ error ไม่ crash | endpoint | Not Run |
| TC-CFM-05 | navigate ออกระหว่าง countdown | UI | Functional | Low | TD-33 valid | ยืนยันสำเร็จ → คลิกออกก่อนครบ 5 วิ | timer clear ไม่ redirect ทับ | `useEffect cleanup` | Not Run |

### A.4 ลืมรหัสผ่าน — `/forget-password`, `POST /web/forgot-password`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-FGT-01 | ส่งลิงก์สำเร็จ | UI | Positive | High | TD-30 | กรอก email → ส่ง | "ส่งลิงก์สำเร็จ กรุณาตรวจสอบอีเมล", ฟอร์มซ่อน | `forget-password/page.tsx:14-31` | Not Run |
| TC-FGT-02 | error path | UI | Negative | Medium | mock 500 | ทำให้ API error | "เกิดข้อผิดพลาดในการส่งลิงก์ กรุณาลองใหม่อีกครั้ง" | เดียวกัน | Not Run |
| TC-FGT-03 | ช่องว่าง/ไม่ใช่อีเมล | UI/API | Negative | Medium | — | กรอกว่าง/"abc" → ส่ง | **ไม่มี client validation** → BE ต้องจัดการ (ตรวจ response) | เดียวกัน | Not Run |
| TC-FGT-04 | กันกดซ้ำ | UI | Race | Low | TD-30 | กดส่งรัว | ปุ่ม disable ("กำลังดำเนินการ") | เดียวกัน | Not Run |

### A.5 รีเซ็ตรหัส — `/user-reset-password?k={token}`, `POST /web/new-password`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-RST-01 | รีเซ็ตสำเร็จ | UI | Positive | High | TD-34 valid | เปิดลิงก์ → กรอกรหัสใหม่ → ยืนยัน | "เปลี่ยนรหัสผ่านสำเร็จแล้ว" | `user-reset-password/Content.tsx:19-44` | Not Run |
| TC-RST-02 | ไม่มี token | UI | Negative | Medium | — | เปิดหน้าไม่มี `k` → submit | `alert('Token is missing in the URL')` | เดียวกัน | Not Run |
| TC-RST-03 | token ผิด/หมดอายุ/ใช้แล้ว | UI | Negative | Medium | TD-34 expired/used | ใช้ token ปลอม | "เกิดข้อผิดพลาดในการเปลี่ยนรหัสผ่าน" | เดียวกัน | Not Run |
| TC-RST-04 | placeholder ผิด | UI | Bug | Low | — | สังเกต placeholder | **🐞 เขียน "กรอกรหัสผ่านเดิม" แต่จริงต้องกรอกรหัสใหม่** — flag | `Content.tsx:57` | Not Run |
| TC-RST-05 | complexity FE vs BE | API | Validation | Medium | TD-34 valid | ส่ง password สั้น/ไม่ครบกฎ | FE ไม่บังคับ → ตรวจว่า BE บังคับ min 8 + กฎหรือไม่ | เทียบกับ RegisterSchema | Not Run |

### A.6 ข้อมูลผู้ใช้ — `/user-infos` (protected), `GET/PATCH /web/user`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-USER-01 | เข้าโดยไม่ login | UI | Security | High | guest | เปิด `/user-infos` ตรง | หน้าว่าง/redirect (ปัจจุบัน `{isAuth && ...}` → ว่าง) — ตรวจ behavior | `user-infos/page.tsx` | Not Run |
| TC-USER-02 | prefill ข้อมูล | UI | Positive | Medium | TD-30 | เปิดหน้าหลัง login | ฟอร์ม prefill จาก `user` (name/phone/address/receipt) | `UserInforSection.tsx` | Not Run |
| TC-USER-03 | update ข้อมูลส่วนตัว | UI | Positive | High | TD-30 | แก้ name/phone/address → อัปเดต | toast "อัปเดตข้อมูลส่วนตัวสำเร็จ", refetch | เดียวกัน | Not Run |
| TC-USER-04 | name ว่าง | UI | Validation | Medium | TD-30 | ลบ name → อัปเดต | "กรุณากรอกชื่อ-สกุล" | `validatePersonalInfo` | Not Run |
| TC-USER-05 | email disabled | UI | Functional | Low | TD-30 | ลองแก้ช่อง email | แก้ไม่ได้ (gray, read-only) | `UserInforSection.tsx` | Not Run |
| TC-USER-06 | ใบกำกับ required | UI | Validation | Medium | TD-30 | เว้น issue_to/tax_id/email/address → อัปเดต | error ใต้แต่ละช่องที่ขาด | `validateReceiptInfo` | Not Run |
| TC-USER-07 | tax_id boundary 13 | UI | Boundary | Medium | TD-30 | พิมพ์ tax_id 14 หลัก | บล็อกพิมพ์เกิน 13 + error ถ้าเกิน | `handleNestedChange:231` | Not Run |
| TC-USER-08 | เปลี่ยนรหัส สำเร็จ | UI | Positive | High | TD-30 | เปิด modal → currentPwd ถูก + newPwd ผ่านกฎ | toast "เปลี่ยนรหัสผ่านสำเร็จ", modal ปิด | `PasswordChangeModal.tsx` | Not Run |
| TC-USER-09 | รหัสเดิมผิด | UI | Negative | High | TD-30 | currentPwd ผิด | "รหัสเดิมไม่ถูกต้อง" | เดียวกัน | Not Run |
| TC-USER-10 | newPwd ไม่ผ่านกฎ | UI | Validation | Medium | TD-30 | newPwd อ่อน | error เหมือน register (ครบ 7 กรณี) | `ChangePasswordSchema` | Not Run |
| TC-USER-11 | EDM checkbox | UI | Functional | Low | TD-30 | ติ๊ก/ไม่ติ๊ก → อัปเดต | `accept_for_edm` persist | เดียวกัน | Not Run |
| TC-USER-12 | logout | UI | Functional | High | TD-30 | กด Log Out | clear state+storage, redirect `/` | `handleLogOut` | Not Run |
| TC-USER-13 | tab switch desktop/mobile | UI | Functional | Low | TD-30 | สลับแท็บข้อมูล/ออเดอร์ | render ถูก, mobile accordion | `UserInforSection` | Not Run |

### A.7 ประวัติออเดอร์ — `OrdersSection.tsx`, `GET /web/user`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-OH-01 | แสดง pending+completed | UI | Positive | Medium | TD-39 | เปิดแท็บรายการสั่งซื้อ | 2 section แสดง order code/รายการ/จำนวน + badge pending count | `OrdersSection.tsx` | Not Run |
| TC-OH-02 | empty state | UI | Positive | Low | user ไม่มีออเดอร์ | เปิดแท็บ | "- ยังไม่มีรายการสั่งซื้อ -" ทั้ง 2 section | เดียวกัน | Not Run |
| TC-OH-03 | copy order code | UI | Functional | Low | TD-39 | คลิกปุ่ม copy | clipboard ได้ค่า + "คัดลอกเลขออเดอร์สำเร็จ" 1.5 วิ | เดียวกัน | Not Run |
| TC-OH-04 | ลิงก์ติดต่อ LINE | UI | Functional | Low | TD-39 | คลิก "ติดต่อทีมงานผ่าน LINE" | เปิด `/line` แท็บใหม่ | เดียวกัน | Not Run |

---

## B. MESSAGE CARD / ป้ายหรีด CUSTOMIZER — `MessageCardModal.tsx`, `card-preview/final/size`, `media`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-CARD-01 | preview real-time | UI | Positive | High | สินค้าใน checkout | เปิด modal → พิมพ์บรรทัด 1 | หลัง 888ms preview รูปอัปเดต (base64) | `MessageCardModal.tsx` debounce | Not Run |
| TC-CARD-02 | เปลี่ยน tone/format/align | UI | Functional | Medium | เปิด modal | สลับขาว/ดำ, format 1/2/3, ซ้าย/ขวา | preview เปลี่ยนตาม | เดียวกัน | Not Run |
| TC-CARD-03 | บรรทัด 1 ว่าง | UI | Validation | High | เปิด modal | เว้นบรรทัด 1 (หรือใส่ space) | ปุ่มบันทึก disable + "กรุณาระบุข้อความบรรทัดที่ 1" | `shouldDisableButton` | Not Run |
| TC-CARD-04 | บันทึก → card-final | Integration | Positive | High | กรอกบรรทัด 1 | กดบันทึก | ได้ finalId+finalUrl เก็บ `messageCardModal-{n}-{code}` | `card-final` | Not Run |
| TC-CARD-05 | หลายพวง validate แยก | Integration | Positive | High | TD-36 (2 พวง) | กรอกป้ายพวงที่ 1 ไม่กรอกพวงที่ 2 → submit checkout | submit disable "กรุณากรอกข้อความป้ายให้ครบทุกพวงหรีด" | `validateMessageCards` | Not Run |
| TC-CARD-06 | โลโก้ใหญ่เกิน 20×20cm | UI | Validation | Medium | TD-35 รูปใหญ่ | อัปโลโก้ >288px | toast "รูปมีขนาดใหญ่เกินไป กรุณาใช้รูปที่เล็กลง" | `MessageCardModal.tsx` | Not Run |
| TC-CARD-07 | อัปโหลดล้มเหลว | UI | Negative | Medium | mock media error | อัปโลโก้ตอน API down | toast "...กรุณาลองใหม่อีกครั้ง" | `media.ts` | Not Run |
| TC-CARD-08 | ไฟล์ไม่ใช่รูป | UI | Negative | Low | TD-35 non-image | เลือก .pdf | `accept="image/*"` กรอง / BE reject | เดียวกัน | Not Run |
| TC-CARD-09 | ลบโลโก้แล้วอัปใหม่ | UI | Functional | Low | เปิด modal | อัป → ลบ → อัปใหม่ | logoID reset แล้วได้ค่าใหม่ | เดียวกัน | Not Run |
| TC-CARD-10 | ลบสินค้า → cleanup key | Integration | Session | High | มีป้าย+สินค้า | ลบสินค้าออกจาก cart | `messageCardModal-*` ถูกล้าง (ไม่รั่วไปออเดอร์ใหม่) | `useCart:43-53` | Not Run |
| TC-CARD-11 | payload attachments | API | Integration | Medium | กรอกป้ายครบ | submit order | `attachments[]` มี logo_id/card_id/attached_message_1/2 ถูก | `getProductPayload:81-137` | Not Run |
| TC-CARD-12 | card-size default | UI | Positive | Low | เปิด MessageCardForWreath | โหลด component | แสดงขนาด/พื้นหลัง default จาก `card-size` | `card-size.ts` | Not Run |

---

## F. PRODUCT DISCOVERY (เพิ่มเติม) — `products`, `filter.ts` ฯลฯ

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-DISC-01 | sort mapping | UI | Functional | Medium | listing | เลือก "แนะนำ" / "ช่วงราคา" | URL/query → `recommend` / `price`, ลำดับเปลี่ยน | `filter.ts:41-42` | Not Run |
| TC-DISC-02 | filter tag (and/or) | UI | Functional | Medium | listing | เลือกหลาย tag | `tag_ids_operand` and/or ถูกต้อง | `StoreController::_products` | Not Run |
| TC-DISC-03 | search `?keyword=` | UI | Functional | Medium | — | เปิด `/ร้านพวงหรีด/...?keyword=xxx` | กรองตาม keyword (ไม่มีกล่อง UI) | `products/page.tsx:62-68` | Not Run |
| TC-DISC-04 | pagination + คง URL | UI | Functional | Medium | listing >15 ชิ้น | เปลี่ยนหน้า → refresh | 15/หน้า, state คงใน URL | เดียวกัน | Not Run |
| TC-DISC-05 | wizard แนะนำเฉพาะคุณ | UI | Functional | Medium | TD-37 | เปิด `products-special` ที่มี cookie | สินค้าตรง key_1..4, load more 20 | `products-special/page.tsx` | Not Run |
| TC-DISC-06 | EXCLUDED_TAGS ไม่โผล่ | API | Negative | Medium | หมวดมี excluded tag | ดู listing | สินค้า excluded ไม่แสดง | `process_excluded_tags` | Not Run |
| TC-DISC-07 | allow_add_to_cart=false | UI | Negative | Medium | TD-04 | เปิด PDP สินค้าสั่งไม่ได้ | ซ่อน Buy Now + แสดงลิงก์ LINE | `ProductButton.tsx:131-150` | Not Run |
| TC-DISC-08 | ราคา promotion vs regular | UI | Functional | Medium | สินค้ามีโปร | เปิด PDP/listing | แสดงราคาโปร + ราคาตัดทอน | `_products` promotion | Not Run |
| TC-DISC-09 | express/promotion/donate | UI | Smoke | Low | — | เปิด `product-express`, `wreath-promotion`, `wreath-donate` | render, ปุ่ม LINE/pagination ทำงาน | routes | Not Run |
| TC-DISC-10 | near-temple/near-me | UI | Smoke | Low | — | เปิด `servicelocation/[slug]`, `wreath-nearme` | location selector ตามจังหวัด | routes | Not Run |

---

## G. CONTENT / SEO (smoke) — articles, service pages ฯลฯ

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-CMS-01 | บทความ listing + filter | UI | Functional | Medium | TD-38 | เปิด `/บทความ`, เลือก category | filter ทำงาน, pagination 20/หน้า | `article/page.tsx` | Not Run |
| TC-CMS-02 | บทความ detail | UI | Smoke | Low | TD-38 | เปิด `/บทความ/[slug]` | render เนื้อหา + JSON-LD BreadcrumbList | `article/[slug]` | Not Run |
| TC-CMS-03 | ผู้เขียน | UI | Smoke | Low | TD-38 | เปิด `/ผู้เขียน/[slug]` | บทความตาม author | `author-article/[slug]` | Not Run |
| TC-CMS-04 | service pages static | UI | Smoke | Low | — | เปิด service-funeral, all-service (crematory/pet/relics ตัดออก — 404 บน staging) | 200, มี title/meta/og/canonical, breadcrumb, ข้อมูลติดต่อ | routes | Not Run |
| TC-CMS-05 | info pages | UI | Smoke | Low | — | เปิด about-us/how-to-order/faqs/privacy/compensation/flower-shop/review-wreath | render + responsive | routes | Not Run |
| TC-CMS-06 | dynamic [...slug] router | UI | Functional | Medium | — | เปิด slug ตาม switch ต่างๆ | route ไปหน้าถูก, Thai URL decode | `[...slug]/page.tsx` | Not Run |
| TC-CMS-07 | slug มั่ว → 404 | UI | Negative | Medium | — | เปิด slug ไม่มีจริง | `NotfoundPage` (404) | เดียวกัน | Not Run |
| TC-CMS-08 | sitemap | API | Smoke | Low | — | เปิด `/sitemap/*` | XML ถูกต้อง | `pages/sitemap/*` | Not Run |

---

## H. LINE / B2B / OPENLINE — `line*`, `openline*/[slug]`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-LINE-01 | /line set cookie+QR | UI | Functional | Medium | clear cookie | เปิด `/line` ครั้งแรก | สร้าง UUID, set `user_id` (30วัน), QR ชี้ `/openline/{uuid}` | `line/page.tsx` | Not Run |
| TC-LINE-02 | cookie persist | UI | Functional | Low | มี cookie | refresh `/line` | `user_id` คงเดิม ไม่สร้างใหม่ | เดียวกัน | Not Run |
| TC-LINE-03 | openline redirect | UI | Functional | Medium | — | เปิด `/openline/{uuid}` | set cookie + redirect `page.line.me/wreathnawat` | `openline/[slug]` | Not Run |
| TC-LINE-04 | b2b แยก cookie/redirect | UI | Functional | Medium | — | เปิด `/lineb2b` → `/openlineb2b/{uuid}` | cookie `user_id_b2b`, redirect `@237rjmhp` | `lineb2b`, `openlineb2b` | Not Run |
| TC-LINE-05 | event แยก cookie/redirect | UI | Functional | Medium | — | เปิด `/line-event` → `/openline-event/{uuid}` | cookie `user_id_event`, redirect `@175ctrfd` | `line-event`, `openline-event` | Not Run |
| TC-LINE-06 | 3 cookie ไม่ชนกัน | UI | Functional | Low | — | เปิดทั้ง 3 flow | `user_id`/`user_id_b2b`/`user_id_event` แยกอิสระ | ทั้ง 3 หน้า | Not Run |

---

## I. TRACKING (เพิ่มเติม) — `tracking/page.tsx`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-TRK2-01 | ค้นด้วย order_code+เบอร์/อีเมล | UI | Positive | Medium | TD-22 | กรอก order_code + phone_or_email → ค้นหา | แสดงสถานะ (path ที่ 2) | `tracking/page.tsx:36-44` | Not Run |
| TC-TRK2-02 | status 0/1 → notpayment | UI | Functional | Medium | TD-20 | track order ยังไม่จ่าย | แสดง `ResultNotpayment` | `:140-160` | Not Run |
| TC-TRK2-03 | status 2/3/4 → result | UI | Functional | Medium | TD-21 | track order จ่ายแล้ว | แสดง `Result` | เดียวกัน | Not Run |
| TC-TRK2-04 | notFound ไม่ leak | UI | Negative | Medium | — | กรอกข้อมูลผิด | branch notFound, ไม่โชว์ข้อมูลคนอื่น | `:55-58` | Not Run |
| TC-TRK2-05 | tax invoice module | UI | Functional | Low | flag=y | track order ที่จ่ายแล้ว | fetch hash + แสดงฟอร์มใบกำกับ | `NEXT_PUBLIC_ENABLED_TAX_INVOICE_MODULE` | Not Run |
| TC-TRK2-06 | quotation flow | UI | Functional | Low | — | เปิด `/tracking/quotation` | render flow ใบเสนอราคา | `tracking/quotation` | Not Run |

---

## J. CONTACT / CORPORATE — `contactus`, `corporate-customer`

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-CT-01 | contact reveal toggle | UI | Functional | Low | — | เปิด `/ติดต่อเรา`, คลิก LINE/โทร/อีเมล | เผยลิงก์ถูก (line/tel:/mailto:) | `contactus/page.tsx` | Not Run |
| TC-CT-02 | corporate FAQ accordion | UI | Functional | Low | — | เปิด `/ลูกค้าองค์กร`, toggle FAQ 4 ข้อ | เปิด/ปิดถูกต้อง | `corporate-customer/page.tsx` | Not Run |
| TC-CT-03 | corporate contact + gallery | UI | Functional | Low | — | คลิก 6 ปุ่ม contact, ดู gallery | ไป `/lineb2b`/tel/mailto, รูป 20 โหลด | เดียวกัน | Not Run |

---

## K. GLOBAL COMPONENTS — header/footer

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-GBL-01 | announcement bar | UI | Functional | Low | มี announcement active | โหลดทุกหน้า | bar แสดงข้อความ + ปิดได้ | `AnnouncementBar.tsx`, `/announcement/active` | Not Run |
| TC-GBL-02 | mini-cart badge+dropdown | UI | Functional | Medium | มีของในตะกร้า | คลิกไอคอนตะกร้า | badge จำนวนถูก, dropdown รายการ | `ShoppingCart.tsx` | Not Run |
| TC-GBL-03 | floating contact / sticky bar | UI | Functional | Low | mobile | เลื่อนหน้า | FloatingContactButton + StickyBars แสดง/คลิกได้ | `Footer/*` | Not Run |
| TC-GBL-04 | back to top | UI | Functional | Low | หน้ายาว | เลื่อนลง → คลิก | scroll กลับบนสุด | `BackToTop.tsx` | Not Run |
| TC-GBL-05 | responsive nav (hamburger) | UI | Functional | Medium | mobile viewport | เปิดเมนูมือถือ | MobileNavBar เปิด/นำทางถูก | `MobileNavBar.tsx` | Not Run |

---

## L. CROSS-CUTTING / NON-FUNCTIONAL

| TC ID | Feature | Level | Type | Priority | Preconditions | Test Steps | Expected Result | Code Evidence | Status |
|---|---|---|---|---|---|---|---|---|---|
| TC-XAPI-01 | ERP 422 → modal | API/UI | Negative | High | mock 422 | submit order/total | proxy `{error:true}` → openErrorModal ไม่ crash | `pages/api/order.ts catch` | Not Run |
| TC-XAPI-02 | ERP 500/timeout | API/UI | Negative | High | mock 500/delay | เรียก total-payment/order | modal error, ไม่ค้าง/crash | `instance.ts` interceptors | Not Run |
| TC-XSESS-01 | 401 → clear+reload | UI | Session | High | login + mock 401 | เรียก ERP_API ระหว่าง flow | `clearStorage()` + reload | `instance.ts` ERP_API | Not Run |
| TC-XSESS-02 | token หมดอายุกลาง flow | UI | Session | Medium | token หมดอายุ | กระทำต่อ | จัดการ session หมด ไม่ค้าง | เดียวกัน | Not Run |
| TC-XSEC-01 | consent bypass (PDPA) | API | Security | High | — | POST `/api/order` ไม่มี privacy_policy | **BE ไม่ block** → flag ความเสี่ยง + แจ้ง dev | `OrderController::store` (ไม่มี rule) | Not Run |
| TC-XSEC-02 | phone FE≠BE | API | Security | Medium | — | ส่ง `+66...`/มี space ตรง API | FE reject แต่ BE รับ → flag inconsistency | `validation.ts` vs `OrderController` | Not Run |
| TC-XSEC-03 | line_id regex | UI | Validation | Low | checkout | line_id อักษรใหญ่/>20 | FE reject ตาม `^[a-z0-9_-]{,20}$` | `validation.ts:27-33` | Not Run |
| TC-XSEC-04 | XSS/SQLi ในป้าย/ศาลา | API | Security | Medium | — | กรอก `<script>` / `' OR '1'='1` | ไม่ execute/ไม่ 500 (Eloquent param) | `OrderController::store` | Not Run |
| TC-XPERF-01 | double-submit ชำระ | UI | Race | High | กรอก checkout ครบ | กดชำระรัว 2 ครั้ง | `isSubmitting` block ครั้งที่ 2, ไม่สร้างออเดอร์ซ้ำ | `CheckoutForm:onSubmit` | Not Run |
| TC-XPERF-02 | SEO/JSON-LD/canonical | UI | Functional | Low | — | ตรวจ meta/og/JSON-LD หน้า PDP/article | structured data ครบ, canonical ถูก | page metadata | Not Run |
| TC-XPERF-03 | responsive/cross-browser | UI | Compat | Low | — | ทดสอบ datepicker/upload/clipboard บนมือถือ | ทำงานข้าม browser/อุปกรณ์ | ทั่วไป | Not Run |

---

## 5. สรุปจำนวน Test Case

| กลุ่ม | จำนวน | Priority สูง |
|---|---|---|
| A. Account/Auth (Login 8 + Reg 13 + Confirm 5 + Forgot 4 + Reset 5 + User 13 + OrderHist 4) | 52 | 14 |
| B. Message Card | 12 | 5 |
| F. Product Discovery | 10 | 0 |
| G. Content/SEO | 8 | 0 |
| H. LINE flows | 6 | 0 |
| I. Tracking+ | 6 | 0 |
| J. Contact/Corporate | 3 | 0 |
| K. Global | 5 | 0 |
| L. Cross-cutting | 11 | 6 |
| **รวมใหม่** | **113** | **25** |

> รวมกับ Order Flow เดิม (~60 เคส) → ทั้งระบบ **~170 test cases**

---

## 6. ลำดับ Execution แนะนำ

1. **Sprint 1 (ไม่ต้องรอ data):** A (Auth ทั้งชุด), L (XAPI/XSESS/XPERF double-submit), B (Message Card)
2. **Sprint 2 (รอ dev data):** C (Coupon) + E (Payment) จากเอกสารเดิม + TD coupon/2C2P
3. **Sprint 3 (กว้าง):** F, H, I+, K
4. **Sprint 4 (smoke):** G, J + XSEC (ประสาน dev ปิด defect)

## 7. Defect ที่ต้องแจ้ง dev (พบจาก code)
- **DEF-A1:** `/user-confirm-email` token ผิด/ไม่มี → หน้าเงียบ ไม่มี error message (TC-CFM-02/03)
- **DEF-A2:** `/user-reset-password` placeholder "กรอกรหัสผ่านเดิม" ผิด ควรเป็น "รหัสผ่านใหม่" (TC-RST-04)
- **DEF-A3:** reset-password ไม่บังคับ complexity ฝั่ง FE (TC-RST-05)
- **DEF-L1:** consent/PDPA ไม่ enforce ฝั่ง BE (TC-XSEC-01)
- **DEF-L2:** phone regex FE≠BE (TC-XSEC-02)
