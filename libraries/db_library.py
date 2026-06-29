"""db_library.py — placeholder database-access library.

The WNW application under test exposes NO direct database access to the test
harness, and the original Playwright suite performed zero DB verification — every
assertion is made through the UI / order-tracking pages. This stub is kept only to
satisfy the canonical POM project layout (libraries/db_library.py) and to give a
ready home for SQL-backed verification keywords should a future phase gain DB access
(e.g. asserting an order row, a payment-notification record, or cleaning up test data).

To implement later: connect with a driver such as DatabaseLibrary / pymysql, expose
keywords like `Connect To App Db`, `Order Row Should Exist`, `Cleanup Test Orders`.
Until then every keyword raises a clear NotImplementedError so accidental use fails
loudly instead of silently passing.
"""

from __future__ import annotations

ROBOT_LIBRARY_SCOPE = "GLOBAL"

_NOT_WIRED = (
    "db_library is an intentional stub — the WNW suite has no database access. "
    "Wire up a real connection (DatabaseLibrary/pymysql) before using DB keywords."
)


def connect_to_app_db(*args, **kwargs):
    """Placeholder — open a DB connection. Not wired up."""
    raise NotImplementedError(_NOT_WIRED)


def order_row_should_exist(order_number: str):
    """Placeholder — assert an order row exists for the given order number."""
    raise NotImplementedError(_NOT_WIRED)


def cleanup_test_orders(*args, **kwargs):
    """Placeholder — remove orders created by automation (TEST-marked rows)."""
    raise NotImplementedError(_NOT_WIRED)
