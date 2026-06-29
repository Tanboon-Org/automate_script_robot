"""ScreenshotListener — Robot Framework listener (API v3).

ถ่าย screenshot อัตโนมัติหลังทุก keyword ที่แตะ browser (ทุก "การเคลื่อนไหว")
เพื่อให้ log.html แสดงสถานะหน้าจอทีละ step ตั้งแต่ต้นจนจบของทุก test case.

วิธีใช้ (เพิ่ม --listener เข้าไปในคำสั่ง robot):
    robot --listener listeners/ScreenshotListener.py \
          --pythonpath libraries \
          --variablefile resources/variables/env_staging.yaml \
          --outputdir results tests

พฤติกรรม:
  * ถ่ายเฉพาะ keyword ของ SeleniumLibrary (click / input / go to / select / get / assert ...)
    ซึ่งคือ keyword ที่มีผลกับหน้าจอจริง — keyword พวก Load Test Data / Evaluate / unit tests
    (ไม่มี browser) จะถูกข้ามอัตโนมัติ
  * ไม่ถ่ายซ้ำตอน keyword 'Capture Page Screenshot' เอง (กัน recursion)
  * ถ้ายังไม่ได้เปิด browser หรือถ่ายไม่สำเร็จ จะข้ามเงียบ ๆ ไม่ทำให้เทสล้ม
  * รูปถูกฝังเป็น base64 ลง log.html โดยตรง (EMBED) → log.html เป็นไฟล์เดียวจบ
    เปิดดูที่ไหนก็เห็นรูป ไม่ต้องพึ่งไฟล์ .png ข้างนอก (ไม่ broken image)
    ดูได้ใน log.html โดยกด + ขยาย keyword ของ SeleniumLibrary — ไม่ใช่ report.html

ปรับลดจำนวนรูป: ตั้ง env var  SHOT_MODE=action  เพื่อถ่ายเฉพาะ keyword ที่ "ขยับ" จริง
(click/input/select/submit/go to/open/clear/press/scroll/switch/reload/choose/drag/upload)
ไม่ถ่าย getter/assertion. ค่า default = ทุก keyword ของ SeleniumLibrary.
"""

from __future__ import annotations

import os

from robot.libraries.BuiltIn import BuiltIn

# keyword ที่ไม่ถ่าย (กัน recursion / ไม่มีประโยชน์)
_SKIP = {"capture page screenshot", "capture element screenshot"}

# คำขึ้นต้นของ keyword ที่ถือว่าเป็น "การเคลื่อนไหว" จริง (ใช้เมื่อ SHOT_MODE=action)
_ACTION_PREFIXES = (
    "click", "input", "select", "submit", "go to", "open browser", "open ",
    "clear", "press", "scroll", "switch window", "switch ", "reload",
    "choose", "drag", "execute javascript", "double click", "mouse",
    "set focus", "check ", "uncheck", "choose file",
)


class ScreenshotListener:
    ROBOT_LISTENER_API_VERSION = 3

    def __init__(self):
        # "action" = เฉพาะ keyword ที่ขยับหน้าจอ, อย่างอื่น = ทุก keyword ของ SeleniumLibrary
        self._action_only = os.environ.get("SHOT_MODE", "all").lower() == "action"

    def end_keyword(self, data, result):
        if getattr(result, "libname", None) != "SeleniumLibrary":
            return
        kwname = (getattr(result, "kwname", "") or "")
        low = kwname.lower()
        if low in _SKIP:
            return
        if self._action_only and not low.startswith(_ACTION_PREFIXES):
            return
        try:
            sl = BuiltIn().get_library_instance("SeleniumLibrary")
            # "EMBED" = ฝังรูปเป็น base64 ลง log.html โดยตรง → log.html เป็นไฟล์เดียวจบ
            # เปิดที่ไหนก็เห็นรูป ไม่ต้องพึ่งไฟล์ .png ข้างนอก (ไม่ broken image)
            sl.capture_page_screenshot("EMBED")
        except Exception:
            # ไม่มี browser เปิดอยู่ / ถ่ายไม่ได้ — ข้าม ไม่ให้กระทบผลเทส
            pass
