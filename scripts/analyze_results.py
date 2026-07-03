#!/usr/bin/env python3
"""อ่าน results/output.xml แล้วให้ Google Gemini วิเคราะห์ผลรัน Robot Framework

รันบน GitHub Actions คั่นระหว่าง "Run tests" กับ "Notify MS Teams":
- ดึงสถิติรวม + รายละเอียดเทสที่ fail + สรุปผ่าน/ไม่ผ่านรายโมดูล
- ส่งเฉพาะข้อมูลย่อ (ไม่ส่ง output.xml ทั้งไฟล์) ให้ Gemini เพื่อคุมโควตา
- เขียนผลวิเคราะห์ (ภาษาไทย) ลง results/ai_analysis.md ให้ step ถัดไปอ่านไปใส่การ์ด Teams

ใช้ Gemini free tier (GEMINI_API_KEY) — สมัครฟรีที่ https://aistudio.google.com/apikey ไม่ต้องผูกบัตร
ออกแบบให้ "ไม่ทำ pipeline พัง": ไม่มี key / เรียก API ไม่สำเร็จ -> เขียนหมายเหตุแล้ว exit 0
"""

import os
import sys
import xml.etree.ElementTree as ET

OUTPUT_XML = os.environ.get("ROBOT_OUTPUT", "results/output.xml")
ANALYSIS_OUT = os.environ.get("AI_ANALYSIS_OUT", "results/ai_analysis.md")
MODEL = os.environ.get("AI_MODEL", "gemini-2.0-flash")   # free tier
MAX_MSG_LEN = 600      # ตัด error message ยาวๆ กันเปลืองโควตา
MAX_FAILS = 40         # กันเคสหลุดผิดปกติจน prompt บวม


def write_out(text: str) -> None:
    os.makedirs(os.path.dirname(ANALYSIS_OUT) or ".", exist_ok=True)
    with open(ANALYSIS_OUT, "w", encoding="utf-8") as f:
        f.write(text.strip() + "\n")
    print(text)


def top_suite_name(test_elem, id_to_name):
    """หาชื่อ suite ระดับบนสุด (โฟลเดอร์ใต้ tests/) ของเทส จาก test id เช่น s1-s3-t2"""
    tid = test_elem.get("id", "")
    parts = tid.split("-")
    # parts[0]='s1' คือ root suite; ระดับโมดูลคือ s1-s2
    if len(parts) >= 2:
        return id_to_name.get(f"{parts[0]}-{parts[1]}", "?")
    return id_to_name.get(parts[0], "?") if parts else "?"


def collect(root):
    id_to_name = {s.get("id"): s.get("name") for s in root.iter("suite")}

    stat = root.find("./statistics/total/stat")
    passed = int(stat.get("pass", 0)) if stat is not None else 0
    failed = int(stat.get("fail", 0)) if stat is not None else 0
    skipped = int(stat.get("skip", 0)) if stat is not None else 0

    per_module = {}   # module -> [pass, fail, skip]
    fails = []
    for test in root.iter("test"):
        st = test.find("status")
        if st is None:
            continue
        status = st.get("status")
        module = top_suite_name(test, id_to_name)
        counts = per_module.setdefault(module, [0, 0, 0])
        if status == "PASS":
            counts[0] += 1
        elif status == "FAIL":
            counts[1] += 1
            msg = (st.text or "").strip().replace("\n", " ")
            if len(msg) > MAX_MSG_LEN:
                msg = msg[:MAX_MSG_LEN] + " …(ตัด)"
            fails.append({"name": test.get("name"), "module": module, "msg": msg})
        elif status == "SKIP":
            counts[2] += 1

    return passed, failed, skipped, per_module, fails


def build_prompt(passed, failed, skipped, per_module, fails):
    lines = [f"สรุปรวม: PASS {passed} / FAIL {failed} / SKIP {skipped}", "", "ผลรายโมดูล (โฟลเดอร์เทส):"]
    for mod in sorted(per_module):
        p, f, s = per_module[mod]
        lines.append(f"- {mod}: pass {p}, fail {f}, skip {s}")

    lines.append("")
    if fails:
        lines.append(f"เทสที่ FAIL ({len(fails)} เคส) — ชื่อ | โมดูล | error:")
        for i, ftest in enumerate(fails[:MAX_FAILS], 1):
            lines.append(f"{i}. {ftest['name']} | {ftest['module']} | {ftest['msg']}")
        if len(fails) > MAX_FAILS:
            lines.append(f"… และอีก {len(fails) - MAX_FAILS} เคส")
    else:
        lines.append("ไม่มีเทส FAIL")

    return "\n".join(lines)


SYSTEM = (
    "คุณเป็น QA engineer ที่ช่วยวิเคราะห์ผลรัน Robot Framework E2E (staging) ของเว็บ e-commerce พวงหรีด "
    "ตอบเป็นภาษาไทย กระชับ อ่านง่ายบนการ์ด Microsoft Teams (ใช้ markdown ได้: **ตัวหนา**, bullet). "
    "โครงสร้างคำตอบ:\n"
    "1) สรุปภาพรวม 1 บรรทัด (ผ่านกี่โมดูล เน้นว่ามีปัญหาตรงไหน)\n"
    "2) วิเคราะห์เทสที่ fail: จัดกลุ่มตามสาเหตุที่น่าจะเป็น และเดาประเภท "
    "(บั๊กจริงในระบบ / เทสเปราะ-flaky / staging มีปัญหา / ข้อมูลทดสอบ) พร้อมเหตุผลสั้นๆ\n"
    "3) ข้อเสนอแนะขั้นถัดไป 1-3 ข้อ\n"
    "ห้ามแต่งข้อมูลเกินจากที่ให้มา ถ้าไม่มี fail ให้บอกสั้นๆ ว่าผ่านหมดและโมดูลไหนเด่น "
    "รวมทั้งหมดไม่ควรเกิน ~1500 ตัวอักษร"
)


def is_quota_error(e: Exception) -> bool:
    """โควตา Gemini free tier หมด -> HTTP 429 / RESOURCE_EXHAUSTED

    google-genai โยน APIError ที่มี .code == 429; เผื่อ SDK เวอร์ชันอื่นด้วยการ
    เช็กข้อความประกอบ (429 / RESOURCE_EXHAUSTED / quota / rate limit)
    """
    if getattr(e, "code", None) == 429 or getattr(e, "status_code", None) == 429:
        return True
    text = f"{getattr(e, 'status', '')} {e}".lower()
    return any(k in text for k in ("resource_exhausted", "429", "quota", "rate limit", "ratelimit"))


def analyze(prompt: str) -> str:
    from google import genai
    from google.genai import types

    client = genai.Client(api_key=os.environ["GEMINI_API_KEY"])
    resp = client.models.generate_content(
        model=MODEL,
        contents=f"นี่คือผลรันล่าสุด วิเคราะห์ให้หน่อย:\n\n{prompt}",
        config=types.GenerateContentConfig(
            system_instruction=SYSTEM,
            max_output_tokens=1500,
            temperature=0.3,
        ),
    )
    return (resp.text or "").strip()


def main() -> int:
    if not os.path.exists(OUTPUT_XML):
        write_out("_ไม่พบ results/output.xml — ข้ามการวิเคราะห์ด้วย AI (เทสอาจไม่ได้รัน)_")
        return 0

    try:
        root = ET.parse(OUTPUT_XML).getroot()
        passed, failed, skipped, per_module, fails = collect(root)
    except Exception as e:  # noqa: BLE001
        write_out(f"_อ่าน output.xml ไม่สำเร็จ ({e}) — ข้ามการวิเคราะห์ด้วย AI_")
        return 0

    if not os.environ.get("GEMINI_API_KEY"):
        write_out("_ไม่ได้ตั้ง GEMINI_API_KEY — ข้ามการวิเคราะห์ด้วย AI (ตั้ง secret เพื่อเปิดใช้งาน)_")
        return 0

    prompt = build_prompt(passed, failed, skipped, per_module, fails)
    try:
        analysis = analyze(prompt)
        write_out(analysis or "_AI ไม่ได้ส่งข้อความกลับ (อาจโดน safety filter)_")
    except Exception as e:  # noqa: BLE001
        # log สาเหตุจริงลง Actions log เสมอ (การ์ด Teams เก็บข้อความสั้น)
        print(f"[ai-analyze] ERROR {type(e).__name__}: {e}", file=sys.stderr)
        if is_quota_error(e):
            write_out(
                "⚠️ **Gemini free tier รอบนี้ติดโควตา/เรตลิมิต** — ข้ามการวิเคราะห์ด้วย AI รอบนี้ "
                "(เต็มต่อนาทีจะคลายใน ~1 นาที, เต็มรายวันรีเซ็ตเที่ยงคืน Pacific — "
                "ดูสาเหตุจริงใน Actions log ที่ step ‘AI analyze results’)"
            )
        else:
            write_out(f"_เรียก AI วิเคราะห์ไม่สำเร็จ ({type(e).__name__}: {e}) — ข้ามไปก่อน (ดู Actions log)_")
    return 0


if __name__ == "__main__":
    sys.exit(main())
