# คำขอ Test Data: คูปอง / โปรโมชั่น (Coupon) — ขอจาก Dev

> เอกสารนี้ใช้ขอข้อมูลจากทีม Dev เพื่อปลดล็อกการ automate เคสคูปองทั้งหมด (กลุ่ม **TC-PROMO-***)
> ระบบ: หรีด ณ วัด (Wreath Na Wat) — Checkout / Order Flow
> Environment: **staging** (`wnw2025-frontend.dev-app-bit.com`)
> อ้างอิง: `resources/variables/test_data/wnw-checkout-orderflow.testdata.json` (section `coupons`, `users`)
> สถานะปัจจุบัน: เคสคูปอง **8 เคสถูก BLOCKED** รอข้อมูลด้านล่าง

---

## 0. ⚠️ Prerequisite สำคัญที่สุด — `web_user_token` (บล็อกทุกเคสคูปอง)

คูปอง**ทุกตัวต้อง login** ก่อนถึงจะใช้ได้ (`validate_coupon` เช็ค token) ตอนนี้เรามี user แต่**ยังขาด token**:

| Field | ค่าปัจจุบัน | ต้องการจาก Dev |
|---|---|---|
| email | `inoobeam@hotmail.com` | (มีแล้ว) |
| password | `123456789` | (มีแล้ว) |
| **`web_user_token`** | `<<ask-dev>>` | ⬅️ **ขอค่า token จริงของ user นี้** |

> ถ้าไม่มี token นี้ → เคส TC-PROMO-01-R / 02-R / 05 / 06 / 07 / 10 รันไม่ได้เลย

---

## 1. รายการคูปองที่ต้องการ (7 แบบ)

ช่อง "ต้องการจาก Dev" = ค่าที่ขอให้กรอก/สร้างให้

### 1.1 คูปองใช้ได้ปกติ (valid) — `TD-07`
- **ใช้กับ:** TC-PROMO-01-R (ใส่คูปองถูกต้อง → หักส่วนลด), TC-PROMO-03-R (พิมพ์เล็ก/ว่าง), TC-PROMO-04 (guest ใส่ → ต้อง login ก่อน)
- **เงื่อนไข:** ยอดตะกร้าต้องอยู่ในช่วง min/max ของคูปอง และ **loginUser ยังไม่เคยใช้**

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสคูปองที่ใช้ได้จริงบน staging |
| ช่วงยอดที่ใช้ได้ (min–max) | ⬅️ บอกช่วงยอด เพื่อ QA จัดตะกร้าให้เข้าเงื่อนไข |
| ประเภทส่วนลด + ค่าที่คาดหวัง | ⬅️ (amount กี่บาท / percent กี่ %) เพื่อ assert ยอดหัก |

### 1.2 คูปองหมดอายุ (expired) — `TD-08`
- **ใช้กับ:** TC-PROMO-02-R (error "ไม่พบ/หมดอายุ")
- หมายเหตุ: เคส "ไม่มีจริง" เราใช้ `INVALIDXXXX` เองได้แล้ว — ขอแค่ตัว **หมดอายุ**

| Field | ต้องการจาก Dev |
|---|---|
| `codeExpired` | ⬅️ รหัสคูปองที่**หมดอายุแล้ว**จริงบน staging |

### 1.3 คูปองที่ user ใช้ไปแล้ว (used) — `TD-09`
- **ใช้กับ:** TC-PROMO-07 (ใช้ซ้ำ → "ท่านได้ใช้รหัสส่วนลด ... ไปแล้ว")
- **เงื่อนไข:** ต้องมี record ใน `UserCoupon` ว่า **loginUser ใช้ code นี้ไปแล้ว**

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสที่ loginUser มี record การใช้แล้ว (หรือช่วยสร้าง record ให้) |

### 1.4 คูปองมีช่วงยอด min/max (withMinMax) — `TD-10`
- **ใช้กับ:** TC-PROMO-05 (ยอด < min → WM21), TC-PROMO-06 (boundary strict)
- **เงื่อนไข:** กฎเป็น **strict** (`> min && < max`) → ยอด = min พอดี หรือ = max พอดี ต้อง **ใช้ไม่ได้**

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสคูปองที่มีกำหนด min/max |
| `discountMin` | ⬅️ ยอดขั้นต่ำ (บาท) |
| `discountMax` | ⬅️ ยอดสูงสุด (บาท) |

### 1.5 คูปองหักเป็นจำนวนเงิน (amount type) — `TD-11`
- **ใช้กับ:** TC-PROMO-09 (amount vs percent)
- **เงื่อนไข:** tag `discount = amount` (หักบาทคงที่)

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสคูปองแบบหักบาทคงที่ |
| `expectedDiscount` | ⬅️ จำนวนเงินที่หัก (บาท) |

### 1.6 คูปองหักเป็นเปอร์เซ็นต์ (percent type) — `TD-12`
- **ใช้กับ:** TC-PROMO-09
- **เงื่อนไข:** tag `discount = percent`

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสคูปองแบบหัก % |
| `percent` | ⬅️ เปอร์เซ็นต์ที่หัก (เช่น 10 = 10%) |

### 1.7 คูปองเฉพาะแคมเปญ (campaign) — `TD-13`
- **ใช้กับ:** TC-PROMO-09, TC-PROMO-10 (re-validate ตอนกดสั่ง)
- **เงื่อนไข:** tag `discount_campaign` — ใช้ได้เฉพาะสินค้าที่ tag ตรงกัน

| Field | ต้องการจาก Dev |
|---|---|
| `code` | ⬅️ รหัสคูปองแคมเปญ |
| `applicableProductSlug` | ⬅️ slug สินค้าที่คูปองนี้ใช้ได้ (tag ตรง) |

---

## 2. หมายเหตุเชิงเทคนิค (เพื่อให้ data ใช้ได้จริง)

1. **คูปองมี state ผูกกับ user** — ตัว `valid` (1.1) ต้องเป็นคูปองที่ `loginUser` **ยังไม่เคยใช้**, ส่วน `used` (1.3) ต้อง **เคยใช้แล้ว**
   - ถ้าเป็นไปได้ ขอ Dev สร้าง user ทดสอบแยกสำหรับ QA + เซ็ต record ให้ หรือบอกวิธี reset การใช้คูปองของ user
2. **ช่วงยอด min/max** — ขอ Dev ระบุค่าจริง เพื่อ QA จะได้จัดจำนวนสินค้า/เลือกสินค้าให้ยอดเข้าเงื่อนไข (มีสินค้าราคาตั้งแต่ ~1,599)
3. **boundary แบบ strict (1.4)** — ยืนยันว่ากฎคือ `> min && < max` จริง (ยอดพอดีขอบ = ใช้ไม่ได้) ตามที่อ่านจากโค้ด `Controller.php:918`
4. **คูปองทุกตัวต้องใช้บน staging** (`wnw2025-frontend.dev-app-bit.com`) ไม่ใช่ prod
5. ปัจจุบันค่าทั้งหมดในไฟล์ test data เป็น `"<<ask-dev>>"` / `_status: "todo"` — เมื่อได้ค่าจะอัปเดตให้เป็น `ready`

---

## 3. Checklist สรุปให้ Dev กรอก (คัดลอกตอบกลับได้เลย)

```
[ ] web_user_token ของ inoobeam@hotmail.com = ______________________  (สำคัญสุด)

[ ] valid.code            = ____________   (min–max: ____–____, ส่วนลด: ______)
[ ] expired.code          = ____________
[ ] used.code             = ____________   (loginUser ใช้แล้ว: yes)
[ ] withMinMax.code       = ____________   (min=____ , max=____)
[ ] amountType.code       = ____________   (หัก ______ บาท)
[ ] percentType.code      = ____________   (หัก ______ %)
[ ] campaign.code         = ____________   (ใช้กับ slug: ____________)
```

---

## 4. เคสที่จะปลดล็อกเมื่อได้ data ครบ (8 เคส)

| TC-ID | เรื่อง | ต้องใช้ |
|---|---|---|
| TC-PROMO-01-R | คูปองถูกต้อง → หักส่วนลด | token + valid |
| TC-PROMO-02-R | คูปองผิด/หมดอายุ → error | token + expired (+ INVALIDXXXX มีแล้ว) |
| TC-PROMO-03-R | พิมพ์เล็ก→ใหญ่ / ว่าง | token + valid |
| TC-PROMO-04 | guest ใส่คูปอง → ต้อง login ก่อน | valid (รันแบบ guest) |
| TC-PROMO-05 | ยอด < min → WM21 | token + withMinMax |
| TC-PROMO-06 | boundary พอดี min/max → ใช้ไม่ได้ | token + withMinMax |
| TC-PROMO-07 | ใช้คูปองซ้ำ → reject | token + used |
| TC-PROMO-09 | amount vs percent vs campaign | token + amount/percent/campaign |
| TC-PROMO-10 | re-validate ตอนกดสั่ง | token + campaign |

> นอกจากนี้ยังมี `TC-CHK-07` (ช่องกรอกส่วนลดที่หน้า checkout) ที่รออยู่ — ใช้ค่าเดียวกับ valid/expired ด้านบน
