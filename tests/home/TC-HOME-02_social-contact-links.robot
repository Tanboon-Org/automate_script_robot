*** Settings ***
Documentation     TC-HOME-02 — หน้าแรกมีช่องทางติดต่อ/โซเชียล: LINE + โทร + โซเชียล (facebook).
...               Smoke. (คลิกแบนเนอร์→collection เป็น interaction เก็บภายหลัง — รอบนี้ตรวจลิงก์)
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:home    group:home

*** Test Cases ***
TC-HOME-02 Home exposes LINE, phone and social links
    [Documentation]    P3 — หน้าแรก → มีลิงก์ LINE(/line/) + tel: + โซเชียล (facebook).
    [Tags]    TC-HOME-02
    Dismiss Cookie
    Assert Home Loaded
    Page Should Have Link To    /line/
    Page Should Have Link To    tel:
    Page Should Have Link To    facebook
