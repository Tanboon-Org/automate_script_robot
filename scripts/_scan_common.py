"""Helper ที่ใช้ร่วมกันระหว่าง a11y_scan.py และ link_check.py

- โหลด BASE_URL + รายการ route จาก resources/variables/
- สร้าง Selenium Chrome (headless, ตั้งค่าเหมือน CI ของ suite เดิม)
- ฟังก์ชัน URL ล้วนๆ (ทดสอบได้โดยไม่ต้องมี browser)
"""

import os
from urllib.parse import urljoin, urlparse

import requests  # noqa: F401  (ใช้ผ่าน requote ด้านล่าง / โดยสคริปต์ที่ import)

ENV_FILE = os.environ.get("SCAN_ENV_FILE", "resources/variables/env_staging.yaml")
ROUTES_FILE = os.environ.get("SCAN_ROUTES_FILE", "resources/variables/routes.yaml")

# นามสกุลไฟล์ที่ถือว่าเป็น asset — เช็ค status ได้ แต่ไม่ต้อง "เดินต่อ" (crawl) เข้าไป
ASSET_EXT = (
    ".pdf", ".jpg", ".jpeg", ".png", ".gif", ".webp", ".svg", ".ico",
    ".css", ".js", ".json", ".xml", ".zip", ".mp4", ".webm", ".woff", ".woff2", ".ttf",
)


def _read_yaml(path):
    import yaml
    with open(path, encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def get_base_url():
    base = os.environ.get("BASE_URL")
    if base:
        return base.rstrip("/")
    data = _read_yaml(ENV_FILE)
    return str(data.get("BASE_URL", "")).rstrip("/")


def seed_urls(base_url=None):
    """URL เริ่มต้นสำหรับสแกน = หน้าแรก + ทุก route ที่เป็น path คงที่ใน routes.yaml
    (ตัด PRODUCT_PREFIX / PAYMENT_PREFIX ที่เป็น prefix ประกอบ runtime ออก)
    """
    base = (base_url or get_base_url()).rstrip("/")
    routes = _read_yaml(ROUTES_FILE).get("ROUTES", {})
    seeds = [base + "/"]
    for key, path in routes.items():
        if key.endswith("_PREFIX"):
            continue
        if not isinstance(path, str) or not path.startswith("/"):
            continue
        seeds.append(urljoin(base + "/", path))
    # unique คงลำดับ
    seen, out = set(), []
    for u in seeds:
        if u not in seen:
            seen.add(u)
            out.append(u)
    return out


def same_origin(url, base):
    try:
        a, b = urlparse(url), urlparse(base)
        return (a.scheme, a.netloc) == (b.scheme, b.netloc)
    except Exception:  # noqa: BLE001
        return False


def strip_fragment(url):
    return url.split("#", 1)[0]


def is_asset(url):
    path = urlparse(url).path.lower()
    return path.endswith(ASSET_EXT)


def is_crawlable(url, base):
    """เป็นหน้า HTML ภายในโดเมนเดียวกันที่ควร 'เดินต่อ' ไหม"""
    if not url or url.startswith(("mailto:", "tel:", "javascript:", "data:")):
        return False
    url = strip_fragment(url)
    return same_origin(url, base) and not is_asset(url)


def requote(url):
    """encode อักขระไทย/พิเศษใน URL ให้ requests ยิงได้ (route หลายอันเป็นภาษาไทย)"""
    return requests.utils.requote_uri(url)


def build_driver(headless=True):
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options

    opts = Options()
    if headless:
        opts.add_argument("--headless=new")
    opts.add_argument("--no-sandbox")
    opts.add_argument("--disable-dev-shm-usage")
    opts.add_argument("--disable-gpu")
    opts.add_argument("--window-size=1440,900")
    opts.add_argument("--lang=th-TH")
    # เปิด browser log เพื่ออ่าน JS console error (ใช้ใน link_check)
    opts.set_capability("goog:loggingPrefs", {"browser": "ALL"})
    driver = webdriver.Chrome(options=opts)
    driver.set_page_load_timeout(45)
    driver.set_script_timeout(60)
    return driver


def wait_rendered(driver, extra_sleep=2.0):
    """รอให้หน้า (SPA/Vue) เรนเดอร์เสร็จพอสมควร: readyState complete + หน่วงเล็กน้อย"""
    import time
    try:
        end = time.time() + 15
        while time.time() < end:
            if driver.execute_script("return document.readyState") == "complete":
                break
            time.sleep(0.3)
    except Exception:  # noqa: BLE001
        pass
    time.sleep(extra_sleep)
