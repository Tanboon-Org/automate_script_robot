*** Settings ***
Documentation     TC-CT-03 — หน้า /ลูกค้าองค์กร มีช่องทางติดต่อ B2B (LINE B2B / โทร) + gallery รูป.
...               Functional-smoke: มีลิงก์ /lineb2b/ + tel: + รูปในหน้า (gallery).
Resource          ../../resources/keywords/suite_helpers.resource
Test Setup        Open WNW Browser
Test Teardown     Close WNW Browser
Test Tags         feature:contact    group:corporate

*** Variables ***
${CORPORATE_PATH}    /ลูกค้าองค์กร/

*** Test Cases ***
TC-CT-03 Corporate page has B2B contact links and a gallery
    [Documentation]    P3 — เปิดหน้าลูกค้าองค์กร → มีลิงก์ LINE B2B + โทร + รูป gallery.
    [Tags]    TC-CT-03
    Assert Content Page Loads    ${CORPORATE_PATH}
    Page Should Have Link To    /lineb2b/
    Page Should Have Link To    tel:
    Assert Image Count At Least    5
