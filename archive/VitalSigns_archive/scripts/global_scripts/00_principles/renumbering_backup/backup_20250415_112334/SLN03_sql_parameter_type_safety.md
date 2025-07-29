---
id: "SLN03"
title: "SQL Parameter Type Safety"
type: "solution"
date_created: "2025-04-07"
date_modified: "2025-04-07"
author: "Claude"
implements:
  - "SLN01": "Type Safety in Logical Contexts"
related_to:
  - "P71": "Row-Aligned Tables"
  - "P74": "Reactive Data Filtering"
---

# SQL Parameter Type Safety

## Problem Description

When constructing SQL queries dynamically in R, parameters must be properly typed and escaped to prevent:

1. SQL syntax errors due to string vs. numeric handling
2. Security vulnerabilities like SQL injection
3. Data type mismatches between code and database schema

A common error occurs when filtering by a column that stores numeric IDs:

```r
# ERROR: When platform_filter is a string like "ebay"
query <- paste0("SELECT * FROM df_customer_profile WHERE platform_id = ", platform_filter)
# Results in: SELECT * FROM df_customer_profile WHERE platform_id = ebay
# This fails because "ebay" is treated as a column name, not a string value
```

## Solution: Type-Aware Parameter Handling

Implement type-checking before constructing SQL queries:

```r
# Type-safe parameter handling
if (!is.null(platform_filter)) {
  if (is.numeric(platform_filter) || grepl("^[0-9]+$", platform_filter)) {
    # Numeric value - no quotes needed
    where_clause <- paste0("platform_id = ", platform_filter) 
  } else {
    # String value - needs quotes
    where_clause <- paste0("platform_id = '", platform_filter, "'")
  }
}
```

## Implementation Guidelines

### 1. String Parameters

For string parameters, always add single quotes and escape any single quotes within the string:

```r
safe_string <- gsub("'", "''", user_input)  # Escape single quotes
query <- paste0("SELECT * FROM table WHERE name = '", safe_string, "'")
```

### 2. Numeric Parameters

For numeric parameters, validate they are actually numeric:

```r
if (is.numeric(user_id) || grepl("^[0-9]+$", user_id)) {
  query <- paste0("SELECT * FROM users WHERE id = ", user_id)
} else {
  stop("Invalid numeric ID")
}
```

### 3. Date Parameters

Format dates according to your database's expectations:

```r
# Format date for SQL
sql_date <- format(as.Date(date_input), "%Y-%m-%d")
query <- paste0("SELECT * FROM events WHERE event_date = '", sql_date, "'")
```

### 4. Boolean Parameters

Handle booleans based on your database's conventions:

```r
# For databases using 1/0
sql_bool <- ifelse(is_active, 1, 0)
query <- paste0("SELECT * FROM users WHERE active = ", sql_bool)

# For databases using TRUE/FALSE
sql_bool <- ifelse(is_active, "TRUE", "FALSE")
query <- paste0("SELECT * FROM users WHERE active = ", sql_bool)
```

## Best Practices

1. **Use Prepared Statements**: When available in your database driver, always prefer prepared statements:

   ```r
   query <- "SELECT * FROM users WHERE username = ?"
   result <- dbGetQuery(conn, query, params = list(username))
   ```

2. **Create Wrapper Functions**: Abstract SQL generation with type-safe functions:

   ```r
   build_where_clause <- function(field, value) {
     if (is.numeric(value)) {
       return(paste0(field, " = ", value))
     } else {
       value <- gsub("'", "''", value)
       return(paste0(field, " = '", value, "'"))
     }
   }
   ```

3. **Validate Before Query**: Always validate parameter types before constructing queries:

   ```r
   if (!is.numeric(id) && !grepl("^[0-9]+$", id)) {
     stop("ID must be numeric")
   }
   ```

4. **Document Expected Types**: Clearly document parameter type expectations in function headers:

   ```r
   #' @param platform_id Numeric. The platform identifier.
   ```

## Common Patterns

### 1. Safe WHERE Clause Builder

```r
build_where_conditions <- function(conditions) {
  where_clauses <- character(0)
  
  for (field in names(conditions)) {
    value <- conditions[[field]]
    
    if (is.null(value)) {
      next
    } else if (is.numeric(value)) {
      where_clauses <- c(where_clauses, paste0(field, " = ", value))
    } else if (is.character(value)) {
      where_clauses <- c(where_clauses, paste0(field, " = '", gsub("'", "''", value), "'"))
    } else if (is.logical(value)) {
      where_clauses <- c(where_clauses, paste0(field, " = ", ifelse(value, "TRUE", "FALSE")))
    }
  }
  
  if (length(where_clauses) > 0) {
    return(paste0(" WHERE ", paste(where_clauses, collapse = " AND ")))
  } else {
    return("")
  }
}

# Usage
query <- paste0(
  "SELECT * FROM customers", 
  build_where_conditions(list(
    platform_id = 123,
    name = "Smith",
    active = TRUE
  ))
)
```

### 2. IN Clause for Multiple Values

```r
build_in_clause <- function(field, values) {
  if (length(values) == 0) {
    return(NULL)
  }
  
  if (is.numeric(values[1])) {
    values_str <- paste(values, collapse = ",")
  } else {
    values_str <- paste0("'", gsub("'", "''", values), "'", collapse = ",")
  }
  
  return(paste0(field, " IN (", values_str, ")"))
}
```

## Examples of Fixed Queries

### Before (Problematic)

```r
# Problem: Numeric vs. String confusion
platform_filter <- "ebay"
query <- paste0("SELECT * FROM df_customer_profile WHERE platform_id = ", platform_filter)
# Results in: SELECT * FROM df_customer_profile WHERE platform_id = ebay
# Causes: "Referenced column 'ebay' not found in FROM clause!"
```

### After (Type-Safe)

```r
# Fixed: Type-aware parameter handling
platform_filter <- "ebay"
if (is.numeric(platform_filter) || grepl("^[0-9]+$", platform_filter)) {
  query <- paste0("SELECT * FROM df_customer_profile WHERE platform_id = ", platform_filter)
} else {
  query <- paste0("SELECT * FROM df_customer_profile WHERE platform_id = '", platform_filter, "'")
}
# Results in: SELECT * FROM df_customer_profile WHERE platform_id = 'ebay'
# Works correctly with string values
```

## References

- SQL Injection: https://owasp.org/www-community/attacks/SQL_Injection
- R DBI Package: https://dbi.r-dbi.org/
- Database Type Systems: https://en.wikipedia.org/wiki/SQL#Data_types