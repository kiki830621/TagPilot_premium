---
id: "P0005"
title: "Case Sensitivity Principle"
type: "principle"
date_created: "2025-04-04"
date_modified: "2025-04-04"
author: "Claude"
derives_from:
  - "MP0012": "Company-Centered Design"
---

# Case Sensitivity Principle

## Core Principle

In our application architecture, we maintain a clear distinction between UI and server-side processing with respect to case sensitivity:

1. **UI is case sensitive** - User-facing text must preserve exact capitalization for proper branding and readability.
2. **Server is case insensitive** - All server-side processing should standardize case (generally to lowercase) for consistency and to prevent errors.

## Rationale

This principle enforces a "strict outward, permissive inward" approach that:

- Ensures professional presentation and brand consistency in user-facing elements
- Reduces errors caused by case inconsistencies in data processing
- Aligns with the Company-Centered Design principle (MP0012) by maintaining professional appearance while increasing system robustness

## Implementation Guidelines

### UI Components

1. **Text Display**:
   - Always use the exact capitalization specified in UI terminology dictionaries
   - Respect proper nouns, acronyms, and brand-specific capitalization
   - Never automatically transform case of displayed text

2. **Labels and Headings**:
   - Follow title case for English headings (e.g., "Customer Analysis")
   - For other languages, follow language-specific capitalization conventions

3. **Error Messages**:
   - Begin with capital letter
   - Use proper sentence case for readability

### Server-Side Processing

1. **Data Storage**:
   - Store normalized data (typically lowercase) for fields where case is unimportant
   - Preserve case only when semantically meaningful

2. **Data Comparison**:
   - All string comparisons should be case-insensitive by default
   - Use functions like `tolower()` or `toupper()` before comparison

3. **File and Resource Naming**:
   - Use lowercase for internal resource identifiers
   - Support case-insensitive matching for resource lookup

## Examples

### Parameter File Handling

```r
# When processing parameter files like platform.xlsx:

# UI representation - Case sensitive for display
platform_display_name <- platform_data$platform_name_english

# Server lookup key - Case insensitive for processing
platform_key <- tolower(gsub(" ", "", platform_data$platform_name_english))
```

### Translation Dictionary Access

```r
# Case-sensitive display of translations
translate <- function(text) {
  # Exact match for retrieving translations
  ui_dictionary[[text]]
}

# Case-insensitive matching for parameter files
find_language_column <- function(columns, target_language) {
  for (col in columns) {
    if (tolower(col) == tolower(target_language)) {
      return(col)
    }
  }
  return(NULL)
}
```

## Common Pitfalls

1. **Inconsistent Database Queries**:
   - INCORRECT: `WHERE name = 'Customer'`
   - CORRECT: `WHERE LOWER(name) = 'customer'`

2. **Filename Mismatches**:
   - INCORRECT: `file.exists("Config.yaml")`
   - CORRECT: `file_path <- find_file_case_insensitive("config.yaml")`

3. **Configuration Lookups**:
   - INCORRECT: `config$Parameters$Debug`
   - CORRECT: `config[[tolower("Parameters")]][[tolower("Debug")]]`

## Related Guidelines

- All UI text should come from terminology dictionaries, not hardcoded in the application
- Server-side code should standardize incoming data to a consistent case before processing
- Log files should preserve original case for debugging purposes

## Conclusion

By maintaining case sensitivity in the UI while enforcing case insensitivity in server-side processing, we create an application that both looks professional to users and operates robustly in the background. This principle helps prevent common errors while ensuring a polished user experience.
