"""api_library — thin Robot Framework wrapper over `requests` for API-level tests.

Why not robotframework-requests? It is not installed in this environment and pulling
it in risks a urllib3/chardet version clash. Plain `requests` ships already, so we wrap
it in a few keywords that return a Robot-friendly dict ({status, json, text}).

Usage (Robot):
    Library    api_library.py
    ${resp}=    API Post Json    ${BASE_URL}/api/order    ${payload}
    Should Be Equal As Integers    ${resp}[status]    422
    Should Be Equal    ${resp}[json][error]    ${True}

SAFETY: only use for endpoints/payloads that are REJECTED (no order is created). The
order proxy requires server-stamped fields (from_ip_address/user_device/...), so a
malformed/empty payload always 4xx/5xx — it can never create a real order.
"""

import warnings

import requests

# Quiet the urllib3/chardet mismatch + 'strict' FutureWarning noise in this env.
warnings.filterwarnings("ignore")
try:
    requests.packages.urllib3.disable_warnings()
except Exception:
    pass


class api_library:
    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def _wrap(self, resp):
        try:
            body = resp.json()
        except ValueError:
            body = {}
        return {"status": resp.status_code, "json": body, "text": resp.text}

    def api_post_json(self, url, payload=None, timeout=30):
        """POST `payload` (a dict, or None for {}) as JSON; return {status, json, text}."""
        resp = requests.post(url, json=(payload or {}), timeout=float(timeout))
        return self._wrap(resp)

    def api_get(self, url, timeout=30):
        """GET `url`; return {status, json, text}."""
        resp = requests.get(url, timeout=float(timeout))
        return self._wrap(resp)
