---
id: "R55"
title: "Platform ID Reference Rule"
type: "rule"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "R38": "Platform Numbering Convention"
  - "SLN03": "SQL Parameter Type Safety"
related_to:
  - "MP46": "Neighborhood Principle"
---

# Platform ID Reference Rule

## Core Rule

**Marketing platform identifiers must be referenced using their numeric IDs when used in database operations, following the platform dictionary mapping defined in the R38 Platform Numbering Convention.**

## Background

The application uses numeric platform IDs in database tables and queries, but presents platforms to users with user-friendly names or codes. This rule establishes consistent handling of platform references to prevent type errors and ensure compatibility with database schemas.

## Implementation

### 1. Platform Dictionary Structure

The platform dictionary is defined in `platform_dictionary.xlsx` with the structure:

| platform_number | platform_name_english | code_alias |
|-----------------|----------------------|------------|
| 1               | Amazon               | AMZ        |
| 2               | Official Website     | WEB        |
| 6               | eBay                 | EBY        |
| etc.            | ...                  | ...        |

This file should be located according to MP46 (Neighborhood Principle) at:
```
update_scripts/global_scripts/global_data/parameters/platform_dictionary.xlsx
```

### 2. Platform Reference Mapping

When handling platform references, implement mapping between string identifiers and numeric IDs:

```r
# Create a mapping function
get_platform_id <- function(platform_reference) {
  # Get platform dictionary
  platform_dict <- load_platform_dictionary()
  
  # If already numeric, return as-is
  if (is.numeric(platform_reference) || grepl("^[0-9]+$", platform_reference)) {
    return(platform_reference)
  }
  
  # Normalize input
  platform_key <- tolower(platform_reference)
  
  # Check if it matches a name
  for (i in 1:nrow(platform_dict)) {
    name_key <- tolower(gsub(" ", "", platform_dict$platform_name_english[i]))
    if (platform_key == name_key) {
      return(platform_dict$platform_number[i])
    }
  }
  
  # Check if it matches a code alias
  if ("code_alias" %in% colnames(platform_dict)) {
    for (i in 1:nrow(platform_dict)) {
      if (!is.na(platform_dict$code_alias[i])) {
        alias_key <- tolower(platform_dict$code_alias[i])
        if (platform_key == alias_key) {
          return(platform_dict$platform_number[i])
        }
      }
    }
  }
  
  # No match found
  return(NULL)
}
```

### 3. Database Query Pattern

When using platform identifiers in database operations:

```r
# Good: Using numeric IDs directly
query <- "SELECT * FROM customer_data WHERE platform_id = 1"

# Good: Converting from string to numeric ID
platform_name <- "eBay"
platform_id <- get_platform_id(platform_name)
if (!is.null(platform_id)) {
  query <- paste0("SELECT * FROM customer_data WHERE platform_id = ", platform_id)
} else {
  warning("Unknown platform: ", platform_name)
}

# Bad: Using string directly in numeric column
query <- "SELECT * FROM customer_data WHERE platform_id = 'ebay'" # WILL FAIL
```

### 4. Caching Strategy

To improve performance, cache platform mappings:

```r
# Initialize cache on startup
initialize_platform_mapping <- function() {
  platform_dict <- load_platform_dictionary()
  platform_dict_mapping <- list()
  
  if (!is.null(platform_dict)) {
    # Map names
    for (i in 1:nrow(platform_dict)) {
      name_key <- tolower(gsub(" ", "", platform_dict$platform_name_english[i]))
      platform_dict_mapping[[name_key]] <- platform_dict$platform_number[i]
    }
    
    # Map code aliases
    if ("code_alias" %in% colnames(platform_dict)) {
      for (i in 1:nrow(platform_dict)) {
        if (!is.na(platform_dict$code_alias[i])) {
          alias_key <- tolower(platform_dict$code_alias[i])
          platform_dict_mapping[[alias_key]] <- platform_dict$platform_number[i]
        }
      }
    }
    
    # Store globally
    assign("platform_dict_mapping", platform_dict_mapping, envir = .GlobalEnv)
  }
}
```

## Validation Rules

1. **Database Schema Validation**: All platform ID columns in database tables must be numeric types.
2. **Query Validation**: All SQL queries filtering by platform must use numeric IDs.
3. **UI-to-Database Translation**: UI components must translate user-selected platform names to numeric IDs before database operations.

## Examples

### Example 1: UI Selection to Database Query

```r
# User selects "eBay" from dropdown
selected_platform <- input$platform_selection

# Convert to numeric ID for database query
platform_id <- NULL
if (exists("platform_dict_mapping")) {
  platform_key <- tolower(selected_platform)
  if (platform_key %in% names(platform_dict_mapping)) {
    platform_id <- platform_dict_mapping[[platform_key]]
  }
}

# Use in query
if (!is.null(platform_id)) {
  query <- paste0("SELECT * FROM sales WHERE platform_id = ", platform_id)
} else {
  # Handle unknown platform
  warning("Unknown platform: ", selected_platform)
  query <- "SELECT * FROM sales WHERE 1 = 0" # Returns empty result
}
```

### Example 2: Multiple Platform Handling

```r
# For multiple platform selection
selected_platforms <- input$platforms
platform_ids <- numeric(0)

for (platform in selected_platforms) {
  platform_key <- tolower(platform)
  if (platform_key %in% names(platform_dict_mapping)) {
    platform_ids <- c(platform_ids, platform_dict_mapping[[platform_key]])
  }
}

if (length(platform_ids) > 0) {
  query <- paste0("SELECT * FROM sales WHERE platform_id IN (", 
                 paste(platform_ids, collapse = ","), ")")
} else {
  query <- "SELECT * FROM sales WHERE 1 = 0" # Returns empty result
}
```

## Error Handling

When platform IDs cannot be resolved:

1. **Log Warning**: Include platform name in warning message
2. **Fail Gracefully**: Return empty results rather than invalid SQL
3. **User Feedback**: Notify user of invalid platform selection

## Related Rules

- **R38**: Platform Numbering Convention - Defines the numbering scheme for platforms
- **SLN03**: SQL Parameter Type Safety - Ensures proper SQL parameter handling
- **MP46**: Neighborhood Principle - Defines where platform dictionary should be located