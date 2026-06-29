# QA Test Plan — Flow การสั่งซื้อสินค้า: หรีด ณ วัด (Wreath Na Wat)

| | |
|---|---|
| **ระบบ** | หรีด ณ วัด (Wreath Na Wat) — ร้านขายพวงหรีด/ดอกไม้งานศพออนไลน์ |
| **Environment** | `https://wnw2025-frontend.dev-app-bit.com/` (DEV) |
| **ผู้จัดทำ** | Senior QA Automation Engineer |
| **วันที่** | 2026-06-25 |
| **ขอบเขต** | Flow การสั่งซื้อสินค้า (Home → Category → Product → Cart → Checkout → Payment → Order Success → Tracking) |

> **หมายเหตุวิธีการสำรวจ (สำคัญ):** รอบนี้ไม่มี Chrome browser เชื่อมต่อกับเครื่องมือ automation จึงสำรวจผ่านการ fetch หน้าเว็บจริง (server-rendered HTML) หลายหน้าได้ครบเรื่องโครงสร้าง/ฟิลด์/flow แต่**ยังไม่ได้ execute การคลิก/กรอกฟอร์มแบบ interactive** ดังนั้น Test Case ทุกเคสจึงสถานะ `Not Run` และ Actual Result = `N/A` ส่วน Defect ที่พบเป็นระดับ "พบจากการวิเคราะห์โครงสร้าง ต้องยืนยันด้วยการ execute จริงอีกครั้ง"
>
> **ข้อกำหนดความปลอดภัย:** เว็บนี้เป็น env ทดสอบ — **ห้ามทำรายการชำระเงินจริง** ทดสอบถึงหน้าก่อนยืนยันชำระเท่านั้น หรือใช้ payment sandbox

---

## 1) Website Flow Summary

### 1.1 Flow การสั่งซื้อหลัก (Happy Path)

```
Home → เลือกหมวด/แบนเนอร์ → Category Listing (Filter/Sort/Paginate)
     → Product Detail → "เพิ่มลงตะกร้า" หรือ "ซื้อทันที"
     → Cart (สรุปยอด) → Checkout (ข้อมูลจัดส่ง+ผู้สั่ง+ส่วนลด+วิธีชำระ)
     → ชำระเงิน (QR/โอน/บัตร) → Order Success → ติดตามสถานะ
```

### 1.2 Module / Page ที่พบ

| # | Module / Page | URL | Action ที่ทำได้ | จุดสังเกต / ความเสี่ยง |
|---|---|---|---|---|
| 1 | Home | `/` | เมนู dropdown 7 หมวด, แบนเนอร์, ลิงก์ตะกร้า, LINE, โทร | เมนูหลักเป็น `href="#"` (dropdown JS) — เสี่ยง SEO/ลิงก์ค้าง |
| 2 | Category / Listing | `/ร้านพวงหรีด/พวงหรีดดอกไม้สด/` ฯลฯ | Filter, Sort (4 แบบ), Pagination (สูงสุด ~12 หน้า), Add to Cart | มี 177 สินค้าในหมวด — เหมาะ test pagination/sort |
| 3 | Banner Collections | `/ร้านพวงหรีด/สินค้าขายดี/`, `/สินค้าราคาพิเศษ/`, `/สินค้าส่งด่วน/`, `/พวงหรีดใกล้วัด/`, `/พวงหรีดใกล้ฉัน/` | Listing แบบกรองพิเศษ | ตรวจว่าผลตรงเงื่อนไข collection |
| 4 | Product Detail (PDP) | `/พวงหรีด/<slug>/` | ดูข้อมูล, "เพิ่มลงตะกร้า", "ซื้อทันที!", สินค้าแนะนำ, breadcrumb, ลิงก์รีวิว | **ไม่มี** ช่องเลือกจำนวน, ไม่มีตัวเลือกไซซ์, **ไม่มีช่องข้อความริบบิ้น** |
| 5 | Cart | `/cart/` | ดูรายการ, ยอดรวม, ปุ่มไปขั้นชำระเงิน, ปุ่มต่างจังหวัด→LINE | Empty state: "- คุณยังไม่มีสินค้าในตะกร้า -"; โค้ดส่วนลดแจ้งว่า "อยู่ขั้นตอนถัดไป" |
| 6 | Checkout | `/checkout/` | กรอกข้อมูลจัดส่ง/ผู้สั่ง, ใส่โค้ดส่วนลด, เลือกวิธีชำระ, กด "ชำระเงิน" | ดูฟิลด์ละเอียดในตาราง 1.3 |
| 7 | Payment | (ขั้นถัดจาก checkout) | QR PromptPay / โอนผ่านธนาคาร (KBank, BBL, KTB) / บัตรเครดิต-เดบิต (+3%) | **ห้ามทำ transaction จริง** |
| 8 | Order Success | (ขั้นถัดจากชำระ) | แสดงเลขออเดอร์/สรุป | ต้องยืนยันว่ามีหน้านี้จริงและให้เลข tracking |
| 9 | Order Tracking | `/ติดตามสถานะ/` | กรอก Tracking ID **หรือ** เลขออเดอร์ + เบอร์/อีเมล | ดูเหมือนนำทางไป LINE/ติดต่อทีม มากกว่า self-service อัตโนมัติ |
| 10 | Help / FAQ | `/faqs/` | อ่านคำถาม-คำตอบ | หัวข้อ: พื้นที่จัดส่ง, เวลาผลิต/ส่ง, ส่งด่วน/วันเดียว, ปรับแต่ง, ใบกำกับภาษี, คืนเงิน |
| 11 | Static/Policy | `/เกี่ยวกับเรา/`, `/นโยบายความเป็นส่วนตัว/`, `/นโยบายชดเชย/`, `/ติดต่อเรา/`, `/บทความ/`, `/รีวิวสินค้า/` | อ่านอย่างเดียว | ตรวจลิงก์เสีย/404 |

### 1.3 Checkout — ฟิลด์ที่พบ

| Section | Field (label ไทย) | Type | Required |
|---|---|---|---|
| ข้อมูลจัดส่ง | ศาลา (ชื่อวัด/สถานที่) | text | สังเกตว่าน่าจะ required |
| ข้อมูลจัดส่ง | ชื่อ-นามสกุล (ผู้เสียชีวิต) | text | ✅ (*) |
| ข้อมูลจัดส่ง | เบอร์โทรศัพท์สำหรับติดต่อ | text/tel | ✅ (*) |
| ข้อมูลจัดส่ง | เลือกเวลาจัดส่ง | dropdown | ✅ (*) |
| ข้อมูลผู้สั่ง | ชื่อ-สกุล | text | ✅ (*) |
| ข้อมูลผู้สั่ง | อีเมล | email | ✅ (*) |
| ข้อมูลผู้สั่ง | เบอร์โทร | tel | ✅ (*) |
| ตัวเลือก | สมัครสมาชิกเพื่อความสะดวกในการสั่งซื้อ | checkbox | optional |
| ตัวเลือก | ยินยอมตามนโยบายความเป็นส่วนตัว | checkbox | บังคับ (เพื่อกดชำระ) |
| ตัวเลือก | รับข่าวสาร/โปรโมชัน | checkbox | optional |
| สรุป | รหัสส่วนลด | text + ปุ่ม Apply | optional |
| ชำระเงิน | QR/โอนธนาคาร \| บัตรเครดิต-เดบิต (+3%) | radio | ✅ |
| ปุ่ม | ชำระเงิน | button | — |

### 1.4 Business Rules / ข้อสังเกตสำคัญ

- จัดส่งฟรี กรุงเทพฯ–ปริมณฑล; **ต่างจังหวัดต้องสั่งผ่าน LINE** (แยก flow ออกจากเว็บ)
- บัตรเครดิต/เดบิต มีค่าธรรมเนียม **+3%** (ต้องตรวจการคำนวณยอดรวม)
- โมเดลเป็น **Guest Checkout เป็นหลัก** (สมัครสมาชิกเป็นแค่ checkbox) — `/login/` ตอบ **404**
- **ไม่พบช่องกรอกข้อความริบบิ้น/ป้ายคำไว้อาลัย** ในทั้ง PDP และ Checkout (สำคัญมากสำหรับพวงหรีด)
- **ไม่พบตัวเลือก "วันที่" จัดส่ง** มีเพียง "เวลา"
- **ไม่พบช่อง Search** ทั่วทั้งเว็บ

---

## 2) Test Scenario List

| Scenario ID | Module | Scenario Name | Description | Priority | Test Type |
|---|---|---|---|---|---|
| SC-HOME-01 | Home | นำทางจากเมนู/แบนเนอร์ | คลิกเมนู dropdown และแบนเนอร์ไปยังหมวดที่ถูกต้อง | High | Positive |
| SC-HOME-02 | Home | ลิงก์ติดต่อ/โซเชียล | LINE, โทร, FB, IG ทำงานถูกต้อง | Low | Positive |
| SC-CAT-01 | Category | แสดงรายการสินค้า | โหลด listing + ราคา + badge ถูกต้อง | High | Positive |
| SC-CAT-02 | Category | Sort | เรียง 4 แบบ (แนะนำ/ใหม่/ราคาต่ำ-สูง/สูง-ต่ำ) | High | Positive |
| SC-CAT-03 | Category | Filter | กรอง + ล้างตัวกรองทั้งหมด | High | Positive |
| SC-CAT-04 | Category | Pagination | เปลี่ยนหน้า/ก่อนหน้า/ถัดไป/หน้าสุดท้าย | Medium | Boundary |
| SC-CAT-05 | Category | Filter ไม่มีผลลัพธ์ | กรองจนได้ 0 รายการ → empty state | Medium | Negative |
| SC-PDP-01 | Product Detail | แสดงข้อมูลสินค้า | ชื่อ/รหัส/ราคาโปร/ราคาเดิม/ไซซ์/รูป/breadcrumb | High | Positive |
| SC-PDP-02 | Product Detail | เพิ่มลงตะกร้า | กด "เพิ่มลงตะกร้า" → จำนวนตะกร้าเพิ่ม | High | Positive |
| SC-PDP-03 | Product Detail | ซื้อทันที | กด "ซื้อทันที!" → ไป checkout/cart | High | Positive |
| SC-PDP-04 | Product Detail | สินค้าแนะนำ/รีวิว | ลิงก์สินค้าแนะนำ + ดูรีวิวทั้งหมด | Low | Positive |
| SC-PDP-05 | Product Detail | ข้อความริบบิ้น | ระบุข้อความบนพวงหรีด (ตรวจว่ามี/ไม่มี) | High | Validation |
| SC-CART-01 | Cart | ตะกร้าว่าง | แสดง empty state | Medium | Negative |
| SC-CART-02 | Cart | แก้จำนวน/ลบสินค้า | เพิ่ม-ลด-ลบรายการ + ยอดรวมอัปเดต | High | Positive |
| SC-CART-03 | Cart | คงสินค้าเมื่อ refresh | persist ตะกร้าหลังรีเฟรช | Medium | Regression |
| SC-CART-04 | Cart | ไปขั้นชำระเงิน | ปุ่มไป checkout ทำงาน | High | Positive |
| SC-CART-05 | Cart | flow ต่างจังหวัด | ปุ่ม "ต่างจังหวัดกดแอดไลน์" → /line/ | Medium | Positive |
| SC-PROMO-01 | Promotion | ใช้โค้ดถูกต้อง | กรอกโค้ดที่ valid → ส่วนลดถูกหัก | High | Positive |
| SC-PROMO-02 | Promotion | โค้ดผิด/หมดอายุ | error message ชัดเจน | High | Negative |
| SC-PROMO-03 | Promotion | โค้ดว่าง/ช่องว่าง/ตัวพิมพ์ | validation + case sensitivity | Medium | Validation |
| SC-CHK-01 | Checkout | กรอกครบ flow ปกติ | กรอกทุก required → ไปชำระเงิน | High | Positive |
| SC-CHK-02 | Checkout | required ว่าง | เว้นแต่ละ required → error | High | Validation |
| SC-CHK-03 | Checkout | รูปแบบอีเมล | อีเมลผิดรูปแบบถูก reject | High | Validation |
| SC-CHK-04 | Checkout | รูปแบบเบอร์โทร | เบอร์ตัวอักษร/สั้น/ยาวเกิน | High | Validation/Boundary |
| SC-CHK-05 | Checkout | consent policy | ไม่ติ๊กยินยอม → กดชำระไม่ได้ | High | Negative |
| SC-CHK-06 | Checkout | ค่าขนส่ง/ยอดรวม | คำนวณ subtotal+ship+ส่วนลด ถูกต้อง | High | Positive |
| SC-CHK-07 | Checkout | XSS/SQLi ในฟิลด์ข้อความ | กรอก payload → ระบบ sanitize | Medium | Negative/Security |
| SC-CHK-08 | Checkout | ค่าขอบเขตข้อความ | ชื่อ/ศาลา ยาวมาก, อักขระพิเศษ, emoji | Medium | Boundary |
| SC-PAY-01 | Payment | เลือก QR/โอน | แสดงข้อมูลชำระถูกต้อง | High | Positive |
| SC-PAY-02 | Payment | บัตร +3% | ยอดรวมบวกค่าธรรมเนียม 3% ถูกต้อง | High | Positive/Boundary |
| SC-PAY-03 | Payment | ไม่ยืนยันชำระจริง | หยุดก่อน transaction จริง (sandbox) | High | Positive |
| SC-ORD-01 | Order Success | หน้ายืนยันออเดอร์ | แสดงเลขออเดอร์/สรุป/อีเมลยืนยัน | High | Positive |
| SC-TRK-01 | Tracking | ติดตามด้วย Tracking ID | กรอก ID ที่ถูกต้อง → สถานะ | Medium | Positive |
| SC-TRK-02 | Tracking | ติดตามด้วยเลขออเดอร์+เบอร์ | คู่ข้อมูลถูกต้อง → สถานะ | Medium | Positive |
| SC-TRK-03 | Tracking | ข้อมูลผิด/ว่าง | error/empty handling | Medium | Negative |
| SC-AUTH-01 | Auth | สมัครสมาชิกตอน checkout | ติ๊กสมัครสมาชิก → สร้างบัญชี | Medium | Positive |
| SC-AUTH-02 | Auth | หน้า login | เข้าถึง `/login/` (พบ 404) | Medium | Negative |
| SC-ERR-01 | Error | 404 page | เปิด URL ไม่มีจริง → หน้า 404 เหมาะสม | Medium | Negative |
| SC-ERR-02 | Error | Responsive/Mobile | flow สั่งซื้อบนมือถือ | Medium | Regression |
| SC-SRCH-01 | Search | ค้นหาสินค้า | ตรวจว่ามีฟังก์ชัน search (พบว่าไม่มี) | Medium | Negative |

---

## 3) Detailed Test Cases

> Status เริ่มต้น = **Not Run**, Actual Result = **N/A** ทุกเคส (ยังไม่ได้ execute จริง)
> Test Data ที่ใช้ทดสอบ payment ให้ใช้ **sandbox/test เท่านั้น** และ**หยุดก่อนยืนยันชำระจริง**

### 3.1 Home

#### TC-HOME-01
| Field | Detail |
|---|---|
| Module / Feature | Home / Navigation |
| Test Scenario | SC-HOME-01 คลิกเมนูหมวดหมู่ |
| Priority | High |
| Test Type | Positive |
| Preconditions | เปิดหน้า Home สำเร็จ |
| Test Data | เมนู "พวงหรีดดอกไม้สด" |
| Test Steps | 1. เปิด `/` 2. คลิกเมนู dropdown 3. เลือกหมวดย่อย |
| Expected Result | นำทางไปหน้า listing หมวดที่เลือก, URL/breadcrumb ถูกต้อง, สินค้าตรงหมวด |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | เมนูเป็น `href="#"` + JS ต้องตรวจว่าทำงานเมื่อคลิกจริง |

#### TC-HOME-02
| Field | Detail |
|---|---|
| Module / Feature | Home / แบนเนอร์ & ลิงก์ติดต่อ |
| Test Scenario | SC-HOME-01 / SC-HOME-02 |
| Priority | Medium |
| Test Type | Positive |
| Preconditions | หน้า Home โหลดสำเร็จ |
| Test Data | แบนเนอร์ "สินค้าขายดี", ปุ่ม LINE, tel |
| Test Steps | 1. คลิกแบนเนอร์แต่ละอัน 2. คลิก LINE/โทร/FB/IG |
| Expected Result | แบนเนอร์ไปยัง collection ถูกต้อง; LINE/โทรเปิด deep link; โซเชียลเปิดแท็บใหม่ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | No (external deep link) |
| Remark | เช็คเฉพาะ URL ปลายทาง ไม่ต้องเปิดแอปจริง |

### 3.2 Category / Listing + Filter/Sort (เหมาะทำ Parameterized)

#### TC-CAT-01
| Field | Detail |
|---|---|
| Module / Feature | Category / แสดงสินค้า |
| Test Scenario | SC-CAT-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | มีสินค้าในหมวด |
| Test Data | `/ร้านพวงหรีด/พวงหรีดดอกไม้สด/` |
| Test Steps | 1. เปิดหน้าหมวด 2. ตรวจการ์ดสินค้า |
| Expected Result | แสดงรูป/ชื่อ/รหัส/ไซซ์/ราคาโปร+ราคาเดิม/badge ครบ, จำนวนรวมถูกต้อง |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Smoke |

#### TC-CAT-02 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Category / Sort |
| Test Scenario | SC-CAT-02 |
| Priority | High |
| Test Type | Positive / Data-driven |
| Preconditions | อยู่หน้า listing |
| Test Data | [แนะนำ, มาใหม่, ราคาต่ำ-สูง, ราคาสูง-ต่ำ] |
| Test Steps | 1. เลือก sort แต่ละแบบ 2. อ่านลำดับราคา/รายการ |
| Expected Result | "ราคาต่ำ-สูง" = ราคาเรียงน้อย→มาก; "สูง-ต่ำ" = ตรงข้าม; แบบอื่นเป็นไปตามเกณฑ์; URL/state คงค่า sort |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | จัดเป็น data-driven 4 ชุด; assert ลำดับราคาด้วย parse ตัวเลข |

#### TC-CAT-03
| Field | Detail |
|---|---|
| Module / Feature | Category / Filter |
| Test Scenario | SC-CAT-03 |
| Priority | High |
| Test Type | Positive |
| Preconditions | อยู่หน้า listing |
| Test Data | ตัวกรองช่วงราคา/ประเภท |
| Test Steps | 1. เลือกตัวกรอง 2. ตรวจผล 3. กด "ล้างตัวกรองทั้งหมด" |
| Expected Result | ผลลัพธ์ตรงเงื่อนไข; ล้างตัวกรองคืนรายการเต็ม; ตัวนับจำนวนอัปเดต |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

#### TC-CAT-04
| Field | Detail |
|---|---|
| Module / Feature | Category / Pagination |
| Test Scenario | SC-CAT-04 |
| Priority | Medium |
| Test Type | Boundary |
| Preconditions | หมวดมีหลายหน้า (~12) |
| Test Data | หน้า 1, 2, หน้าสุดท้าย |
| Test Steps | 1. คลิก "ถัดไป"/เลขหน้า 2. ไปหน้าสุดท้าย 3. คลิก "ก่อนหน้า" |
| Expected Result | เปลี่ยนหน้าเนื้อหาถูกต้อง; ปุ่ม "ก่อนหน้า" disabled ที่หน้า 1, "ถัดไป" disabled ที่หน้าสุดท้าย; ไม่มีสินค้าซ้ำข้ามหน้า |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Boundary หน้าแรก/สุดท้าย |

#### TC-CAT-05
| Field | Detail |
|---|---|
| Module / Feature | Category / Empty result |
| Test Scenario | SC-CAT-05 |
| Priority | Medium |
| Test Type | Negative |
| Preconditions | — |
| Test Data | ตัวกรองที่ไม่มีสินค้าตรง |
| Test Steps | 1. ตั้งตัวกรองเข้มจนเหลือ 0 รายการ |
| Expected Result | แสดง empty state ที่สื่อความหมาย + ทางเลือกล้างตัวกรอง ไม่แสดงหน้า error/หน้าว่างเปล่า |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

### 3.3 Product Detail

#### TC-PDP-01
| Field | Detail |
|---|---|
| Module / Feature | PDP / แสดงข้อมูล |
| Test Scenario | SC-PDP-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | สินค้ามีอยู่ |
| Test Data | `/พวงหรีด/h015-wnw-บุหลันพลอยสีม่วง/` |
| Test Steps | 1. เปิด PDP 2. ตรวจชื่อ/รหัส/ราคา/ไซซ์/คำอธิบาย/รูป/breadcrumb |
| Expected Result | ข้อมูลตรงกับ listing; ราคาโปร ฿1,599 + ราคาเดิม ฿1,899; SIZE M (60×80 ซม.); breadcrumb ถูกต้อง |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจราคาตรงกับ listing (consistency) |

#### TC-PDP-02
| Field | Detail |
|---|---|
| Module / Feature | PDP / Add to Cart |
| Test Scenario | SC-PDP-02 |
| Priority | High |
| Test Type | Positive |
| Preconditions | ตะกร้าว่าง |
| Test Data | สินค้า H015 |
| Test Steps | 1. กด "เพิ่มลงตะกร้า" 2. ดูตัวนับตะกร้า 3. เปิด /cart/ |
| Expected Result | ตัวนับตะกร้า +1; มีสินค้าถูกต้อง+ราคาถูกต้องในตะกร้า; มี toast/feedback |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Critical path |

#### TC-PDP-03
| Field | Detail |
|---|---|
| Module / Feature | PDP / Buy Now |
| Test Scenario | SC-PDP-03 |
| Priority | High |
| Test Type | Positive |
| Preconditions | — |
| Test Data | สินค้า H015 |
| Test Steps | 1. กด "ซื้อทันที! เพื่อไม่พลาดรอบจัดส่ง" |
| Expected Result | นำไป cart หรือ checkout พร้อมสินค้านี้ในรายการ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจว่าต่างจาก Add to Cart อย่างไร |

#### TC-PDP-04
| Field | Detail |
|---|---|
| Module / Feature | PDP / ข้อความริบบิ้น (ป้ายคำไว้อาลัย) |
| Test Scenario | SC-PDP-05 |
| Priority | High |
| Test Type | Validation |
| Preconditions | อยู่ PDP/Cart/Checkout |
| Test Data | ข้อความ "ด้วยรักและอาลัย / บริษัท ABC" |
| Test Steps | 1. หาช่องกรอกข้อความบนพวงหรีดในทุกขั้นตอน |
| Expected Result | ต้องมีช่องระบุข้อความริบบิ้น (จำเป็นมากสำหรับพวงหรีด) และบันทึกไปกับออเดอร์ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | No (exploratory ก่อน) |
| Remark | **ปัจจุบันไม่พบช่องนี้ → ดู DEF-003** |

### 3.4 Cart

#### TC-CART-01
| Field | Detail |
|---|---|
| Module / Feature | Cart / Empty state |
| Test Scenario | SC-CART-01 |
| Priority | Medium |
| Test Type | Negative |
| Preconditions | ตะกร้าว่าง |
| Test Data | — |
| Test Steps | 1. เปิด `/cart/` ตอนไม่มีสินค้า |
| Expected Result | แสดง "- คุณยังไม่มีสินค้าในตะกร้า -", ยอดรวม ฿0, ปุ่มไปชำระเงิน disabled/ซ่อน |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

#### TC-CART-02
| Field | Detail |
|---|---|
| Module / Feature | Cart / แก้ไขรายการ |
| Test Scenario | SC-CART-02 |
| Priority | High |
| Test Type | Positive / Boundary |
| Preconditions | มี ≥1 สินค้าในตะกร้า |
| Test Data | จำนวน 1→2, ลด→1, ลบ |
| Test Steps | 1. เพิ่มจำนวน 2. ลดจำนวน 3. ลดถึง 0/ลบ 4. ดูยอดรวม |
| Expected Result | ยอดรวมคำนวณตามจำนวน×ราคาถูกต้อง; ลบแล้วรายการหาย; ป้องกันจำนวนติดลบ/0 |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจว่า PDP ไม่มี qty แต่ cart แก้ qty ได้หรือไม่ |

#### TC-CART-03
| Field | Detail |
|---|---|
| Module / Feature | Cart / Persistence |
| Test Scenario | SC-CART-03 |
| Priority | Medium |
| Test Type | Regression |
| Preconditions | มีสินค้าในตะกร้า |
| Test Data | — |
| Test Steps | 1. เพิ่มสินค้า 2. Refresh/ปิดเปิดแท็บใหม่ |
| Expected Result | สินค้าในตะกร้ายังอยู่ (cookie/localStorage) |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

#### TC-CART-04
| Field | Detail |
|---|---|
| Module / Feature | Cart / ไป Checkout |
| Test Scenario | SC-CART-04 |
| Priority | High |
| Test Type | Positive |
| Preconditions | มีสินค้าในตะกร้า (พื้นที่ กทม.) |
| Test Data | — |
| Test Steps | 1. กดปุ่มไปชำระเงิน |
| Expected Result | ไป `/checkout/` พร้อมสรุปยอด |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Critical path |

#### TC-CART-05
| Field | Detail |
|---|---|
| Module / Feature | Cart / Flow ต่างจังหวัด |
| Test Scenario | SC-CART-05 |
| Priority | Medium |
| Test Type | Positive |
| Preconditions | มีสินค้าในตะกร้า |
| Test Data | — |
| Test Steps | 1. กด "สั่งสินค้า พื้นที่ต่างจังหวัดกดแอดไลน์" |
| Expected Result | นำไป `/line/` (LINE OA) |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | No (external) |
| Remark | ตรวจปลายทาง URL เท่านั้น |

### 3.5 Promotion / Discount

#### TC-PROMO-01
| Field | Detail |
|---|---|
| Module / Feature | Promotion / ใช้โค้ดถูกต้อง |
| Test Scenario | SC-PROMO-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | มีโค้ด valid + สินค้าในตะกร้า, อยู่ checkout |
| Test Data | โค้ดส่วนลดที่ใช้ได้ (จากทีม) |
| Test Steps | 1. กรอกรหัสส่วนลด 2. กด Apply 3. ดูยอด |
| Expected Result | ยอดส่วนลดถูกหักถูกต้อง, แสดงบรรทัดส่วนลด, grand total ลดลง |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ต้องขอ test code จากทีม |

#### TC-PROMO-02 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Promotion / โค้ดไม่ถูกต้อง |
| Test Scenario | SC-PROMO-02 |
| Priority | High |
| Test Type | Negative / Data-driven |
| Preconditions | อยู่ checkout |
| Test Data | [โค้ดผิด, โค้ดหมดอายุ, โค้ดยอดขั้นต่ำไม่ถึง, โค้ดใช้ไปแล้ว] |
| Test Steps | 1. กรอกโค้ดแต่ละชุด 2. Apply |
| Expected Result | แสดง error ที่ถูกต้องตามกรณี, ไม่หักส่วนลด, ยอดไม่เปลี่ยน |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | data-driven |

#### TC-PROMO-03
| Field | Detail |
|---|---|
| Module / Feature | Promotion / Validation |
| Test Scenario | SC-PROMO-03 |
| Priority | Medium |
| Test Type | Validation |
| Preconditions | อยู่ checkout |
| Test Data | ค่าว่าง, เว้นวรรค, ตัวพิมพ์เล็ก/ใหญ่, อักขระพิเศษ |
| Test Steps | 1. กรอกค่าขอบเขต 2. Apply |
| Expected Result | trim ช่องว่าง, จัดการ case ตามสเปก, ไม่ crash, error สื่อความหมาย |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจ case sensitivity |

### 3.6 Checkout (Validation เป็นหัวใจ)

#### TC-CHK-01
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Happy path |
| Test Scenario | SC-CHK-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | มีสินค้าในตะกร้า |
| Test Data | ศาลา="วัดเทพศิรินทร์ ศาลา 5", ผู้เสียชีวิต="นายทดสอบ ระบบ", โทรติดต่อ="0812345678", เวลา=เลือก 1 ช่วง, ผู้สั่ง="นางสาวคิวเอ เทส", อีเมล="qa@test.com", โทร="0898765432", ติ๊กยินยอม policy |
| Test Steps | 1. กรอกครบทุก required 2. เลือกวิธีชำระ 3. กด "ชำระเงิน" |
| Expected Result | ผ่าน validation → ไปหน้าชำระเงิน/สรุปออเดอร์ (หยุดก่อนชำระจริง) |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Critical path |

#### TC-CHK-02 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Required field ว่าง |
| Test Scenario | SC-CHK-02 |
| Priority | High |
| Test Type | Validation / Data-driven |
| Preconditions | กรอกฟอร์มเกือบครบ |
| Test Data | เว้นทีละช่อง: [ศาลา, ผู้เสียชีวิต, โทรติดต่อ, เวลาจัดส่ง, ชื่อผู้สั่ง, อีเมล, โทรผู้สั่ง] |
| Test Steps | 1. เว้นช่องที่ระบุ 2. กด "ชำระเงิน" |
| Expected Result | บล็อกการ submit, แสดง error ใต้ช่องที่ขาด, โฟกัสไปช่องแรกที่ผิด |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | 7 ชุดข้อมูล |

#### TC-CHK-03 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Email validation |
| Test Scenario | SC-CHK-03 |
| Priority | High |
| Test Type | Validation / Data-driven |
| Preconditions | — |
| Test Data | invalid: ["abc", "abc@", "abc@x", "a b@x.com", "@x.com", "abc@@x.com"], valid: ["a@b.com", "a.b+c@sub.domain.co.th"] |
| Test Steps | 1. กรอกอีเมลแต่ละค่า 2. submit/blur |
| Expected Result | invalid ถูก reject พร้อม error; valid ผ่าน |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

#### TC-CHK-04 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Phone validation |
| Test Scenario | SC-CHK-04 |
| Priority | High |
| Test Type | Validation / Boundary |
| Preconditions | — |
| Test Data | ["0812345678"(valid), "12345"(สั้น), "08123456789012"(ยาว), "08a2345678"(ตัวอักษร), "+66812345678", "081-234-5678", " "(ว่าง)] |
| Test Steps | 1. กรอกเบอร์แต่ละค่า 2. submit |
| Expected Result | รับเฉพาะรูปแบบที่ถูก, reject ที่ผิด + error ชัด, กำหนดความยาว 9–10 หลัก |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจ boundary ความยาว |

#### TC-CHK-05
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Consent บังคับ |
| Test Scenario | SC-CHK-05 |
| Priority | High |
| Test Type | Negative |
| Preconditions | กรอกครบ แต่ไม่ติ๊กยินยอม policy |
| Test Data | — |
| Test Steps | 1. ไม่ติ๊ก "ยินยอมนโยบายความเป็นส่วนตัว" 2. กดชำระเงิน |
| Expected Result | บล็อก submit + แจ้งให้ยอมรับนโยบาย |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจ PDPA compliance |

#### TC-CHK-06
| Field | Detail |
|---|---|
| Module / Feature | Checkout / คำนวณยอดรวม |
| Test Scenario | SC-CHK-06 |
| Priority | High |
| Test Type | Positive / Boundary |
| Preconditions | มีสินค้าหลายชิ้นในตะกร้า |
| Test Data | 2–3 สินค้าราคาต่างกัน + โค้ดส่วนลด |
| Test Steps | 1. ดู subtotal 2. ดูค่าขนส่ง 3. ใส่ส่วนลด 4. ดู grand total |
| Expected Result | grand total = subtotal − ส่วนลด + ค่าขนส่ง (กทม.=ฟรี); ปัดเศษถูกต้อง |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจร่วมกับ TC-PAY-02 (+3% บัตร) |

#### TC-CHK-07
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Security input |
| Test Scenario | SC-CHK-07 |
| Priority | Medium |
| Test Type | Negative / Security |
| Preconditions | — |
| Test Data | `<script>alert(1)</script>`, `' OR '1'='1`, `"><img src=x onerror=alert(1)>` |
| Test Steps | 1. กรอก payload ในช่องข้อความ (ศาลา/ชื่อ) 2. submit/แสดงผล |
| Expected Result | sanitize/escape, ไม่เกิด script execution, ไม่ 500 error |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | basic security smoke |

#### TC-CHK-08 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Checkout / Boundary ข้อความ |
| Test Scenario | SC-CHK-08 |
| Priority | Medium |
| Test Type | Boundary |
| Preconditions | — |
| Test Data | ["A"×1, "ก"×255, "ก"×1000, "😊ไทยEng123", "   เว้นหน้า-หลัง   "] |
| Test Steps | 1. กรอกค่าขอบเขตในศาลา/ชื่อ 2. submit |
| Expected Result | มี maxlength เหมาะสม, trim ช่องว่าง, รองรับไทย/emoji หรือ reject อย่างสุภาพ, ไม่ตัดข้อมูลเงียบ ๆ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

### 3.7 Payment

#### TC-PAY-01
| Field | Detail |
|---|---|
| Module / Feature | Payment / QR & โอน |
| Test Scenario | SC-PAY-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | ผ่าน checkout |
| Test Data | เลือก "QR PromptPay / โอนธนาคาร" |
| Test Steps | 1. เลือกวิธี QR/โอน 2. กดต่อ |
| Expected Result | แสดง QR/เลขบัญชี (KBank/BBL/KTB) ถูกต้อง, ยอดตรง, **ไม่มีการตัดเงินอัตโนมัติ** |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Partial |
| Remark | หยุดก่อนอัปสลิป/ยืนยันจริง |

#### TC-PAY-02
| Field | Detail |
|---|---|
| Module / Feature | Payment / บัตร +3% |
| Test Scenario | SC-PAY-02 |
| Priority | High |
| Test Type | Boundary |
| Preconditions | ผ่าน checkout, ยอดทราบค่า |
| Test Data | ยอด 1,599 → คาด +3% = 1,646.97 |
| Test Steps | 1. เลือก "บัตรเครดิต/เดบิต" 2. ดูยอดที่อัปเดต |
| Expected Result | ยอดบวกค่าธรรมเนียม 3% ถูกต้องและแสดงชัดเจนก่อนชำระ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | **ห้ามกรอกเลขบัตรจริง** ใช้ sandbox; หยุดก่อนยืนยัน |

#### TC-PAY-03
| Field | Detail |
|---|---|
| Module / Feature | Payment / ไม่ทำ transaction จริง |
| Test Scenario | SC-PAY-03 |
| Priority | High |
| Test Type | Positive (safety gate) |
| Preconditions | อยู่หน้าชำระเงิน |
| Test Data | — |
| Test Steps | 1. หยุดก่อนยืนยันชำระเงินจริง |
| Expected Result | ไม่มี transaction จริงเกิดขึ้นใน env ทดสอบ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | No |
| Remark | กฎความปลอดภัยตามโจทย์ |

### 3.8 Order Success & Tracking

#### TC-ORD-01
| Field | Detail |
|---|---|
| Module / Feature | Order / หน้ายืนยัน |
| Test Scenario | SC-ORD-01 |
| Priority | High |
| Test Type | Positive |
| Preconditions | (ต้องมี sandbox payment) สั่งซื้อสำเร็จ |
| Test Data | — |
| Test Steps | 1. ทำออเดอร์จนสำเร็จใน sandbox 2. ดูหน้า success |
| Expected Result | แสดงเลขออเดอร์/สรุปรายการ/Tracking ID + ส่งอีเมลยืนยัน |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Partial |
| Remark | ขึ้นกับการมี sandbox; มิฉะนั้นเป็น manual |

#### TC-TRK-01 (Parameterized)
| Field | Detail |
|---|---|
| Module / Feature | Tracking / ติดตามสถานะ |
| Test Scenario | SC-TRK-01/02/03 |
| Priority | Medium |
| Test Type | Positive / Negative |
| Preconditions | มี Tracking ID หรือเลขออเดอร์จริง |
| Test Data | [valid TrackingID, valid เลขออเดอร์+เบอร์, เลขผิด, ช่องว่าง, เลขถูก+เบอร์ผิด] |
| Test Steps | 1. เปิด `/ติดตามสถานะ/` 2. กรอกแต่ละชุด 3. ค้นหา |
| Expected Result | valid → แสดงสถานะ; invalid/ว่าง → error ที่ชัดเจน ไม่ leak ข้อมูลผู้อื่น |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | ตรวจว่าเป็น self-service จริง หรือนำไป LINE (ดู Defect) |

### 3.9 Auth / Search / Error

#### TC-AUTH-01
| Field | Detail |
|---|---|
| Module / Feature | Auth / สมัครสมาชิกตอน checkout |
| Test Scenario | SC-AUTH-01 |
| Priority | Medium |
| Test Type | Positive |
| Preconditions | อยู่ checkout |
| Test Data | ติ๊ก "สมัครสมาชิก..." |
| Test Steps | 1. ติ๊ก checkbox สมัครสมาชิก 2. ทำออเดอร์ |
| Expected Result | สร้างบัญชีจากข้อมูลผู้สั่ง (อาจตั้งรหัส/ส่งอีเมล), login ภายหลังได้ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Partial |
| Remark | ตรวจว่าผูกกับ `/login/` ที่ปัจจุบัน 404 อย่างไร |

#### TC-SRCH-01
| Field | Detail |
|---|---|
| Module / Feature | Search |
| Test Scenario | SC-SRCH-01 |
| Priority | Medium |
| Test Type | Negative / Exploratory |
| Preconditions | — |
| Test Data | คำค้น "ดอกไม้สด" |
| Test Steps | 1. หาช่อง search บนเว็บ 2. ลอง `/search/?q=` |
| Expected Result | ควรมีฟังก์ชันค้นหาสินค้า |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | No |
| Remark | **ปัจจุบันไม่พบ search → DEF-001** |

#### TC-ERR-01
| Field | Detail |
|---|---|
| Module / Feature | Error / 404 |
| Test Scenario | SC-ERR-01 |
| Priority | Medium |
| Test Type | Negative |
| Preconditions | — |
| Test Data | `/this-page-does-not-exist/` |
| Test Steps | 1. เปิด URL ที่ไม่มีจริง |
| Expected Result | แสดงหน้า 404 ที่ออกแบบไว้ + ลิงก์กลับหน้าหลัก/หมวด ไม่ใช่หน้าขาว/error ดิบ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | — |

#### TC-ERR-02
| Field | Detail |
|---|---|
| Module / Feature | Responsive / Mobile |
| Test Scenario | SC-ERR-02 |
| Priority | Medium |
| Test Type | Regression |
| Preconditions | — |
| Test Data | viewport 375×812 (มือถือ) |
| Test Steps | 1. ทำ flow สั่งซื้อบนมือถือ |
| Expected Result | layout ไม่แตก, ปุ่มกดได้, ฟอร์มกรอกได้, เมนู hamburger ใช้งานได้ |
| Actual Result | N/A |
| Status | Not Run |
| Automation Candidate | Yes |
| Remark | Playwright หลาย viewport |

---

## 4) Defect Report

> ⚠️ ทุกรายการเป็น **"พบจากการวิเคราะห์โครงสร้างหน้าเว็บ (static fetch)"** ยังต้องยืนยันด้วยการ execute แบบ interactive อีกครั้ง (เพราะไม่มี Chrome เชื่อมต่อในรอบนี้) จึงตั้ง Status = `Open – Needs Verification`

### DEF-001
| Field | Detail |
|---|---|
| Title | ไม่พบฟังก์ชันค้นหาสินค้า (Search) บนเว็บไซต์ |
| Module | Global / Search |
| Severity | Medium |
| Priority | Medium |
| Preconditions | เปิดเว็บไซต์ปกติ |
| Steps to Reproduce | 1. หาช่อง search บนทุกหน้า 2. เปิด `/search/?q=หรีด` |
| Expected Result | มีช่องค้นหาสินค้า / มีหน้า search results |
| Actual Result | ไม่พบช่อง search; `/search/?q=` → **HTTP 404** |
| Evidence / Screenshot Reference | WebFetch homepage (ไม่มี search box) + `/search/` = 404 |
| Environment | DEV `wnw2025-frontend.dev-app-bit.com`, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | เว็บ e-commerce สินค้า 1,000+ ชิ้น ไม่มี search = ลด conversion มาก (อาจเป็น missing feature โดยตั้งใจ — ยืนยันกับ PO) |

### DEF-002
| Field | Detail |
|---|---|
| Title | หน้า `/login/` ตอบ 404 (ไม่มีหน้า login/register มาตรฐาน) |
| Module | Auth |
| Severity | Medium |
| Priority | Medium |
| Preconditions | — |
| Steps to Reproduce | 1. เปิด `/login/` |
| Expected Result | แสดงหน้าเข้าสู่ระบบ/สมัครสมาชิก |
| Actual Result | **HTTP 404** ทั้งที่ checkout มี checkbox "สมัครสมาชิก" |
| Evidence / Screenshot Reference | `/login/` = 404 |
| Environment | DEV, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | ถ้าสมัครสมาชิกตอน checkout แล้วไม่มีทาง login กลับ = ฟีเจอร์ค้าง; ยืนยัน path login ที่ถูกต้อง (อาจเป็น modal/social) |

### DEF-003
| Field | Detail |
|---|---|
| Title | ไม่พบช่องกรอก "ข้อความริบบิ้น/ป้ายคำไว้อาลัย" ในทั้ง PDP และ Checkout |
| Module | Product Detail / Checkout |
| Severity | High |
| Priority | High |
| Preconditions | สั่งพวงหรีด 1 ชิ้น |
| Steps to Reproduce | 1. เปิด PDP 2. เพิ่มลงตะกร้า 3. ไป checkout 4. หาช่องระบุข้อความบนพวงหรีด |
| Expected Result | ต้องมีช่องระบุข้อความบนริบบิ้น (เป็นข้อมูลจำเป็นของพวงหรีด) |
| Actual Result | ไม่พบช่องนี้ในทุกขั้นตอนที่ตรวจสอบ |
| Evidence / Screenshot Reference | WebFetch PDP H015 + Checkout (ไม่มี field ริบบิ้น) |
| Environment | DEV, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | ถ้าต้องแจ้งข้อความผ่าน LINE หลังสั่ง = UX แตก/เสี่ยงข้อมูลตกหล่น; กระทบ core business ของพวงหรีด |

### DEF-004
| Field | Detail |
|---|---|
| Title | Checkout มีเฉพาะ "เลือกเวลาจัดส่ง" แต่ไม่มีตัวเลือก "วันที่จัดส่ง" |
| Module | Checkout / Delivery |
| Severity | Medium |
| Priority | Medium |
| Preconditions | อยู่หน้า checkout |
| Steps to Reproduce | 1. ดูส่วนข้อมูลจัดส่ง |
| Expected Result | เลือกได้ทั้งวันและเวลาจัดส่ง (งานศพมีวันสวด/ฌาปนกิจชัดเจน) |
| Actual Result | พบเพียง dropdown "เลือกเวลาจัดส่ง" ไม่พบ date picker |
| Evidence / Screenshot Reference | WebFetch `/checkout/` |
| Environment | DEV, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | ถ้า default เป็น "วันนี้/รอบถัดไป" ต้องสื่อสารชัดเจน มิฉะนั้นเสี่ยงส่งผิดวัน |

### DEF-005
| Field | Detail |
|---|---|
| Title | เมนูหมวดหลักใช้ `href="#"` (พึ่งพา JS) — เสี่ยงลิงก์ค้าง/SEO/เปิดแท็บใหม่ไม่ได้ |
| Module | Home / Navigation |
| Severity | Low |
| Priority | Low |
| Preconditions | หน้า Home |
| Steps to Reproduce | 1. ดู href ของเมนู 7 หมวด |
| Expected Result | เมนูควรชี้ URL จริง (รองรับ middle-click/SEO/crawler) |
| Actual Result | ทุกเมนูหลัก href=`#` (เปิด dropdown ด้วย JS) |
| Evidence / Screenshot Reference | WebFetch homepage link list |
| Environment | DEV, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | ตรวจว่าหมวดย่อยใน dropdown เป็น URL จริงหรือไม่ |

### DEF-006
| Field | Detail |
|---|---|
| Title | โค้ดส่วนลดไม่อยู่ในหน้า Cart (แจ้งเพียง "อยู่ขั้นตอนถัดไป") |
| Module | Cart / Promotion |
| Severity | Low |
| Priority | Low |
| Preconditions | มีสินค้าในตะกร้า |
| Steps to Reproduce | 1. เปิด `/cart/` |
| Expected Result | ผู้ใช้เห็น/ทดลองใส่โค้ดเพื่อประเมินยอดได้ตั้งแต่ตะกร้า |
| Actual Result | หน้า cart แสดงข้อความ "*รหัสส่วนลด อยู่ขั้นตอนถัดไป" ไม่มีช่องกรอก |
| Evidence / Screenshot Reference | WebFetch `/cart/` |
| Environment | DEV, 2026-06-25 |
| Status | Open – Needs Verification |
| Remark | UX ปกติ e-commerce แสดงช่องโค้ดที่ cart; เป็น minor UX |

---

## 5) Playwright Automation Recommendation

### 5.1 Smoke Test (ทุก deploy / รันเร็ว ~5 นาที)
| TC | เหตุผล |
|---|---|
| TC-HOME-01, TC-CAT-01, TC-PDP-01, TC-PDP-02, TC-CART-04, TC-CHK-01 | เส้นทางหลักให้ระบบ "ยังขายได้" — เสถียร, value สูง, คุ้มค่า automate ก่อนอื่น |

### 5.2 Critical Path Test (ทุก release)
| TC | เหตุผล |
|---|---|
| TC-PDP-02/03 → TC-CART-02 → TC-CHK-01 → TC-PAY-01/02 (หยุดก่อนยืนยัน) → TC-ORD-01 | ครอบคลุม end-to-end การสั่งซื้อ; เป็นรายได้ของธุรกิจ ต้องไม่พังเด็ดขาด |

### 5.3 Regression Test (nightly / ก่อน release ใหญ่)
| TC | เหตุผล |
|---|---|
| TC-CAT-03/04/05, TC-CART-01/03/05, TC-CHK-05/06, TC-TRK-01, TC-ERR-01/02 | ครอบคลุมพฤติกรรมรอง + responsive + empty/error states ที่เปลี่ยนบ่อยจาก refactor |

### 5.4 Data-driven Test (Parameterized — Playwright fixtures/`test.each`)
| TC | ชุดข้อมูล | เหตุผล |
|---|---|---|
| TC-CAT-02 | 4 sort options | logic เดียว ข้อมูลต่าง → parameterize ลดโค้ดซ้ำ |
| TC-CHK-02 | 7 required fields | วน assert ทีละช่องว่าง |
| TC-CHK-03 | email valid/invalid | boundary รูปแบบจำนวนมาก |
| TC-CHK-04 | phone valid/invalid/boundary | เหมาะ data table |
| TC-PROMO-02/03 | โค้ดผิดหลายแบบ | ผลลัพธ์ต่างตาม input |
| TC-CHK-08 | boundary ข้อความ | reuse ฟอร์มเดียว |

### 5.5 Not Recommended for Automation (ทำ Manual)
| รายการ | เหตุผล |
|---|---|
| TC-HOME-02 (LINE/โทร/โซเชียล) | external deep link/แอปภายนอก — เปราะและไม่ใช่ขอบเขตเว็บ (assert ปลายทาง URL ได้แค่บางส่วน) |
| TC-CART-05 (redirect LINE OA) | ปลายทางนอกระบบ |
| TC-PAY-03 / การยืนยันชำระจริง | ห้ามทำ transaction จริง; ต้องมี payment sandbox ก่อนถึงจะ automate ปลอดภัย |
| Defect verification (DEF-001..006) | exploratory — ใช้คนตัดสินใจกับ PO ก่อน |
| Visual/อารมณ์ดีไซน์ (โทนสี ความเหมาะสมงานศพ) | ตัดสินด้วยมนุษย์; ใช้ visual snapshot ช่วยได้แต่ไม่ทดแทน |

### 5.6 แนวทาง implement (สั้น ๆ)
- ใช้ **Page Object Model** แยกตาม module (HomePage, ListingPage, ProductPage, CartPage, CheckoutPage, TrackingPage)
- เพิ่ม **`data-testid`** ให้ทีม dev (ฟิลด์ checkout/ปุ่ม add-to-cart/ตัวนับตะกร้า) — selector ปัจจุบันต้องพึ่ง Thai text เปราะต่อการเปลี่ยนคำ
- แยก **test data** เป็น fixtures (โค้ดส่วนลด, ข้อมูลผู้สั่ง) + env config
- **Mock/intercept** API payment เพื่อทดสอบ flow ถึงปลายทางโดยไม่ตัดเงินจริง (`page.route`)
- รัน **cross-browser + mobile viewport** (chromium/webkit + 375px)

---

## ภาคผนวก — สิ่งที่ควรดำเนินการต่อ

1. **Execute จริงแบบ interactive** — เชื่อมต่อ Chrome extension เพื่อคลิก/กรอกฟอร์มจริง ยืนยัน DEF-001..006 และเติม Actual Result/Status
2. **ขอ test data จริง** — โค้ดส่วนลด test, payment sandbox, Tracking ID ตัวอย่าง (จากทีม dev) สำหรับ TC-PROMO-01, TC-PAY, TC-ORD, TC-TRK
3. **สร้างโครง Playwright project** — POM + spec ของ Smoke/Critical Path
