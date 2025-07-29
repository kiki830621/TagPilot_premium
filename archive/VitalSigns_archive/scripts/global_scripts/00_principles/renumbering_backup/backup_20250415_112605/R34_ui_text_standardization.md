---
id: "R34"
title: "UI Text Standardization Rule"
type: "rule"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "P05": "Case Sensitivity Principle"
  - "MP23": "Language Preferences Meta-Principle"
---

# UI Text Standardization Rule

## Core Rule

All user interface text within the application must adhere to the following standardization rules:

1. **English-First Approach**: All hardcoded text in UI components must be in English.
2. **Translation via Dictionary**: Translations to other languages must be handled exclusively through the UI terminology dictionary.
3. **Translator Function Usage**: All UI text must be wrapped in the `translate()` function.
4. **Dictionary Append-Only**: The UI terminology dictionary follows SCD Type 2 principles - entries can only be appended, never modified or deleted.

## Implementation Requirements

### 1. UI Component Development

When creating or modifying UI components:

```r
# INCORRECT - Hardcoded non-English text
radioButtons(
  inputId = ns("product_category"),
  label = "商品種類",
  choices = NULL
)

# CORRECT - English text with translation function
radioButtons(
  inputId = ns("product_category"),
  label = translate("Product Category"),
  choices = NULL
)
```

### 2. Translation Function Usage

The `translate()` function must be used for all user-facing text:

```r
# Basic usage
title = translate("Application Settings")

# With vector inputs
labels = translate(c("Year", "Quarter", "Month"))

# In nested UI elements
card(
  card_header(translate("Customer Analysis")),
  card_body(translate("Detailed customer analysis will be displayed here."))
)
```

### 3. UI Terminology Dictionary Management

The UI terminology dictionary must follow these principles:

1. **Structure**: Must contain at minimum "English" and language-specific columns
2. **Immutability**: Existing entries must never be modified or deleted
3. **Expansion**: New terms can be added by appending to the dictionary
4. **Comprehensive Coverage**: All UI text must have corresponding dictionary entries

Example dictionary format:
```
English,Chinese
Application Settings,應用程式設定
Product Category,商品種類
Customer Analysis,顧客分析
```

### 4. Language Configuration Handling

Language configuration must be properly handled:

```r
# In app_config.yaml
brand:
  language: "English"  # Or other supported language with proper capitalization

# In translation function - case-insensitive matching for language columns
for (col in available_columns) {
  if (tolower(col) == tolower(target_language)) {
    language_column <- col
    break
  }
}
```

## Benefits

1. **Consistency**: Ensures consistent terminology throughout the application
2. **Maintainability**: Centralizes all text in a single dictionary for easier updates
3. **Internationalization**: Simplifies adding support for new languages
4. **Quality Assurance**: Makes it easier to review and approve translations
5. **Audit Trail**: Preserves historical terminology through append-only approach

## Common Pitfalls

1. **Direct Hardcoding**: Never hardcode non-English text directly in UI components
2. **Inconsistent Function Usage**: Always use translate() even for English-only applications
3. **Bypass Dictionary**: Never implement ad-hoc translation logic outside the dictionary
4. **Modifying Entries**: Never modify existing dictionary entries; always append new ones

## Implementation Example

### Dictionary Management

When adding new terminology:

```r
# INCORRECT - Modifying existing entries
ui_terminology_dictionary$English[5] <- "Updated Term"

# CORRECT - Appending new entries
new_entries <- data.frame(
  English = c("New Term 1", "New Term 2"),
  Chinese = c("新術語 1", "新術語 2")
)
ui_terminology_dictionary <- rbind(ui_terminology_dictionary, new_entries)
```

### Robust Translation Function

```r
translate <- function(text, default_lang = "English") {
  if (is.null(text)) return(text)
  
  # Handle vectors
  if (length(text) > 1) {
    return(sapply(text, translate, default_lang = default_lang))
  }
  
  # Try exact match first (case-sensitive)
  result <- ui_dictionary[[text]]
  
  # Fall back to case-insensitive if needed
  if (is.null(result)) {
    text_lower <- tolower(text)
    for (key in names(ui_dictionary)) {
      if (tolower(key) == text_lower) {
        result <- ui_dictionary[[key]]
        break
      }
    }
  }
  
  # Return original if no translation found
  if (is.null(result)) {
    # Log missing translation for easier dictionary updates
    if (!exists("missing_translations")) {
      assign("missing_translations", character(0), envir = .GlobalEnv)
    }
    if (!(text %in% missing_translations)) {
      missing_translations <<- c(missing_translations, text)
      message("Missing translation for: ", text)
    }
    return(text)
  }
  
  return(result)
}
```

## Special Considerations

1. **Dynamic Text**: Text that's dynamically generated must use translated components
2. **Concatenation**: Avoid concatenating translated fragments; translate whole sentences
3. **Formatting**: Use placeholders instead of string concatenation for formatted text
4. **Default Language**: English serves as the default when translations aren't available

## Conclusion

By following the UI Text Standardization Rule, we ensure a consistent, maintainable, and internationalizable user interface. The English-first approach with dictionary-based translation provides a solid foundation for multi-language support while preserving the historical record of terminology through an append-only dictionary system.