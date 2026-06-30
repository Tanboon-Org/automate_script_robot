*** Settings ***
Documentation    Locators for product-listing/category pages (port of pages/CategoryPage.ts).
...              Route pattern: /ร้านพวงหรีด/<category>/

*** Variables ***
# Product cards render as anchors to /พวงหรีด/<slug>/. Thai chars in CSS attribute
# selectors fail at runtime, so target the ASCII slug fragment "-wnw-".
${CAT_PRODUCT_CARDS}    css:a[href*="-wnw-"]
${CAT_PRODUCT_GRID}     css:[class*="product-grid"], [class*="product-list"], [class*="grid"]
${CAT_FILTER}           xpath=(//*[contains(text(),'ตัวกรองสินค้า')])[1]
${CAT_SORT_DROPDOWN}    css:select[class*="sort"], [class*="sort"] select
# Pagination: listing caps at 15 cards/page; "ถัดไป" advances and writes ?page=N to the URL.
${CAT_NEXT_PAGE}        xpath=//a[normalize-space()='ถัดไป'] | //button[normalize-space()='ถัดไป']
# findProductLinkByCode(code) -> a[href*="<code>-wnw"] is built dynamically in the keyword.
