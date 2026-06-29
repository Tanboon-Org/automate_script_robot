# Plan: รัน WNW E2E Automation บน GitHub Actions (CI/CD)

> เอกสารแผนงาน — สรุปสิ่งที่ต้องทำเพื่อนำ Playwright framework ขึ้นรันบน GitHub Actions
> ตัดสินใจแล้ว: รัน **staging atomic/regression**, **ไม่แตะ prod**, **ลบไฟล์ขยะ `*:Zone.Identifier`**

---

## 1. สิ่งที่เจอในโปรเจกต์ (context สำคัญต่อ CI)

| ประเด็น | รายละเอียด |
|---|---|
| Root ของ npm/Playwright | อยู่ที่ `automation/` (package.json + configs อยู่ในนั้น) **ไม่ใช่** git repo root |
| ทดสอบกับอะไร | ยิงเว็บ **live** (staging `wnw2025-frontend.dev-app-bit.com` / prod `wreathnawat.com`) — ไม่มี local server ต้อง start |
| ค่า default | `npx playwright test` = staging, ปลอดภัย (ไม่สร้าง order) |
| Secrets/env | `.env` ถูก gitignore แล้ว — ตัวแปรมีแค่ `ENV`, `BASE_URL`, `ALLOW_PROD_ORDER`, `ALLOW_PROD_2C2P`, `DEBUG_LOG` ไม่มี login/credential จริง |
| Safety gate | prod จะ skip เทสที่สร้าง order เว้นแต่ตั้ง `ALLOW_PROD_*=1` |
| `CI` flag | `playwright.base.ts` ใช้ `forbidOnly: !!process.env.CI` อยู่แล้ว, `retries=2`, `workers=1` |
| ขยะใน repo | มีไฟล์ `*:Zone.Identifier` เต็มไปหมด (artifact จาก Windows/WSL) ควรลบ + gitignore |

---

## 2. การตัดสินใจที่ยืนยันแล้ว

- **Test scope:** Staging atomic/regression เท่านั้น (ชุดที่ไม่สร้าง order) — รันทุก push/PR
- **Production:** ไม่แตะ prod เลย — CI รันแค่ staging
- **Cleanup:** ลบไฟล์ `*:Zone.Identifier` ทั้งหมด + เพิ่มใน `.gitignore`

---

## 3. งานที่จะทำ

### 3.1 ลบไฟล์ขยะ + กัน gitignore
- ลบ `*:Zone.Identifier` ทั้งหมดในทุกโฟลเดอร์ (artifact จาก Windows/WSL)
- เพิ่มบรรทัด `*:Zone.Identifier` ใน `.gitignore`
- Verify ว่า `.env` ไม่เคยถูก commit เข้า git

### 3.2 สร้าง workflow `.github/workflows/playwright.yml` (ที่ git root)

โครงร่าง:

```yaml
on: push (main), pull_request (main), workflow_dispatch
job: ubuntu-latest
defaults.run.working-directory: automation
steps:
  - checkout
  - setup-node 20 + cache npm (path: automation/package-lock.json)
  - npm ci
  - npx playwright install --with-deps chromium
  - run: ENV=staging npx playwright test tests/atomic tests/regression
  - upload-artifact (if: always()) -> playwright-report + test-results
```

หมายเหตุ:
- `CI=true` ถูก GitHub set ให้อยู่แล้ว → `forbidOnly` ทำงานเอง
- **ไม่** ใส่ `ALLOW_PROD_*` และ **ไม่มี** job prod → ปลอดภัย ไม่สร้าง order จริง
- เทส `tests/e2e/purchase-loop.spec.ts` (สร้าง order บน staging) จะ **ไม่ถูกรัน** เพราะระบุเฉพาะ `tests/atomic` + `tests/regression`

### 3.3 แก้ path report ให้ตรงกัน (จุดที่ต้องระวัง)
- ปัจจุบัน root config เขียน report ไป `../playwright-report` แต่ stg/prod config สืบจาก base = `../../playwright-report` → path ไม่ตรงกัน
- CI จะรันด้วย config default (root) → workflow upload จาก path ที่ root config ใช้จริง (`playwright-report/` ที่ repo root)
- จะ verify path จริงโดยรันในเครื่องก่อนเขียน workflow

### 3.4 (optional) เพิ่ม GitHub reporter ตอน CI
- เพิ่ม `process.env.CI ? ['github'] : []` ใน reporter list ของ `playwright.base.ts` เพื่อให้ failure ขึ้น annotation ใน PR
- ถ้าไม่อยากแตะ config เดิม ข้ามได้

---

## 4. สิ่งที่จะ **ไม่** ทำ
- ไม่แตะ prod config
- ไม่ใส่ secret prod
- ไม่เปลี่ยน safety gate (`ALLOW_PROD_*`)
- ไม่รัน e2e ที่สร้าง order (`tests/e2e/purchase-loop.spec.ts`)

---

## 5. จุดที่ต้องยืนยันก่อนลงมือ
- เทส `tests/regression/2c2p-card-declined.spec.ts` ยิง sandbox card เข้า 2C2P บน staging
  - บน staging ปลอดภัย (ไม่ติด ALLOW gate)
  - ถ้าไม่อยากให้รันใน CI → ใช้ `--grep-invert` ตัดออกได้
  - **default:** รวมไว้ตามเดิม
