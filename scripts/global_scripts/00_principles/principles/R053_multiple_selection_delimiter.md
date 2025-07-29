---
id: "R0053"
title: "Multiple Selection Delimiter Rule"
type: "rule"
date_created: "2025-04-06"
author: "Claude"
implements:
  - "MP0008": "Terminology Axiomatization"
  - "MP0010": "Information Flow Transparency"
related_to:
  - "P0002": "Data Integrity"
  - "R0027": "Data Frame Creation Strategy"
---

# Multiple Selection Delimiter Rule

## Core Rule

When representing multiple selections within a single cell or field, always use semicolons (`;`) as the delimiter.

## Rationale

Using semicolons as separators for multiple selections:

1. **Avoids CSV Conflicts**: Commas are reserved as field separators in CSV files, making semicolons safer for internal field delimitation
2. **Aligns with Excel Standards**: Semicolons are Excel's default list separator in many regional settings
3. **Ensures Data Integrity**: Reduces ambiguity during data export, import, and processing operations
4. **Facilitates Parsing**: Makes automated data extraction more reliable and consistent

## Implementation Guidelines

### Format Specification

When storing multiple values in a single field:

```
value1;value2;value3
```

- **MUST** use semicolons without surrounding spaces
- **MUST NOT** use commas, vertical bars, or other characters as delimiters
- **SHOULD** remove any semicolons within individual values before concatenation
- **SHOULD** avoid empty values between delimiters (i.e., `value1;;value3`)

### Handling in R Code

```r
# Splitting a multi-selection field
selections <- unlist(strsplit(df$multiple_selection_field, ";"))

# Combining values into a multi-selection field
combined <- paste(selected_values, collapse = ";")
```

### Database Storage

- **Preferred**: Store in normalized tables with proper relationships
- **Alternative**: Store as semicolon-delimited strings for simple use cases
- **Never**: Use comma-delimited strings in database fields that may be exported to CSV

## File Format Compatibility

| Format | Compatibility | Notes |
|--------|---------------|-------|
| CSV    | High          | Avoids conflict with comma field separators |
| Excel  | High          | Matches Excel's default list separator |
| JSON   | Medium        | Arrays preferred for JSON; use semicolons when stored as strings |
| XML    | Medium        | Dedicated elements preferred; use semicolons when stored as attributes |
| SQL    | Medium        | Normalized tables preferred; use semicolons for simple cases |

## Examples

### Correct Usage

```
# Product categories
Electronics;Computers;Accessories

# Selected regions
North America;Europe;Asia

# Selected filters
price_range:100-500;color:blue;size:medium
```

### Incorrect Usage

```
# Using commas (AVOID)
Electronics,Computers,Accessories

# Using vertical bars (AVOID)
North America|Europe|Asia

# Using other delimiters (AVOID)
price_range:100-500/color:blue/size:medium
```

## Integration with Data Processing

When processing multi-selection data:

1. **Extraction**: Split the string using the semicolon delimiter
   ```r
   categories <- strsplit(product$categories, ";")[[1]]
   ```

2. **Filtering**: Check for the presence of a specific value
   ```r
   has_electronics <- grepl("Electronics", product$categories)
   # More precise matching to avoid partial matches
   has_electronics <- grepl("(^|;)Electronics(;|$)", product$categories)
   ```

3. **Aggregation**: Count selections
   ```r
   selection_count <- lengths(strsplit(df$selections, ";"))
   ```

4. **Visualization**: Transform to factors for visualization
   ```r
   all_selections <- unlist(strsplit(df$selections, ";"))
   selection_counts <- table(all_selections)
   ```

## Exception Handling

In situations where legacy data uses different delimiters:

1. **Convert** to semicolon format during data processing
   ```r
   # Convert comma-separated to semicolon-separated
   standardized <- gsub(",", ";", legacy_data$multiple_values)
   ```

2. **Document** any exceptions where semicolons cannot be used
3. **Implement** validation checks to enforce delimiter consistency

By adhering to this rule, data processing pipelines will be more robust, and the risk of data corruption during import/export operations will be significantly reduced.
