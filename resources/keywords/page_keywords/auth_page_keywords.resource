*** Settings ***
Documentation    Account / Auth actions + assertions (port of LoginForm.tsx / RegisterForm.tsx /
...              AuthModal.tsx / AuthTab.tsx). Pulls in common keywords + auth locators.
Resource         ../common_keywords.resource
Resource         ../../locators/auth_page_locators.resource

*** Keywords ***
# ───────────────────────────── modal / tab control ─────────────────────────────
Open Auth Modal
    [Documentation]    Click the header "สมัครสมาชิก / เข้าสู่ระบบ" trigger and wait for the dialog.
    ...    No-op if the dialog is already open.
    ${already}=    Run Keyword And Return Status    Element Should Be Visible    ${AUTH_DIALOG}
    IF    not ${already}
        Wait Until Any Element Visible    ${AUTH_OPEN_BTN}    ${TIMEOUTS}[DEFAULT]
        Click First Visible    ${AUTH_OPEN_BTN}
    END
    Wait Until Element Is Visible    ${AUTH_DIALOG}    ${TIMEOUTS}[DEFAULT]
    Wait Until Element Is Visible    ${AUTH_EMAIL}    ${TIMEOUTS}[DEFAULT]

Switch To Login Tab
    [Documentation]    Login tab is selected by default; click it to be explicit.
    Click Element Safe    ${AUTH_TAB_LOGIN}
    Wait Until Element Is Visible    ${AUTH_SUBMIT}    ${TIMEOUTS}[DEFAULT]

Switch To Register Tab
    [Documentation]    Open the register panel and wait for the privacy checkbox to mount.
    Click Element Safe    ${AUTH_TAB_REGISTER}
    Wait Until Element Is Visible    ${AUTH_PRIVACY}    ${TIMEOUTS}[DEFAULT]

Click First Visible
    [Documentation]    Click the first VISIBLE element matched (handles desktop+mobile duplicates).
    [Arguments]    ${locator}
    ${elements}=    Get WebElements    ${locator}
    FOR    ${el}    IN    @{elements}
        ${visible}=    Run Keyword And Return Status    Element Should Be Visible    ${el}
        IF    ${visible}
            Click Element    ${el}
            RETURN
        END
    END
    Fail    No visible element matched ${locator}

# ───────────────────────────── login ─────────────────────────────
Fill Login Form
    [Documentation]    Type email + password into the (mounted) login form.
    [Arguments]    ${email}    ${password}
    Input Text Reliably    ${AUTH_EMAIL}       ${email}
    Input Text Reliably    ${AUTH_PASSWORD}    ${password}

Set Remember Me
    [Documentation]    Tick/untick the "จำฉันไว้" checkbox to the desired state.
    [Arguments]    ${enabled}=${TRUE}
    ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${AUTH_REMEMBER}
    IF    ${enabled} and not ${checked}
        Click Element Safe    ${AUTH_REMEMBER}
    ELSE IF    not ${enabled} and ${checked}
        Click Element Safe    ${AUTH_REMEMBER}
    END

Submit Auth Form
    [Documentation]    Submit whichever auth form is mounted (login or register).
    Click Element Safe    ${AUTH_SUBMIT}

Login With
    [Documentation]    Composite: open modal → login tab → fill → (remember) → submit.
    [Arguments]    ${email}    ${password}    ${remember}=${FALSE}
    Open Auth Modal
    Switch To Login Tab
    Fill Login Form    ${email}    ${password}
    Set Remember Me    ${remember}
    Submit Auth Form

Assert Login Succeeded
    [Documentation]    Success modal "เข้าสู่ระบบสำเร็จ" + redirect to /user-infos.
    Wait Until Page Contains    ${MSG_LOGIN_SUCCESS}    ${TIMEOUTS}[NAVIGATION]
    Wait Until Url Contains Fragment    /user-infos

Assert Login Invalid Credentials
    Wait Until Page Contains    ${MSG_LOGIN_INVALID}    ${TIMEOUTS}[DEFAULT]

Assert Login Unverified Email
    Wait Until Page Contains    ${MSG_LOGIN_UNVERIFIED}    ${TIMEOUTS}[DEFAULT]

Assert Login Required Error
    Wait Until Page Contains    ${MSG_LOGIN_REQUIRED}    ${TIMEOUTS}[DEFAULT]

# ───────────────────────────── register ─────────────────────────────
Fill Register Form
    [Documentation]    Type email + password and optionally accept the privacy policy.
    [Arguments]    ${email}    ${password}    ${accept_privacy}=${TRUE}
    Input Text Reliably    ${AUTH_EMAIL}       ${email}
    Input Text Reliably    ${AUTH_PASSWORD}    ${password}
    IF    ${accept_privacy}
        Accept Privacy Policy
    END

Accept Privacy Policy
    ${checked}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${AUTH_PRIVACY}
    IF    not ${checked}    Click Element Safe    ${AUTH_PRIVACY}

Submit Register Form
    Click Element Safe    ${AUTH_SUBMIT}

Register With
    [Documentation]    Composite: open modal → register tab → fill → submit.
    [Arguments]    ${email}    ${password}    ${accept_privacy}=${TRUE}
    Open Auth Modal
    Switch To Register Tab
    Fill Register Form    ${email}    ${password}    ${accept_privacy}
    Submit Register Form

Assert Register Succeeded
    Wait Until Page Contains    ${MSG_REGISTER_SUCCESS}     ${TIMEOUTS}[NAVIGATION]
    Wait Until Page Contains    ${MSG_REGISTER_CHECK_MAIL}  ${TIMEOUTS}[DEFAULT]

Assert Inline Error Contains
    [Documentation]    A red validation message inside the dialog contains the given text.
    [Arguments]    ${text}
    Wait Until Element Is Visible    ${AUTH_INLINE_ERROR}    ${TIMEOUTS}[DEFAULT]
    Wait Until Element Contains    ${AUTH_INLINE_ERROR}    ${text}    ${TIMEOUTS}[DEFAULT]

Toggle Password Visibility
    Click Element Safe    ${AUTH_PWD_TOGGLE}

Assert Password Field Type
    [Documentation]    Verify the password input's type attribute (password|text).
    [Arguments]    ${expected}
    ${type}=    Get Element Attribute    ${AUTH_PASSWORD}    type
    Should Be Equal    ${type}    ${expected}

# ───────────────────────────── storage helpers ─────────────────────────────
Get Local Storage Item
    [Arguments]    ${key}
    ${value}=    Execute JavaScript    return window.localStorage.getItem(arguments[0]);    ARGUMENTS    ${key}
    RETURN    ${value}

Assert Access Token In Local Storage
    [Documentation]    Remember-Me ON → token persisted in localStorage.
    ${token}=    Get Local Storage Item    access_token
    Should Not Be Empty    ${token}    access_token missing from localStorage

Assert Access Token In Session Storage Only
    [Documentation]    Remember-Me OFF → token in sessionStorage, NOT localStorage.
    ${session}=    Get Session Storage Item    access_token
    ${local}=    Get Local Storage Item    access_token
    Should Not Be Empty    ${session}    access_token missing from sessionStorage
    Should Be Empty    ${local}    access_token should NOT be in localStorage when Remember Me is off

# ───────────────────────────── data helpers ─────────────────────────────
Generate Unique Email
    [Documentation]    Build a fresh, never-registered email for register tests.
    [Arguments]    ${prefix}    ${domain}
    ${ts}=    Get Time    epoch
    RETURN    ${prefix}+${ts}@${domain}

# ───────────────────────────── /user-infos (A6/A7) ─────────────────────────────
Open User Infos Page
    [Documentation]    Navigate directly to the protected /user-infos/ route.
    Go To Route    ${ROUTES}[USER_INFOS]
    Wait For Page Settle

Assert User Infos Not Accessible As Guest
    [Documentation]    Guest on /user-infos: no account form renders ({isAuth && ...} is empty),
    ...    so there is no "Log Out" and the header still shows the login trigger.
    Wait Until Any Element Visible    ${AUTH_OPEN_BTN}    ${TIMEOUTS}[DEFAULT]
    Page Should Not Contain Element    ${USER_LOGOUT_BTN}

Assert User Email Prefilled
    [Documentation]    The personal-info email field is prefilled from the logged-in user.
    [Arguments]    ${email}
    ${el}=    Get First Visible Element    ${USER_EMAIL_INPUT}
    ${value}=    Get Value    ${el}
    Should Be Equal    ${value}    ${email}    email field ควร prefill เป็น ${email}

Assert User Email Field Read Only
    [Documentation]    The email field is disabled (cannot be edited).
    ${el}=    Get First Visible Element    ${USER_EMAIL_INPUT}
    Element Should Be Disabled    ${el}

Logout
    [Documentation]    Click "Log Out"; logged-out state = login trigger back, no "Log Out".
    Click First Visible Element    ${USER_LOGOUT_BTN}
    Wait Until Any Element Visible    ${AUTH_OPEN_BTN}    ${TIMEOUTS}[NAVIGATION]
    Page Should Not Contain Element    ${USER_LOGOUT_BTN}

Open Orders Tab
    [Documentation]    Switch to the "รายการสั่งซื้อ" tab in /user-infos (OrdersSection).
    Click First Visible Element    ${USER_ORDERS_TAB}

Open Personal Info Tab
    [Documentation]    Switch back to the "ข้อมูลส่วนตัว" tab in /user-infos.
    Click First Visible Element    ${USER_PERSONAL_TAB}

Assert Order History Empty
    [Documentation]    Orders tab shows the empty-state "- ยังไม่มีรายการสั่งซื้อ -".
    Open Orders Tab
    Wait Until Any Element Visible    ${USER_ORDERS_EMPTY}    ${TIMEOUTS}[DEFAULT]

# ───────────────────────────── /forget-password (A4) ─────────────────────────────
Open Forget Password Page
    [Documentation]    Navigate to /forget-password/ and wait for the username field.
    Go To Route    ${ROUTES}[FORGET_PASSWORD]
    Wait For Page Settle
    Wait Until Any Element Visible    ${FGT_EMAIL_INPUT}    ${TIMEOUTS}[DEFAULT]

Request Password Reset
    [Documentation]    Type an email/username and click "ตกลง" (POST /web/forgot-password).
    [Arguments]    ${email}
    Input Into First Visible    ${FGT_EMAIL_INPUT}    ${email}
    Click First Visible Element    ${FGT_SUBMIT}
