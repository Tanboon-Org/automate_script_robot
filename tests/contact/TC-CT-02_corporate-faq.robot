*** Settings ***
Documentation     TC-CT-02 — หน้า /ลูกค้าองค์กร แสดง FAQ + ข้อมูลเครดิต/ใบกำกับภาษี.
...               Functional-smoke: หน้าโหลด + มีหัวข้อ "คำถามที่พบบ่อย" + ข้อความ เครดิต/ใบกำกับ.
...               (accordion toggle ระดับ interaction เก็บเป็น smoke)
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:contact    group:corporate

*** Variables ***
${CORPORATE_PATH}    /ลูกค้าองค์กร/

*** Test Cases ***
TC-CT-02 Corporate page shows FAQ and credit/invoice info
    [Documentation]    P3 — เปิดหน้าลูกค้าองค์กร → มี FAQ + ข้อมูลเครดิต/ใบกำกับภาษี.
    [Tags]    TC-CT-02
    Assert Content Page Loads    ${CORPORATE_PATH}
    Wait Until Page Contains    คำถามที่พบบ่อย    ${TIMEOUTS}[DEFAULT]
    Page Should Contain    เครดิต
    Page Should Contain    ใบกำกับ
