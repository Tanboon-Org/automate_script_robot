*** Settings ***
Documentation    Single import hub for the WNW Robot Framework suite. Every test suite
...              does `Resource    ../../resources/imports/app_imports.robot` and gets the
...              whole POM stack: SeleniumLibrary + custom/db libraries + variable files +
...              all page keywords + all feature keywords.
...
...              Environment values (BASE_URL/ENV/HEADLESS/...) come from a variable file
...              chosen at run time, e.g.:
...                robot --variablefile resources/variables/env_staging.yaml tests
...              Defaults baked into common_keywords keep a bare `robot` run pointed at staging.

# Feature keyword layer (each transitively pulls in its page keywords, locators,
# common keywords, the Python libraries and the routes/timeouts/messages variables).
Resource         ../keywords/feature_keywords/common_feature_keywords.resource
Resource         ../keywords/feature_keywords/shop_feature_keywords.resource
Resource         ../keywords/feature_keywords/checkout_feature_keywords.resource
Resource         ../keywords/feature_keywords/order_feature_keywords.resource

# Page keyword layer (header is not pulled in by a feature file above, import explicitly).
Resource         ../keywords/page_keywords/header_component_keywords.resource
Resource         ../keywords/page_keywords/card2c2p_page_keywords.resource
Resource         ../keywords/page_keywords/auth_page_keywords.resource

*** Keywords ***
Open WNW Site
    [Documentation]    Suite-level setup: open the browser at the site root.
    Open WNW Browser

Teardown WNW Site
    [Documentation]    Suite-level teardown: close all browsers.
    Close WNW Browser
