"""custom_library.py — pure-Python helpers for the WNW Robot Framework suite.

Ports three TypeScript modules from the original Playwright project so the Robot
keywords have an exact, test-covered foundation:

  * utils/dateHelpers.ts  -> Today Aria Label / Next Delivery Aria Label
                             (Asia/Bangkok calendar arithmetic for the datepicker)
  * utils/dataLoader.ts    -> Load Test Data / Load All Test Data
                             (reads resources/variables/test_data/*.json by key)
  * utils/urlHelpers.ts    -> Url Contains Pii / Get Pathname / Get Query Params

Plus small numeric/string helpers needed when translating Playwright assertions
(`price.toLocaleString('th-TH')`, parsing "฿1,646.97.-" into a float, etc.).

Exposed to Robot via the Robot keyword naming convention (snake_case -> "Space Case").
"""

from __future__ import annotations

import json
import os
import re
from datetime import date, datetime, timedelta, timezone

try:  # Python 3.9+
    from zoneinfo import ZoneInfo
    _BANGKOK = ZoneInfo("Asia/Bangkok")
    _UTC = ZoneInfo("UTC")
except Exception:  # pragma: no cover - fallback for minimal environments
    _BANGKOK = timezone(timedelta(hours=7))
    _UTC = timezone.utc

ROBOT_LIBRARY_SCOPE = "GLOBAL"

_DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "resources", "variables", "test_data")


# ───────────────────────────── date helpers (dateHelpers.ts) ──────────────────


def _ordinal(day: int) -> str:
    """Ordinal suffix for a day number (1->'1st', 2->'2nd', 11->'11th')."""
    mod100 = day % 100
    if 11 <= mod100 <= 13:
        return f"{day}th"
    return {1: f"{day}st", 2: f"{day}nd", 3: f"{day}rd"}.get(day % 10, f"{day}th")


def _format_aria_label(d: date) -> str:
    """Build the calendar day-cell aria-label in English locale.

    Format: "Choose <Weekday>, <Month> <Day-ordinal>, <Year>"
    Example: "Choose Saturday, June 20th, 2026"
    """
    weekday = d.strftime("%A")
    month = d.strftime("%B")
    return f"Choose {weekday}, {month} {_ordinal(d.day)}, {d.year}"


def _parse_now(now):
    """Accept None | ISO-8601 string | datetime and return an aware datetime."""
    if now is None or now == "":
        return datetime.now(_UTC)
    if isinstance(now, datetime):
        dt = now
    else:
        s = str(now).strip().replace("Z", "+00:00")
        dt = datetime.fromisoformat(s)
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=_UTC)
    return dt


def _bangkok_today(now=None) -> date:
    """Return the current calendar date in Asia/Bangkok regardless of OS timezone."""
    dt = _parse_now(now).astimezone(_BANGKOK)
    return date(dt.year, dt.month, dt.day)


def today_aria_label(now=None) -> str:
    """Aria-label for *today's* calendar cell (Bangkok). Used by the payment-date
    picker ("วันที่โอน" / transfer date is today)."""
    return _format_aria_label(_bangkok_today(now))


def next_delivery_aria_label(offset_days=4, now=None) -> str:
    """Aria-label for the next delivery day: the first Saturday on/after
    (today + offset_days), anchored to the Bangkok calendar."""
    offset_days = int(offset_days)
    today = _bangkok_today(now)
    earliest = today + timedelta(days=offset_days)
    # Python weekday(): Mon=0 .. Sun=6.  JS getDay(): Sun=0 .. Sat=6.
    # Saturday in JS = 6 -> daysUntilSat = (6 - jsDay) % 7. Convert via isoweekday/weekday.
    js_day = (earliest.weekday() + 1) % 7  # Mon0->1 ... Sun6->0  => Sun=0..Sat=6
    days_until_sat = (6 - js_day) % 7
    target = earliest + timedelta(days=days_until_sat)
    return _format_aria_label(target)


# ───────────────────────────── data loader (dataLoader.ts) ────────────────────


def _load_json(filename: str):
    path = os.path.join(_DATA_DIR, filename)
    if not os.path.exists(path):
        raise AssertionError(f"Test data file not found: {path}")
    with open(path, "r", encoding="utf-8") as fh:
        return json.load(fh)


# entity name -> json filename (mirrors dataLoader.ts public API)
_ENTITY_FILES = {
    "product": "products.json",
    "products": "products.json",
    "category": "categories.json",
    "categories": "categories.json",
    "customer": "customers.json",
    "customers": "customers.json",
    "recipient": "recipients.json",
    "recipients": "recipients.json",
    "temple": "temples.json",
    "temples": "temples.json",
    "payment": "payments.json",
    "payments": "payments.json",
    "coupon": "coupons.json",
    "coupons": "coupons.json",
    "card": "cards.json",
    "cards": "cards.json",
}


def load_all_test_data(entity: str):
    """Return the full list of records for an entity (e.g. 'products')."""
    key = entity.strip().lower()
    if key not in _ENTITY_FILES:
        raise AssertionError(f"Unknown test-data entity: {entity}")
    return _load_json(_ENTITY_FILES[key])


def load_test_data(entity: str, key: str):
    """Return a single record by its 'key' field (mirrors dataLoader.product('h014'))."""
    items = load_all_test_data(entity)
    for item in items:
        if item.get("key") == key:
            return item
    raise AssertionError(f'Test data key "{key}" not found in "{entity}" dataset.')


# ───────────────────────────── url helpers (urlHelpers.ts) ────────────────────


def url_contains_pii(url: str, *pii_values) -> bool:
    """True if any PII value appears in the (decoded) URL. D-02 regression guard."""
    from urllib.parse import unquote

    # Allow a single list arg or varargs.
    if len(pii_values) == 1 and isinstance(pii_values[0], (list, tuple)):
        pii_values = pii_values[0]
    decoded = unquote(url)
    return any(str(p) in decoded for p in pii_values)


def get_pathname(url: str) -> str:
    """Extract the pathname from a full URL or a relative path."""
    from urllib.parse import urlparse

    try:
        parsed = urlparse(url)
        if parsed.scheme:
            return parsed.path
    except Exception:
        pass
    q = url.find("?")
    return url[:q] if q != -1 else url


def decode_url(url: str) -> str:
    """percent-decode a URL (for Thai-path assertions)."""
    from urllib.parse import unquote

    return unquote(url)


# ───────────────────────────── numeric / string helpers ──────────────────────


def thai_number_format(value) -> str:
    """Equivalent of JS Number.toLocaleString('th-TH') for integers/whole amounts:
    group thousands with commas. 1599 -> '1,599'."""
    num = float(value)
    if num == int(num):
        return f"{int(num):,}"
    return f"{num:,}"


def parse_amount(text: str):
    """Parse the first numeric (with optional decimals) value out of a price string,
    stripping ฿, THB, commas, spaces, and a trailing '.-'.

    "฿1,646.97.-" -> 1646.97 ; "฿ 2,899.-" -> 2899.0 ; returns None if no number.
    Mirrors getGrandTotalAmount()/getChargeAmount()/getPrice() parsing.
    """
    if text is None:
        return None
    cleaned = str(text).replace(",", "")
    match = re.search(r"\d+(?:\.\d+)?", cleaned)
    return float(match.group(0)) if match else None


def parse_int_amount(text: str) -> int:
    """Parse the first integer group from a string (getPrice() semantics): '฿ 1,599.-' -> 1599."""
    if text is None:
        return 0
    match = re.search(r"[\d,]+", str(text))
    return int(match.group(0).replace(",", "")) if match else 0


def extract_order_number(text: str) -> str:
    """Pull the 'O-#########' order code out of a label string; fall back to trimmed text."""
    match = re.search(r"O-\d+", text or "")
    return match.group(0) if match else (text or "").strip()


def extract_payment_hash(url: str) -> str:
    """Extract <hash> from a /payment/<hash>/ URL (placeOrder() return value)."""
    match = re.search(r"/payment/([^/]+)/", url or "")
    return match.group(1) if match else ""
