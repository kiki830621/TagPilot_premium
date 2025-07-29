---
id: "R0116"
title: "Enhanced Data Access with tbl2"
type: "rule"
date_created: "2025-04-19"
date_modified: "2025-04-19"
author: "Claude"
implements:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
  - "MP0081": "Explicit Parameter Specification"
derives_from:
  - "R0091": "Universal Data Access Pattern"
  - "R0101": "Unified tbl-like Data Access Pattern"
  - "R0092": "Universal DBI Approach"
  - "R0114": "Standard Mock Database Rule"
influences:
  - "P0077": "Performance Optimization"
---

# Enhanced Data Access with tbl2

## Core Requirement

All data access throughout the application should use the enhanced `tbl2()` function that extends `dplyr::tbl()` functionality to handle additional data types while maintaining full compatibility with the dplyr ecosystem and pipe operator.

## Pattern Description

This rule extends the Universal Data Access Pattern (R91) and Unified tbl-like Data Access Pattern (R101) by specifying the use of `tbl2()` as the primary interface for all data operations, regardless of source type.

### 1. Enhanced Access Pattern with tbl2

The `tbl2()` function provides a consistent interface for working with all data sources:

```r
# Standard pattern for any data source
data_ref <- tbl2(connection, "data_name")
result <- data_ref %>%
  filter(condition) %>%
  select(columns) %>%
  collect()
```

### 2. Extended Data Type Support

The `tbl2()` function handles an expanded set of data sources:

1. **DBI database connections**: Seamless support for SQL databases
2. **Lists and nested structures**: Intelligent access to data within lists
3. **Function-based data**: Support for functions that return data frames
4. **Files and external sources**: Direct access to CSV, Excel, and other formats
5. **Vectors and simple objects**: Automatic conversion to data frames
6. **Reactive expressions**: Support for Shiny reactive values and expressions

### 3. Integration with Universal Data Accessor

The `universal_data_accessor()` function should internally use `tbl2()` as its primary data reference mechanism:

```r
universal_data_accessor <- function(data_conn, data_name, ...) {
  # Use tbl2 for all data references
  df_ref <- tbl2(data_conn, data_name)
  
  # Apply operations and collect
  result <- df_ref %>% collect()
  return(result)
}
```

### 4. Backward Compatibility

The `tbl2()` function is fully backward compatible with `dplyr::tbl()` but adds enhanced capabilities:

```r
# Works just like dplyr::tbl for database connections
db_conn <- DBI::dbConnect(...)
customer_data <- tbl2(db_conn, "customers")

# But also works with additional data types
excel_data <- tbl2("data/sales.xlsx", "Q1_2023")
json_data <- tbl2(json_string)
```

## Implementation

### 1. Function Structure

The `tbl2()` function is implemented as an S3 generic with methods for different data types:

```r
tbl2 <- function(src, ...) {
  UseMethod("tbl2")
}

# Method for database connections
tbl2.DBIConnection <- function(src, from, ...) {
  dplyr::tbl(src, from, ...)
}

# Method for lists
tbl2.list <- function(src, from = NULL, ...) {
  # Handle list data sources
}

# Method for character (file paths, etc.)
tbl2.character <- function(src, ...) {
  # Handle files, JSON, etc.
}

# Additional methods for other types...
```

### 2. Usage with Mock Database

For consistency with R114 (Standard Mock Database Rule), access the mock database using `tbl2`:

```r
# Connect to mock database
mock_db_path <- file.path(find_project_root(), "update_scripts", 
                         "global_scripts", "global_data", "mock_data.duckdb")
conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = mock_db_path, read_only = TRUE)

# Use tbl2 to access data
customers <- tbl2(conn, "customer_profile") %>%
  filter(signup_date > as.Date("2021-06-01")) %>%
  collect()
```

### 3. Application in Data Pipeline Code

All new data pipelines should use `tbl2` for consistency:

```r
# Joining data from different sources
results <- tbl2(db_conn, "customers") %>%
  left_join(
    tbl2(db_conn, "orders") %>%
      group_by(customer_id) %>%
      summarize(total_orders = n(), total_spent = sum(amount)),
    by = c("id" = "customer_id")
  ) %>%
  collect()
```

## Benefits

1. **Consistency**: Uniform data access pattern across all data types
2. **Extensibility**: Easy to add support for new data sources
3. **Pipeline compatibility**: Integrates seamlessly with dplyr operations
4. **Reduced code duplication**: Standard pattern for all data access
5. **Improved performance**: Optimized for different data sources
6. **Better error handling**: Consistent error patterns and recovery
7. **Enhanced testability**: Simplifies mocking and testing

## Relationship to Other Rules and Principles

This rule:

- **Implements MP16 (Modularity)**: By standardizing the interface for data access
- **Implements MP17 (Separation of Concerns)**: By separating data source handling from business logic
- **Implements MP81 (Explicit Parameter Specification)**: By providing clear parameter interfaces

- **Derives from R91 (Universal Data Access Pattern)**: Extends the universal accessor approach
- **Derives from R101 (Unified tbl-like Data Access)**: Provides concrete implementation of the unified pattern
- **Derives from R92 (Universal DBI Approach)**: Extends DBI methodology to all data types
- **Derives from R114 (Standard Mock Database Rule)**: Integrates with mock database access

## Complete Example

```r
# Source the tbl2 function
source("global_scripts/02_db_utils/fn_tbl2.R")

# Access to database
db_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = "app_data.duckdb")

# A typical data pipeline
analysis_results <- tbl2(db_conn, "customer_profile") %>%
  filter(signup_date > as.Date("2022-01-01")) %>%
  left_join(
    tbl2(db_conn, "orders") %>%
      group_by(customer_id) %>%
      summarize(
        order_count = n(),
        total_spent = sum(amount),
        avg_order = mean(amount)
      ),
    by = c("id" = "customer_id")
  ) %>%
  collect() %>%
  mutate(
    value_segment = case_when(
      total_spent > 1000 ~ "High",
      total_spent > 500 ~ "Medium",
      TRUE ~ "Low"
    )
  )

# Access to external file
external_data <- tbl2("external_data.xlsx", sheet = "Competitors") %>%
  select(competitor_id, name, market_share) %>%
  collect()

# Combined analysis
final_report <- analysis_results %>%
  left_join(external_data, by = c("competitor_reference" = "competitor_id"))
```

## Migration Guidelines

1. Replace all direct calls to `dplyr::tbl()` with `tbl2()`
2. Update `universal_data_accessor()` implementation to use `tbl2()`
3. Use the `tbl2` pattern in all new code for consistent access patterns
4. Gradually refactor existing code to use the new pattern

## Conclusion

By standardizing on the enhanced `tbl2()` function for all data access, we achieve greater consistency, flexibility, and maintainability across the application. This approach builds on existing data access patterns while extending their capabilities to handle a wider range of data sources in a uniform way.