*** Settings ***
Documentation    Browse / search / cart business actions (port of keywords/shopKeywords.ts).
...              Composed from page keywords only — no raw selectors here.
Resource         ../common_keywords.resource
Resource         ../page_keywords/home_page_keywords.resource
Resource         ../page_keywords/category_page_keywords.resource
Resource         ../page_keywords/product_page_keywords.resource
Resource         ../page_keywords/cart_page_keywords.resource
Resource         common_feature_keywords.resource

*** Keywords ***
Select Category
    [Documentation]    shopKeywords.selectCategory(category) — open listing + assert loaded.
    [Arguments]    ${category}
    Open Category    ${category}[url]
    Assert Category Loaded    ${category}[minExpectedItems]

Open Product By Data
    [Documentation]    shopKeywords.openProduct(product) — open PDP directly by slug.
    [Arguments]    ${product}
    Open Product    ${product}[slug]

Add To Cart
    [Documentation]    shopKeywords.addToCart(productPage).
    Add Product To Cart

Go To Cart
    [Documentation]    shopKeywords.goToCart(page).
    Open Cart Page

Open Random Product Via Home
    [Documentation]    shopKeywords.openRandomProductViaHome(page) — Home -> best-sellers
    ...    category -> random product from the curated pool that is present on the listing
    ...    (fallback: direct nav to the first pool item). Returns the chosen product dict.
    Open Home Page
    Assert Home Loaded
    Dismiss Cookie
    ${category}=    Load Test Data    category    best_sellers
    ${clicked}=    Run Keyword And Return Status    Click Best Seller Nav Link
    ${loaded}=    Run Keyword And Return Status    Assert Category Loaded
    IF    not (${clicked} and ${loaded})
        Open Category    ${category}[url]
        Assert Category Loaded
    END
    ${pool}=    Load All Test Data    products
    ${shuffled}=    Evaluate    __import__('random').sample($pool, len($pool))
    ${chosen}=    Set Variable    ${NONE}
    ${href}=    Set Variable    ${NONE}
    FOR    ${p}    IN    @{shuffled}
        ${h}=    Get Product Link Href By Code    ${p}[code]
        IF    $h is not None
            ${chosen}=    Set Variable    ${p}
            ${href}=    Set Variable    ${h}
            BREAK
        END
    END
    IF    $chosen is None
        ${chosen}=    Set Variable    ${shuffled}[0]
        ${href}=    Set Variable    ${ROUTES}[PRODUCT_PREFIX]${chosen}[slug]/
    END
    Log    [e2e] สุ่มสินค้าจาก pool: ${chosen}[code] (${chosen}[name]) -> ${href}
    ${is_abs}=    Evaluate    str($href).startswith('http')
    IF    ${is_abs}
        Go To Absolute    ${href}
    ELSE
        Go To Route    ${href}
    END
    RETURN    ${chosen}
