#!/usr/bin/env python3
"""Crawler ตรวจสุขภาพเว็บ: ลิงก์เสีย / รูปโหลดไม่ขึ้น / JS console error

เว็บเป็น SPA (Vue) จึงเรนเดอร์แต่ละหน้าด้วย Chrome ก่อน แล้วค่อยเก็บลิงก์:
1. เริ่มจาก seed (หน้าแรก + route ใน routes.yaml), BFS เดินตามลิงก์ภายในโดเมนเดียวกัน (จำกัด MAX_PAGES)
2. เก็บ <a href> + <img src> ทุกหน้า -> ยิง HTTP เช็ค status (>=400 = เสีย)
3. อ่าน browser console เก็บ error ระดับ SEVERE ต่อหน้า

ผลลัพธ์:
- results/linkcheck_report.md   : รายงานเต็ม
- results/linkcheck_summary.md  : สรุปสั้นสำหรับ Teams
- results/linkcheck_report.json : ดิบ

หมายเหตุ SPA: route ภายในมักตอบ 200 (index.html) แม้ path ไม่มีจริง — สัญญาณที่เชื่อได้สุด
คือ "ลิงก์นอก/asset เสีย" และ "JS error" ส่วน internal route ให้ดูประกอบ
fail-open เสมอ: ไม่ทำ pipeline ล่ม
"""

import json
import os
import re
import sys
from collections import deque
from urllib.parse import urlparse

import requests

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _scan_common as sc  # noqa: E402

REPORT_MD = os.environ.get("LINK_REPORT", "results/linkcheck_report.md")
REPORT_JSON = os.environ.get("LINK_REPORT_JSON", "results/linkcheck_report.json")
SUMMARY_MD = os.environ.get("LINK_SUMMARY", "results/linkcheck_summary.md")
MAX_PAGES = int(os.environ.get("LINK_MAX_PAGES", "40"))
HTTP_TIMEOUT = int(os.environ.get("LINK_HTTP_TIMEOUT", "20"))
UA = "Mozilla/5.0 (compatible; WNW-QA-linkcheck/1.0)"

COLLECT_LINKS = (
    "return {"
    "  links: Array.from(document.querySelectorAll('a[href]')).map(a => a.href),"
    "  images: Array.from(document.querySelectorAll('img[src]')).map(i => i.src)"
    "};"
)


def _write_summary(text):
    os.makedirs(os.path.dirname(SUMMARY_MD) or ".", exist_ok=True)
    with open(SUMMARY_MD, "w", encoding="utf-8") as f:
        f.write(text.strip() + "\n")
    print(text)


def check_status(session, url):
    """คืน (status_code:int|None, note:str). ลอง HEAD ก่อน ถ้าไม่รองรับค่อย GET"""
    try:
        r = session.head(sc.requote(url), allow_redirects=True, timeout=HTTP_TIMEOUT)
        if r.status_code >= 400 or r.status_code == 405:
            r = session.get(sc.requote(url), allow_redirects=True, timeout=HTTP_TIMEOUT, stream=True)
            r.close()
        return r.status_code, ""
    except requests.RequestException as e:
        return None, type(e).__name__


def crawl(base):
    driver = sc.build_driver()
    session = requests.Session()
    session.headers["User-Agent"] = UA

    visited_pages = []                 # หน้า HTML ที่เปิดเรนเดอร์แล้ว
    queued = set()
    queue = deque()
    for u in sc.seed_urls(base):
        s = sc.strip_fragment(u)
        if s not in queued:
            queued.add(s)
            queue.append(s)

    link_sources = {}                  # url -> set(หน้าที่พบลิงก์นี้)
    js_errors = {}                     # page -> [msg,...]
    page_load_errors = []              # {page, error}

    try:
        while queue and len(visited_pages) < MAX_PAGES:
            page = queue.popleft()
            try:
                driver.get(page)
                sc.wait_rendered(driver)
            except Exception as e:  # noqa: BLE001
                page_load_errors.append({"page": page, "error": f"{type(e).__name__}: {e}"})
                continue
            visited_pages.append(page)

            # JS console errors ระดับ SEVERE
            try:
                for entry in driver.get_log("browser"):
                    if entry.get("level") == "SEVERE":
                        js_errors.setdefault(page, []).append(entry.get("message", "")[:300])
            except Exception:  # noqa: BLE001
                pass

            # เก็บลิงก์ + รูป
            try:
                found = driver.execute_script(COLLECT_LINKS) or {}
            except Exception:  # noqa: BLE001
                found = {}
            for u in (found.get("links", []) + found.get("images", [])):
                if not u or u.startswith(("mailto:", "tel:", "javascript:", "data:")):
                    continue
                u = sc.strip_fragment(u)
                link_sources.setdefault(u, set()).add(page)
                # เดินต่อเฉพาะหน้า HTML ภายในโดเมน
                if u not in queued and sc.is_crawlable(u, base):
                    queued.add(u)
                    queue.append(u)
    finally:
        try:
            driver.quit()
        except Exception:  # noqa: BLE001
            pass

    # เช็ค status ของทุกลิงก์ที่เจอ
    broken = []
    status_cache = {}
    for url, sources in link_sources.items():
        if url not in status_cache:
            status_cache[url] = check_status(session, url)
        code, note = status_cache[url]
        if code is None or code >= 400:
            broken.append({
                "url": url,
                "status": code if code is not None else f"ERR:{note}",
                "internal": sc.same_origin(url, base),
                "found_on": sorted(sources)[:5],
            })

    return {
        "pages_scanned": len(visited_pages),
        "links_checked": len(link_sources),
        "broken": broken,
        "js_errors": js_errors,
        "page_load_errors": page_load_errors,
    }


def _classify_js(msg):
    low = msg.lower()
    if "failed to load resource" in low or "manifest fetch" in low:
        return "resource"          # ไฟล์/asset โหลดไม่ขึ้น (มักเป็น minor)
    return "js"                    # exception จริงในโค้ด (บั๊ก priority สูงกว่า)


def _norm_js(msg):
    """normalize ข้อความ error เพื่อจัดกลุ่มข้ามหน้า (ตัด url / เลขบรรทัด / hash)"""
    m = re.sub(r"https?://\S+", "", msg)
    m = re.sub(r"\b[0-9a-f]{8,}\b", "", m)   # hash เช่นชื่อ chunk
    m = re.sub(r"\d+", "", m)                # เลขบรรทัด/คอลัมน์/สถานะ
    return re.sub(r"\s+", " ", m).strip()[:160] or msg[:160]


def _resource_path(msg):
    m = re.search(r"https?://[^\s]+", msg)
    if not m:
        return msg[:80]
    p = urlparse(m.group(0))
    return (p.path or m.group(0)).split("?", 1)[0]


def aggregate_js(js_errors):
    """js_errors: page -> [msg]  =>  (js_groups, resource_groups)
    js_groups:  normkey -> {sample, pages:set}
    resource_groups: path -> {pages:set}
    """
    js_groups, res_groups = {}, {}
    for page, msgs in js_errors.items():
        for msg in msgs:
            if _classify_js(msg) == "resource":
                key = _resource_path(msg)
                res_groups.setdefault(key, {"pages": set()})["pages"].add(page)
            else:
                key = _norm_js(msg)
                slot = js_groups.setdefault(key, {"sample": msg, "pages": set()})
                slot["pages"].add(page)
    return js_groups, res_groups


def build_reports(data):
    broken = data["broken"]
    ext_broken = [b for b in broken if not b["internal"]]
    int_broken = [b for b in broken if b["internal"]]
    js_groups, res_groups = aggregate_js(data["js_errors"])
    # เรียงบั๊ก JS ตามจำนวนหน้าที่พบ (มากสุดก่อน)
    js_sorted = sorted(js_groups.items(), key=lambda kv: -len(kv[1]["pages"]))
    res_sorted = sorted(res_groups.items(), key=lambda kv: -len(kv[1]["pages"]))

    md = ["# Link & Health Check (crawler)", ""]
    md.append(f"- หน้าที่เดินเรนเดอร์: **{data['pages_scanned']}**")
    md.append(f"- ลิงก์/รูป ที่ตรวจ: **{data['links_checked']}**")
    md.append(f"- ลิงก์เสีย: **{len(broken)}** (ภายนอก/asset {len(ext_broken)}, ภายใน {len(int_broken)})")
    md.append(f"- JS exception (บั๊กโค้ด): **{len(js_sorted)}** แบบ / resource โหลดไม่ขึ้น: **{len(res_sorted)}** แบบ")
    md.append("")

    md.append("## ลิงก์เสีย")
    if broken:
        md.append("| URL | status | ประเภท | พบที่หน้า |")
        md.append("|---|---|---|---|")
        for b in sorted(broken, key=lambda x: (x["internal"], str(x["status"]))):
            kind = "ภายใน" if b["internal"] else "ภายนอก/asset"
            md.append(f"| {b['url']} | {b['status']} | {kind} | {', '.join(b['found_on'])} |")
    else:
        md.append("ไม่พบลิงก์เสีย ✅")
    md.append("")

    md.append("## JS exception (บั๊กโค้ด — priority สูง)")
    if js_sorted:
        for _key, s in js_sorted:
            pages = sorted(s["pages"])
            md.append(f"- **{len(pages)} หน้า** เช่น {pages[0]}")
            md.append(f"  - `{s['sample'][:280]}`")
    else:
        md.append("ไม่พบ ✅")
    md.append("")

    md.append("## Resource โหลดไม่ขึ้น (มักเป็น minor)")
    if res_sorted:
        for path, s in res_sorted:
            md.append(f"- `{path}` — {len(s['pages'])} หน้า")
    else:
        md.append("ไม่พบ ✅")

    if data["page_load_errors"]:
        md.append("")
        md.append("## หน้าที่เปิดไม่สำเร็จ")
        for p in data["page_load_errors"]:
            md.append(f"- {p['page']} — {p['error']}")

    # ---- summary สั้นสำหรับ Teams (เน้นบั๊กจริง) ----
    if not broken and not js_sorted and not res_sorted:
        summary = f"**🔗 Link/Health:** ✅ ไม่พบปัญหา จาก {data['pages_scanned']} หน้า / {data['links_checked']} ลิงก์"
    else:
        lines = [f"**🔗 Link/Health:** ลิงก์เสีย **{len(broken)}** · "
                 f"JS exception **{len(js_sorted)}** แบบ · resource โหลดไม่ขึ้น **{len(res_sorted)}** แบบ "
                 f"— จาก {data['pages_scanned']} หน้า"]
        for b in (ext_broken + int_broken)[:3]:
            lines.append(f"- ⛔ [{b['status']}] {b['url']}")
        for _key, s in js_sorted[:3]:
            lines.append(f"- ⛔ (JS) {s['sample'][:120]} — {len(s['pages'])} หน้า")
        for path, s in res_sorted[:2]:
            lines.append(f"- ⚠️ (resource) {path} — {len(s['pages'])} หน้า")
        summary = "\n".join(lines)

    return "\n".join(md), summary


def main():
    base = sc.get_base_url()
    if not base:
        _write_summary("**🔗 Link/Health:** _ข้าม — หา BASE_URL ไม่เจอ_")
        return 0
    try:
        data = crawl(base)
    except Exception as e:  # noqa: BLE001
        _write_summary(f"**🔗 Link/Health:** _สแกนไม่สำเร็จ ({type(e).__name__}: {e})_")
        return 0

    report_md, summary = build_reports(data)
    os.makedirs(os.path.dirname(REPORT_MD) or ".", exist_ok=True)
    with open(REPORT_MD, "w", encoding="utf-8") as f:
        f.write(report_md + "\n")
    with open(REPORT_JSON, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, default=list)
    _write_summary(summary)
    return 0


if __name__ == "__main__":
    sys.exit(main())
