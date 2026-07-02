*** Settings ***
Documentation     กลุ่ม LINE landing routes — แต่ละ route ตั้ง cookie ประจำช่องทางของตัวเอง
...               และ cookie ทั้ง 3 ไม่ชนกัน. Verified live 2026-07-02:
...               /line→user_id, /lineb2b→user_id_b2b, /line-event→user_id_event.
...               (TC-LINE-03 openline redirect → external line.me ยังไม่ทำ — ออกนอกโดเมน)
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:line    group:line

*** Test Cases ***
TC-LINE-01 /line sets the user_id cookie
    [Documentation]    P2 — เปิด /line → ตั้ง cookie user_id + หน้าโหลด.
    [Tags]    TC-LINE-01
    Delete All Cookies
    Open Route And Settle    /line/
    Cookie Should Be Set    user_id

TC-LINE-02 user_id cookie persists across navigation
    [Documentation]    P2 — ได้ cookie จาก /line แล้ว navigate ต่อ → cookie ยังอยู่ค่าเดิม.
    [Tags]    TC-LINE-02
    Delete All Cookies
    Open Route And Settle    /line/
    ${first}=    Cookie Should Be Set    user_id
    Go To Route    ${ROUTES}[HOME]
    Wait For Page Settle
    ${again}=    Cookie Should Be Set    user_id
    Should Be Equal    ${first}    ${again}    user_id ควรคงค่าเดิมหลัง navigate (persist)

TC-LINE-04 /lineb2b sets a separate user_id_b2b cookie
    [Documentation]    P2 — เปิด /lineb2b → ตั้ง cookie user_id_b2b (คนละตัวกับ user_id).
    [Tags]    TC-LINE-04
    Delete All Cookies
    Open Route And Settle    /lineb2b/
    Cookie Should Be Set    user_id_b2b

TC-LINE-05 /line-event sets a separate user_id_event cookie
    [Documentation]    P2 — เปิด /line-event → ตั้ง cookie user_id_event.
    [Tags]    TC-LINE-05
    Delete All Cookies
    Open Route And Settle    /line-event/
    Cookie Should Be Set    user_id_event

TC-LINE-06 The three LINE cookies coexist without collision
    [Documentation]    P2 — เปิดครบ 3 route → cookie ทั้งสาม (user_id / _b2b / _event) อยู่พร้อมกัน
    ...    และค่าไม่ซ้ำกัน.
    [Tags]    TC-LINE-06
    Delete All Cookies
    Open Route And Settle    /line/
    Open Route And Settle    /lineb2b/
    Open Route And Settle    /line-event/
    ${a}=    Cookie Should Be Set    user_id
    ${b}=    Cookie Should Be Set    user_id_b2b
    ${c}=    Cookie Should Be Set    user_id_event
    Should Be True    len({'${a}','${b}','${c}'}) == 3    cookie ทั้งสามช่องทางต้องมีค่าไม่ซ้ำกัน
