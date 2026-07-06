# รีวิวทั้ง Project — automate_script_robot

- **วันที่รีวิว:** 2026-07-06
- **Branch:** `qa/api-track` (HEAD: `18b5134`)
- **ขอบเขต:** Robot test suites (~115 ไฟล์), resources (keywords/locators/variables), Python helpers (`libraries/`, `scripts/`, `listeners/`), CI workflows, config และ repo hygiene

---

## ภาพรวม

โครงสร้าง project อยู่ในเกณฑ์ **ดี** — จุดแข็งที่ควรคงไว้:

- แบ่ง layer แบบ POM ชัดเจน: tests → keywords → locators → variables และมี import hub เดียว (`resources/imports/app_imports.robot`)
- Timeout รวมศูนย์ที่ `timeouts.yaml` ไม่มี magic number กระจัดกระจาย
- Prod safety gate (`ALLOW_PROD_ORDER` / `ALLOW_PROD_2C2P` default-off) ออกแบบดี
- Teardown (`Close WNW Browser`) ครบทั้ง 106 browser tests, เทสต์แยกไฟล์ละเคส + เปิด browser ใหม่ทุกครั้ง (isolation ดี)
- Headless CI parity ทำถูกต้อง (headless=new, fixed window size, `--no-sandbox`, `--disable-dev-shm-usage`, locale th-TH)
- CI มี `timeout-minutes`, `concurrency` + `cancel-in-progress`, upload artifact และ Teams notify ด้วย `if: !cancelled()` แล้ว
- `scripts/analyze_results.py` ไม่มีทางทำ CI fail (ทุก path คืน exit 0) ตามที่ตั้งใจ
- Repo ขนาด 1.2GB มาจาก `results/` ซึ่ง ignore ไว้ถูกต้องแล้ว — ไฟล์ที่ track จริงมีแค่ 187 ไฟล์

แต่มี **ประเด็นเร่งด่วน 3 เรื่อง** และประเด็นรองตามรายการด้านล่าง

---

## 🔴 เร่งด่วน (ควรทำทันที)

### 1. Credentials จริงถูก commit ลง git

| ตำแหน่ง | สิ่งที่หลุด |
|---|---|
| `resources/variables/test_data/wnw-checkout-orderflow.testdata.json:73-74` | password `123456789_Sno` + `webUserToken` แบบ Laravel Sanctum (`1295|Koa...`) ซึ่งเป็น API credential ที่ใช้งานได้จริง |
| `resources/variables/test_data/users.json:8,24,32` | password plaintext ของบัญชี `champw05w@gmail.com` (ใช้ซ้ำกับ user "unverified") |

ค่าเหล่านี้อยู่ใน git history หลาย commit แล้ว (`acc6243`, `886c394`, `d0e1020`, `1c07c1a`) ดังนั้นลบไฟล์อย่างเดียวไม่พอ

**แนวทางแก้:**
1. **Rotate token + เปลี่ยน password ฝั่ง backend ก่อน** — นี่คือ remediation จริงเพียงทางเดียว
2. ย้ายค่าไปอ่านจาก env var / GitHub secrets (เช่น `%{WNW_LOGIN_PASSWORD}`) เหลือ placeholder ในไฟล์
3. ประเด็นซ้ำเติม: keyword login ใช้ `Input Text Reliably` พิมพ์ password (`resources/keywords/page_keywords/auth_page_keywords.resource:48,92`) ทำให้ค่า password โผล่ใน `log.html`/`output.xml` ที่ CI upload เป็น artifact เก็บ 14 วัน — เปลี่ยนเป็น `Input Password` (SeleniumLibrary ไม่ log ค่า) หรือเพิ่ม `--removekeywords name:*Password*` ในคำสั่งรันบน CI

### 2. `requests` หายจาก requirements.txt

`libraries/api_library.py:20` ทำ `import requests` แต่ `requirements.txt` ไม่มี และตรวจแล้วไม่มี dependency ตัวไหนลากมาให้ (selenium 4.x ใช้แค่ urllib3/trio/websocket-client/certifi) — บน runner สะอาด **api suites จะพังตั้งแต่ import library** ที่ `quality-scan.yml:36` ต้อง `pip install requests` เองด้วยมือก็เป็นหลักฐานว่ารู้อยู่แล้วว่าขาด

**แนวทางแก้:** เพิ่ม `requests==2.32.*` (pin เวอร์ชัน) ลง `requirements.txt`

### 3. SSRF ใน link crawler

`scripts/link_check.py:107-114` เก็บทุก URL จาก `<a href>`/`<img src>` (กรองแค่ `mailto:/tel:/javascript:/data:`) แล้ว `check_status()` (`link_check.py:53-63`) ยิง HEAD/GET ตามไปหมดพร้อม `allow_redirects=True` — ถ้าเนื้อหาบนเว็บ (CMS banner, test data) มีลิงก์ไป `http://169.254.169.254/` หรือ `http://localhost:...` runner ของ GitHub Actions จะยิงตามและ echo URL ลง Teams summary

**แนวทางแก้:** ก่อนยิง request ให้เช็ค `urlparse(u).scheme in ("http", "https")` และ resolve host แล้ว reject IP range แบบ private/loopback/link-local (ใช้โมดูล `ipaddress`) พิจารณา `allow_redirects=False` สำหรับลิงก์ external หรือ validate ทุก redirect hop

---

## 🟠 ระดับกลาง

### ความเสถียรของเทสต์ (flakiness)

- **Locator ปุ่ม stepper ผูกกับ Tailwind class + index** — `resources/locators/cart_page_locators.resource:10-11` ใช้ `xpath=(//button[contains(@class,'shadow-inner-xl')])[1]`/`[2]` ผูกกับ utility class และลำดับ DOM ทั้งหน้า restyle เมื่อไหร่ `Clear Cart` / TC-CART-02 / TC-CART-06 พังเงียบ ๆ → ขอ `data-testid` หรือ `aria-label` จาก dev หรืออย่างน้อย scope XPath เข้า row ของ cart item
- **`Sleep` 15 วินาทีแบบ unconditional** — `resources/keywords/page_keywords/checkout_page_keywords.resource:338` (`Apply Coupon And Assert No Discount` sleep `${TIMEOUTS}[RENDERER_SLOW]` ทุกรอบ) ทั้งช้าและยังแข่งกับ render อยู่ดี → รอ toast/สถานะ reject ด้วย `Wait Until Keyword Succeeds` แล้วค่อยเทียบยอด
- **`Dismiss Cookie` แข่งกับ banner ที่ mount ช้า** — `resources/keywords/feature_keywords/common_feature_keywords.resource:10-16` เช็ค `Element Should Be Visible` แบบ one-shot ทันทีหลังโหลดหน้า banner ที่ animate เข้ามาหลัง hydration บน CI ช้า ๆ จะรอดการเช็คแล้วมาบังคลิกทีหลัง (อาการพังเฉพาะ headless CI แบบคลาสสิก) → รอสั้น ๆ 2-3 วิ ก่อนตัดสินว่าไม่มี หรือ JS-remove node ทิ้ง
- **Locator ผูกกับข้อความไทย/marketing copy จำนวนมาก** — เช่น `checkout_page_locators.resource:62` (`//button[contains(.,'ชำระเงิน')]`), `cart_page_locators.resource:8` (`'ซื้อทันที'`), `home_page_locators.resource:14-16` และ `${CHK_FREE_SHIPPING}` (`contains(text(),'ฟรี')`) เสี่ยง false-match ข้อความโปรโมชันอื่น → ขอ `data-testid` สำหรับ ~10 ปุ่มหลัก (submit, buy-now, add-to-cart, qty steppers) และรวม text fragment ไว้ที่ `messages.yaml`

### ความถูกต้องของเทสต์

- **Assert ยอดรวมจากราคา static** — `tests/cart/TC-CART-06_qty-capped-at-10.robot:13-21` และ `tests/checkout/TC-CHK-06-R_multi-item-total.robot:15-24` ใช้ราคา 1599/2899 จาก `products.json` ทั้งที่ไฟล์เตือนเองว่า "ราคาอ่านจากหน้า runtime" → อ่านราคาจริงจาก PDP ด้วย `Get PDP Price` แบบที่ `TC-PAY_full-purchase-loop.robot` ทำอยู่แล้ว
- **Bug ใน `parse_amount` ตัดเครื่องหมายลบทิ้ง** — `libraries/custom_library.py:215-226` regex `\d+(?:\.\d+)?` ทำให้ `"-฿50.00"` ได้ `50.0` assertion เกี่ยวกับส่วนลด/refund ผ่านทั้งที่เครื่องหมายผิด → normalize `−`→`-` แล้วใช้ `-?\d+(?:\.\d+)?` (แก้ `parse_int_amount` บรรทัด 229 ด้วย)
- **เทสต์สร้าง order ไม่มี cleanup** — `tests/payment/TC-PAY-05_payment-channels.robot` และ `tests/e2e/TC-PAY_full-purchase-loop.robot` สร้าง order จริงบน staging ทุกรอบ CI, `[Teardown]` ปิดแค่ browser — order ค้างสะสมใน DB และ email ทดสอบได้รับแจ้งเตือนจริงทุกครั้ง → เพิ่ม teardown cancel order ผ่าน API หรือทำ cleanup job แยก
- **Coupon suites แชร์ cart ฝั่ง server ผ่าน user เดียว** — `resources/keywords/suite_helpers.resource:99-122` เทสต์ promo ทั้ง 4 login เป็น user TD-30 คนเดียวกัน `Clear Cart` ช่วยได้ระดับหนึ่ง แต่รันขนาน (pabot) หรือรัน local ชนกับ CI เมื่อไหร่ state พังใส่กัน → document/บังคับรัน serial สำหรับ `feature:promo` หรือ provision user ต่อ run ผ่าน API

### CI / dependencies

- **`google-genai` ติดตั้ง ad hoc + ไม่ pin** — `.github/workflows/robot.yml:78` ทำ `pip install "google-genai>=1.0"` ใน step ไม่ reproducible และหลุด pip cache key → ย้ายลง `requirements.txt` แล้ว pin
- **quality-scan ติดตั้ง dependency คนละชุด** — `quality-scan.yml:33` ตั้ง cache key ผูกกับ `requirements.txt` แต่บรรทัด 36 ติดตั้ง `"selenium>=4.27" requests PyYAML` แบบ unpinned และไม่เคยลง requirements.txt เลย — เวอร์ชัน drift ระหว่าง 2 workflows → ใช้ `pip install -r requirements.txt` ทั้งคู่
- **requirements.txt pin ครึ่งเดียว** — บรรทัด 6-9 ใช้ `>=` (`robotframework-pythonlibcore`, `PyYAML`, `selenium`) CI จะ upgrade เงียบ ๆ เมื่อเวลาผ่านไป → pin เวอร์ชันตายตัว หรือใช้ pip-tools/lock file
- **`robot.yaml` drift จาก CI** — task "Staging" (`robot.yaml:13`) ไม่มี `--exclude createsorder` และไม่มี `--pythonpath` ที่ CI ใช้ (`robot.yml:59-66`) รัน profile "เดียวกัน" จาก local จะยิงเทสต์สร้าง order ที่ CI ตั้งใจกันไว้ → เพิ่ม task `Staging CI` ให้เป็น source of truth เดียวแล้วให้ workflow เรียก task นั้น
- **Gemini call ไม่มี timeout** — `scripts/analyze_results.py:120-129` ถ้า API ค้าง step จะค้างจนชน job timeout ทั้งที่ script ออกแบบมาไม่ให้ block notification → ใส่ `http_options=types.HttpOptions(timeout=60_000)`
- **Error message ดิบของ Gemini ขึ้น Teams card** — `analyze_results.py:163` เขียน `{type(e).__name__}: {e}` ลง `ai_analysis.md` ซึ่งถูก render บน Teams card + upload เป็น artifact — SDK error อาจมี URL/header ปน → เขียนแค่ชื่อ exception ลง card (stderr มี log เต็มอยู่แล้วที่บรรทัด 155)

---

## 🟡 ระดับเบา (เก็บตกได้)

### Python helpers

- **Screenshot listener default `SHOT_MODE=all`** — `listeners/ScreenshotListener.py:50-65` ถ่ายหลังทุก keyword รวม getter/assertion run ยาว ๆ ได้ log.html หลายร้อย MB เปิดไม่ขึ้น → default เป็น `action`
- **Listener อ่าน attribute ที่ deprecated** — `ScreenshotListener.py:53-55` ใช้ `result.libname`/`result.kwname` (RF 7 เปลี่ยนเป็น `owner`/`name`) พอถูกถอดใน RF 8 `getattr(..., None)` จะคืน None แล้ว listener หยุดถ่ายเงียบ ๆ → `getattr(result, "owner", None) or getattr(result, "libname", None)`
- **`warnings.filterwarnings("ignore")` ระดับ process** — `libraries/api_library.py:23` ปิด warning ทั้งหมดของทั้ง Robot process (รวม deprecation ของ SeleniumLibrary/RF) → scope filter ให้แคบ เหลือแค่ urllib3
- **link crawler ไม่จำกัดจำนวนลิงก์ + เช็ค serial** — `link_check.py:125-128` ลิงก์ช้า 500 ตัว × timeout 20s × (HEAD+GET) = CI หลายชั่วโมง → cap จำนวนลิงก์ + ใช้ `ThreadPoolExecutor` เล็ก ๆ
- **`requests.Session` ไม่ถูกปิด** — `link_check.py:67` (`finally` ปิดแค่ driver) → ใช้ `with requests.Session() as session:`
- **Dead code** — `link_check.py:57` เงื่อนไข `status_code == 405` unreachable (405 ≥ 400 อยู่แล้ว) และ `status_cache` (`link_check.py:124-127`) ไม่มีทาง hit เพราะ loop วนบน key ที่ unique อยู่แล้ว
- **a11y summary ทำให้เข้าใจผิดเมื่อ scan fail ทุกหน้า** — `scripts/a11y_scan.py:113-123` ถ้า error ทุกหน้า card จะขึ้น "พบ **0** จุด จาก 0 หน้า" ดูเหมือนผ่าน → เพิ่ม branch `scanned == 0` รายงาน "สแกนไม่สำเร็จทุกหน้า"
- **`same_origin` เทียบ scheme ด้วย** — `scripts/_scan_common.py:59-64` ถ้า `BASE_URL` เป็น `http://` แต่เว็บ serve ลิงก์ `https://` ลิงก์ internal ทั้งหมดถูกจัดเป็น external crawl ได้แค่ seed → เทียบเฉพาะ hostname (+port)
- **api_library ห่อ non-JSON response เป็น `json: {}`** — `api_library.py:33-38` assertion เทียบกับ empty dict แทนที่จะ fail ชัด ๆ → คืน `None` หรือเพิ่ม flag `parsed`

### Robot suites

- **Keyword ซ้ำซ้อน** — `Click First Visible` (`auth_page_keywords.resource:30-41`) ก็อป `Click First Visible Element` (`common_keywords.resource:261-271`) แบบด้อยกว่า (ไม่มี stale-element retry / JS-click fallback) และ `Setup Payment Channels Test` (`TC-PAY-05_payment-channels.robot:61-67`) ก็อป `Setup Purchase Loop Test` (`suite_helpers.resource:48-53`) → ลบตัวก็อป ใช้ตัว shared
- **Block "add product → cart" พิมพ์ซ้ำใน ~10 เทสต์** — เช่น `TC-CHK-06-R:16-21`, `TC-PDP-04:14-17`, `TC-CART-01`, `TC-GBL-02` ทั้งที่ `suite_helpers.resource` มี `Open H014 In Cart` / `Setup Checkout` อยู่แล้ว → เรียก helper (เพิ่ม argument `${product_key}` สำหรับสินค้าอื่น)
- **`Force Tags` (deprecated) หลงเหลือ 2 ไฟล์** — `tests/api/TC-API-01_order-empty-payload-422.robot:6`, `tests/api/TC-CHK-12_invalid-slug-rejected.robot:8` ขณะที่อีก 110 ไฟล์ใช้ `Test Tags` → ปรับให้เหมือนกัน
- **api suites ไม่มี default `${BASE_URL}`** — `TC-API-01:12` import แค่ `api_library.py` รัน `robot tests/api` เปล่า ๆ (ไม่มี `--variablefile`) จะ fail ที่ตัวแปร undefined → เพิ่ม `Variables ../../resources/variables/env_staging.yaml`
- **TC-TRK-01 hard-code เลข order prod** — `tests/tracking/TC-TRK-01_track-by-order-code.robot:16` ใช้ `O-0000291286` และ skip บน staging = ไม่มี coverage บน CI เลย → ย้ายเข้า test data + chain จาก order ที่ purchase-loop สร้าง
- **Message constants อยู่ผิดที่** — `checkout_page_locators.resource:33-43` มี `${MSG_COUPON_*}` / `${MSG_CARD_*}` อยู่ในไฟล์ locators ทั้งที่มี `messages.yaml` ไว้เพื่อการนี้ → ย้ายไปรวมที่เดียว

### CI / docs

- **Teams webhook fail แล้ว `exit 1`** — `robot.yml:171-174` run เขียว ๆ กลายเป็นแดงเพราะ notification สะดุด และ webhook URL ถูกส่งเป็น curl CLI argument (มองเห็นได้ใน process list ของ runner) → ลดเป็น `::warning::` และส่ง URL ผ่าน curl config ทาง stdin
- **README.md ว่างเปล่า** — มีแค่ `# automate_script_robot` → ใส่ layout, วิธีรัน (robot.yaml tasks), workflows ทั้งสอง และ secrets ที่ต้องตั้ง (`TEAMS_WEBHOOK_URL`, `GEMINI_API_KEY`) และลบ `README copy.md` ที่ค้างในโฟลเดอร์

---

## ลำดับการแก้ที่แนะนำ

| ลำดับ | งาน | เหตุผล | สถานะ |
|---|---|---|---|
| 1 | Rotate token + password ที่หลุด แล้วย้ายเข้า env var / GitHub secrets | ข้อเดียวที่มีผลกระทบนอก repo — ทำก่อนทุกอย่าง | ⏳ รอ rotate ฝั่ง backend |
| 2 | เพิ่ม `requests` + `google-genai` ลง requirements.txt แล้ว pin ทั้งไฟล์ | ปลดล็อก api suites บน runner สะอาด + CI reproducible | ✅ แก้แล้ว 2026-07-06 (รวมย้าย workflow ทั้งสองมาใช้ requirements.txt) |
| 3 | แก้ SSRF filter ใน `link_check.py` + sign bug ใน `parse_amount` | แก้สั้น ผลคุ้ม (ความปลอดภัย + ความถูกต้องของ assertion) | ✅ แก้แล้ว 2026-07-06 (validate ทุก redirect hop + เก็บเครื่องหมายลบ, แก้ `parse_int_amount` ด้วย) |
| 4 | เก็บ flakiness เป็น batch: ขอ `data-testid` จาก dev, แก้ `Dismiss Cookie`, แทน `Sleep` 15s | ลดเทสต์พังหลอกบน CI ระยะยาว | — |
| 5 | เก็บตกระดับเบา (dedupe keywords, `Force Tags`, README, screenshot mode) | ทำแทรกได้เรื่อย ๆ | — |
