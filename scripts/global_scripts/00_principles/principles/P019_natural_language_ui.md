# Principle 19: Natural Language UI

## Core Principle
User interfaces must display only natural language text and meaningful numbers to end users, never technical identifiers, codes, or internal representations. All technical values must be translated to human-readable form before presentation.

## Rationale
This principle ensures that:

1. **User Comprehension**: Users understand all displayed information without technical knowledge
2. **Cultural Relevance**: Text appears in the user's language and cultural context
3. **Professional Appearance**: UIs maintain a polished, professional appearance 
4. **Cognitive Efficiency**: Users process meaningful terms faster than codes or IDs
5. **Error Reduction**: Clear labeling reduces user input errors and confusion

## Implementation Guidelines

### Text Display
1. **Identifiers**: Never display raw IDs or codes directly
   - INCORRECT: "Category 001" or "Product PROD_392"
   - CORRECT: "Office Supplies" or "Laser Printer HP-5200"

2. **Language**: Display text in the user's selected language
   - Store translations for all user-facing text
   - Use locale-specific formatting for dates, numbers, and currencies
   - Provide fallbacks when translations are missing

3. **Technical Terms**: Technical terms should only appear if they are:
   - Industry standard terminology familiar to users
   - Accompanied by explanations when first introduced
   - Necessary for the user's task

### Number Presentation
1. **IDs**: Never show internal ID values unless they are meaningful user-facing identifiers
   - INCORRECT: User ID "u_9a42f8" or Category ID "000"
   - CORRECT: Order Number "ORD-29385" (when meaningful to user)

2. **Codes**: Replace internal codes with meaningful text
   - INCORRECT: Status "ST_PROC" or Type "TYP_A"
   - CORRECT: Status "Processing" or Type "Standard"

3. **Formatting**: Format numbers according to user's locale
   - Appropriate decimal and thousands separators
   - Currency symbols in correct position
   - Units displayed with appropriate symbols

### Implementation Pattern
Always separate storage values from display values:

```r
# Core pattern: Separate storage from display
picker_input(
  inputId = "category",
  label = "Category",
  # Storage values: Internal codes/IDs
  choices = setNames(
    # Value to store (not shown to user)
    c("000", "001", "002", "003"),
    # Display text (what user sees)
    c("All Categories", "Electronics", "Home Goods", "Office Supplies")
  ),
  selected = "000"
)
```

For language-dependent display:

```r
# Language-dependent display
category_labels <- if (language == "zh_TW.UTF-8") {
  c("所有產品", "電子產品", "家居用品", "辦公用品")
} else {
  c("All Categories", "Electronics", "Home Goods", "Office Supplies")
}

picker_input(
  inputId = "category",
  label = translate("Category"),
  choices = setNames(
    c("000", "001", "002", "003"),  # Internal values
    category_labels  # Language-specific display values
  ),
  selected = "000"
)
```

### Exception Cases
In rare cases where users need to see IDs:

1. **Technical Support**: May show IDs in help/debug views only
2. **Reference Numbers**: Public-facing IDs designed specifically for reference (e.g., Order #12345)
3. **Developer Tools**: Internal tools for developers/admins only

## Implementation Example

### Product Category Selection with Translation
```r
# Product category dropdown with proper translation
product_category_input <- function() {
  # Get product data
  product_data <- config$parameters$product_line
  
  # Determine which language column to use based on user language
  display_column <- if (exists("language") && language == "zh_TW.UTF-8" && 
                        "product_line_name_chinese" %in% names(product_data)) {
    "product_line_name_chinese"
  } else {
    "product_line_name_english"
  }
  
  # Create storage/display mapping
  choices <- setNames(
    # Storage values (not shown to user)
    sprintf("%03d", seq_len(nrow(product_data)) - 1),
    # Display values (shown to user in appropriate language)
    product_data[[display_column]]
  )
  
  # Create the input
  shinyWidgets::pickerInput(
    inputId = "product_category",
    label = translate("Product Category"),
    choices = choices,
    selected = names(choices)[1],  # First product (ALL) 
    width = "100%"
  )
}
```

## Related Principles
- R0034 (UI Text Standardization)
- R0036 (Available Locales)
- P0005 (Case Sensitivity Principle)
- MP0012 (Company Centered Design)
