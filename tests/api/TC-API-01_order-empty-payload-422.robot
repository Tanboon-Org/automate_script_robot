*** Settings ***
Documentation     TC-API-01 — POST /api/order ด้วย payload ว่าง → proxy คืน 422 {error:true}
...               แบบมีโครงสร้าง (ไม่ crash 500). ทดสอบ error path ของ Next.js proxy
...               (pages/api/order.ts catch). ไม่สร้าง order (ถูก reject).
Library           api_library.py
Force Tags        feature:api    group:order-api

*** Test Cases ***
TC-API-01 Order API rejects an empty payload with a structured 422
    [Documentation]    P1 — API Error. payload ว่าง → 422 + error:true + ข้อความ validation.
    [Tags]    TC-API-01
    ${resp}=    API Post Json    ${BASE_URL}/api/order    ${EMPTY}
    Should Be Equal As Integers    ${resp}[status]    422
    Should Be Equal    ${resp}[json][error]    ${True}
    Should Contain    ${resp}[json][message]    จำเป็นต้องระบุ
