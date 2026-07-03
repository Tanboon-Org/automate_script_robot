#!/usr/bin/env python3
"""สแกน Accessibility (WCAG) ทุกหน้า seed ด้วย axe-core

หาบั๊กประเภท "ผู้ใช้เข้าถึงไม่ได้" อัตโนมัติ โดยไม่ต้องเขียนเทสเคส:
เปิดแต่ละหน้าใน Chrome -> inject axe.min.js -> axe.run() -> รวมผล violations

ผลลัพธ์:
- results/a11y_report.md   : รายงานเต็ม (ต่อหน้า + สรุปตามกฎ)
- results/a11y_summary.md  : สรุปสั้นสำหรับการ์ด Teams
- results/a11y_report.json : ดิบ ไว้ประมวลผลต่อ

fail-open: ผิดพลาดที่หน้าไหนข้ามหน้านั้น, พังทั้งหมดก็ยัง exit 0 (ไม่ทำ pipeline ล่ม)
"""

import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import _scan_common as sc  # noqa: E402

AXE_JS = os.path.join(os.path.dirname(os.path.abspath(__file__)), "vendor", "axe.min.js")
REPORT_MD = os.environ.get("A11Y_REPORT", "results/a11y_report.md")
REPORT_JSON = os.environ.get("A11Y_REPORT_JSON", "results/a11y_report.json")
SUMMARY_MD = os.environ.get("A11Y_SUMMARY", "results/a11y_summary.md")
MAX_PAGES = int(os.environ.get("A11Y_MAX_PAGES", "25"))
IMPACT_ORDER = ["critical", "serious", "moderate", "minor"]

RUN_AXE = (
    "var cb = arguments[arguments.length - 1];"
    "try {"
    "  axe.run(document, {resultTypes: ['violations']})"
    "    .then(function(r){ cb({violations: r.violations}); })"
    "    .catch(function(e){ cb({error: String(e)}); });"
    "} catch (e) { cb({error: String(e)}); }"
)


def _ensure_dirs():
    for p in (REPORT_MD, REPORT_JSON, SUMMARY_MD):
        os.makedirs(os.path.dirname(p) or ".", exist_ok=True)


def _write_summary(text):
    os.makedirs(os.path.dirname(SUMMARY_MD) or ".", exist_ok=True)
    with open(SUMMARY_MD, "w", encoding="utf-8") as f:
        f.write(text.strip() + "\n")
    print(text)


def scan_page(driver, axe_src, url):
    driver.get(url)
    sc.wait_rendered(driver)
    driver.execute_script(axe_src)
    res = driver.execute_async_script(RUN_AXE)
    if not isinstance(res, dict) or res.get("error"):
        raise RuntimeError((res or {}).get("error", "axe คืนผลผิดรูปแบบ"))
    out = []
    for v in res.get("violations", []):
        out.append({
            "id": v.get("id"),
            "impact": v.get("impact") or "minor",
            "help": v.get("help"),
            "nodes": len(v.get("nodes", [])),
        })
    return out


def build_reports(results):
    """results: list of {url, ok, violations|error}"""
    by_rule = {}          # id -> {impact, help, pages, nodes}
    impact_count = {k: 0 for k in IMPACT_ORDER}
    scanned = errored = 0

    for r in results:
        if not r.get("ok"):
            errored += 1
            continue
        scanned += 1
        for v in r["violations"]:
            impact_count[v["impact"]] = impact_count.get(v["impact"], 0) + 1
            slot = by_rule.setdefault(v["id"], {"impact": v["impact"], "help": v["help"], "pages": 0, "nodes": 0})
            slot["pages"] += 1
            slot["nodes"] += v["nodes"]

    total_violations = sum(impact_count.values())

    # ---- report.md (เต็ม) ----
    md = ["# Accessibility Scan (axe-core)", ""]
    md.append(f"- หน้าที่สแกนสำเร็จ: **{scanned}** / ผิดพลาด: {errored}")
    md.append(f"- จำนวนจุดที่ผิดกฎรวม: **{total_violations}** "
              f"(critical {impact_count.get('critical',0)}, serious {impact_count.get('serious',0)}, "
              f"moderate {impact_count.get('moderate',0)}, minor {impact_count.get('minor',0)})")
    md.append("")
    md.append("## กฎที่ผิดบ่อยสุด (เรียงตามความรุนแรง)")
    md.append("| กฎ (axe rule) | ความรุนแรง | พบกี่หน้า | จำนวน element | คำอธิบาย |")
    md.append("|---|---|---|---|---|")
    for rid, s in sorted(by_rule.items(),
                         key=lambda kv: (IMPACT_ORDER.index(kv[1]["impact"]) if kv[1]["impact"] in IMPACT_ORDER else 9,
                                         -kv[1]["nodes"])):
        md.append(f"| `{rid}` | {s['impact']} | {s['pages']} | {s['nodes']} | {s['help']} |")
    md.append("")
    md.append("## รายหน้า")
    md.append("| หน้า | violations | หมายเหตุ |")
    md.append("|---|---|---|")
    for r in results:
        if r.get("ok"):
            md.append(f"| {r['url']} | {len(r['violations'])} | |")
        else:
            md.append(f"| {r['url']} | - | ⚠️ {r.get('error','สแกนไม่สำเร็จ')} |")

    # ---- summary.md (สั้น สำหรับ Teams) ----
    if total_violations == 0 and scanned > 0:
        summary = f"**♿ Accessibility:** ✅ ไม่พบปัญหา จาก {scanned} หน้า"
    else:
        top = sorted(by_rule.items(),
                     key=lambda kv: (IMPACT_ORDER.index(kv[1]["impact"]) if kv[1]["impact"] in IMPACT_ORDER else 9,
                                     -kv[1]["nodes"]))[:5]
        lines = [f"**♿ Accessibility:** พบ **{total_violations}** จุด จาก {scanned} หน้า "
                 f"(critical {impact_count.get('critical',0)}, serious {impact_count.get('serious',0)})"]
        for rid, s in top:
            lines.append(f"- `{rid}` ({s['impact']}) — {s['help']} · {s['nodes']} element / {s['pages']} หน้า")
        summary = "\n".join(lines)

    return "\n".join(md), summary


def main():
    _ensure_dirs()
    base = sc.get_base_url()
    if not base:
        _write_summary("**♿ Accessibility:** _ข้าม — หา BASE_URL ไม่เจอ_")
        return 0
    if not os.path.exists(AXE_JS):
        _write_summary("**♿ Accessibility:** _ข้าม — ไม่พบ scripts/vendor/axe.min.js_")
        return 0

    with open(AXE_JS, encoding="utf-8") as f:
        axe_src = f.read()

    urls = sc.seed_urls(base)[:MAX_PAGES]
    driver = None
    results = []
    try:
        driver = sc.build_driver()
        for url in urls:
            try:
                results.append({"url": url, "ok": True, "violations": scan_page(driver, axe_src, url)})
            except Exception as e:  # noqa: BLE001
                results.append({"url": url, "ok": False, "error": f"{type(e).__name__}: {e}"})
    except Exception as e:  # noqa: BLE001
        _write_summary(f"**♿ Accessibility:** _สแกนไม่สำเร็จ ({type(e).__name__}: {e})_")
        return 0
    finally:
        if driver:
            try:
                driver.quit()
            except Exception:  # noqa: BLE001
                pass

    report_md, summary = build_reports(results)
    with open(REPORT_MD, "w", encoding="utf-8") as f:
        f.write(report_md + "\n")
    with open(REPORT_JSON, "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=2)
    _write_summary(summary)
    return 0


if __name__ == "__main__":
    sys.exit(main())
