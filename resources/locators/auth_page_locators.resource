*** Settings ***
Documentation    Locators for the Account / Auth surface (port of
...              components/layout/Header/NavBar/{AuthModal,AuthTab,LoginForm,RegisterForm}.tsx
...              and pages user-confirm-email / forget-password / user-reset-password / user-infos).
...              The login + register forms render inside a headless-ui Dialog (role="dialog");
...              only the SELECTED tab's form is mounted, so name-based inputs are unambiguous
...              once scoped to the dialog.

*** Variables ***
# --- header trigger (visible only when NOT authenticated) ---
${AUTH_OPEN_BTN}        xpath=//button[contains(normalize-space(.),'สมัครสมาชิก / เข้าสู่ระบบ')]

# --- dialog shell + tabs ---
${AUTH_DIALOG}          css:[role="dialog"]
${AUTH_TAB_LOGIN}       xpath=//*[@role="dialog"]//button[normalize-space(.)='เข้าสู่ระบบ']
${AUTH_TAB_REGISTER}    xpath=//*[@role="dialog"]//button[normalize-space(.)='สมัครสมาชิก']

# --- form fields (scoped to dialog; only one panel mounted at a time) ---
${AUTH_EMAIL}           xpath=//*[@role="dialog"]//input[@name="email"]
${AUTH_PASSWORD}        xpath=//*[@role="dialog"]//input[@name="password"]
${AUTH_REMEMBER}        xpath=//*[@role="dialog"]//input[@name="rememberMe"]
${AUTH_PRIVACY}         xpath=//*[@role="dialog"]//input[@name="privacy_policy_accepted"]
${AUTH_SUBMIT}          xpath=//*[@role="dialog"]//button[@type="submit"]
${AUTH_PWD_TOGGLE}      xpath=//*[@role="dialog"]//input[@name="password"]/following::button[@type="button"][1]
${AUTH_FORGOT_LINK}     xpath=//*[@role="dialog"]//*[contains(text(),'ลืมรหัสผ่าน')]
${AUTH_PRIVACY_LINK}    xpath=//*[@role="dialog"]//a[contains(@href,'นโยบายความเป็นส่วนตัว')]
# any inline (red) validation message inside the dialog
${AUTH_INLINE_ERROR}    xpath=//*[@role="dialog"]//span[contains(@class,'text-red')]

# --- success / error modals (separate headless-ui Dialog, opened after auth modal closes) ---
# assert by stable text fragments rather than position:
${MSG_LOGIN_SUCCESS}        เข้าสู่ระบบสำเร็จ
${MSG_LOGIN_INVALID}        รหัสหรืออีเมลผู้ใช้ไม่ถูกต้อง
${MSG_LOGIN_UNVERIFIED}     ยังไม่ได้ยืนยันตัวตน
${MSG_LOGIN_REQUIRED}       กรุณาระบุอีเมลและรหัสผ่าน
${MSG_REGISTER_SUCCESS}     ลงทะเบียนสำเร็จ
${MSG_REGISTER_CHECK_MAIL}  กรุณาตรวจสอบอีเมลเพื่อยืนยันตัวตน

# --- /user-infos page (A6/A7). Inputs carry no name attr and render twice (desktop+mobile),
#     so match by type and use first-visible helpers. ---
${USER_EMAIL_INPUT}     xpath=//input[@type='email']
${USER_LOGOUT_BTN}      xpath=//button[normalize-space()='Log Out'] | //a[normalize-space()='Log Out']
