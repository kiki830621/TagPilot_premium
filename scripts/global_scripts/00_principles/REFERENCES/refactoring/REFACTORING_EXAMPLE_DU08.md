# Refactoring Example: DU08 Data Type Handling

This document demonstrates the complete refactoring of DU08_data_type_handling.qmd, showing the before and after states.

## Before: Embedded Implementation (Current State)

The current DU08 file contains 400+ lines of R code embedded directly in the documentation. Here's a sample:

```markdown
# Data Type Handling in DuckDB

## Handling Basic Types

### Numeric Types

```r
process_numeric_data <- function(df) {
  df %>%
    mutate(
      id = as.integer(id),
      large_value = case_when(
        value > .Machine$integer.max ~ as.numeric(value),
        TRUE ~ as.integer(value)
      ),
      price = round(as.numeric(price), 2)
    )
}
```

### String Types

```r
clean_string_data <- function(df) {
  df %>%
    mutate(
      text = trimws(text),
      text_clean = iconv(text, from = "UTF-8", to = "UTF-8", sub = ""),
      text_truncated = substr(text, 1, 255),
      text_normalized = case_when(
        is.na(text) | text == "" ~ NA_character_,
        TRUE ~ text
      )
    )
}
```
```

## After: Refactored Structure

### Step 1: Extract Functions to Script Files

**File: `/scripts/global_scripts/02_db_utils/type_handling/fn_process_numeric_data.R`**

```r
#' Process numeric data for DuckDB compatibility
#' 
#' @description Handles numeric type conversions including integer overflow 
#'              detection and decimal precision preservation.
#'              Implements DU08: Data Type Handling specification.
#' 
#' @param df Data frame containing numeric columns to process
#' @return Data frame with properly typed numeric columns
#' 
#' @details
#' This function performs the following conversions:
#' - Detects and handles integer overflow
#' - Preserves decimal precision for currency fields
#' - Ensures consistent NULL handling
#' 
#' @references 
#' - Principle: natural/en/part2_implementations/CH17_database_specifications/duckdb/DU08_data_type_handling.qmd
#' - Tests: scripts/global_scripts/02_db_utils/type_handling/test_numeric_processing.R
#' 
#' @examples
#' df <- data.frame(
#'   id = c("1", "2", "3"),
#'   price = c(10.999, 20.001, 30.5),
#'   large_value = c(1e10, 2e10, 3e10)
#' )
#' df_processed <- process_numeric_data(df)
#' 
#' @export
process_numeric_data <- function(df) {
  require(dplyr)
  
  # Validate input
  if (!is.data.frame(df)) {
    stop("Input must be a data frame")
  }
  
  df %>%
    mutate(
      # Ensure integer types where appropriate
      across(
        where(~is.character(.) && all(grepl("^\\d+$", ., na.rm = TRUE))),
        as.integer
      ),
      
      # Handle potential overflow
      across(
        where(is.numeric),
        ~case_when(
          . > .Machine$integer.max ~ as.numeric(.),
          . < -.Machine$integer.max ~ as.numeric(.),
          TRUE ~ .
        )
      ),
      
      # Round currency fields to 2 decimal places
      across(
        matches("price|cost|amount|fee|total", ignore.case = TRUE),
        ~round(as.numeric(.), 2)
      )
    )
}
```

**File: `/scripts/global_scripts/02_db_utils/type_handling/fn_clean_string_data.R`**

```r
#' Clean and standardize string data for DuckDB
#' 
#' @description Performs string cleaning operations including encoding fixes,
#'              whitespace trimming, and length enforcement.
#'              Implements DU08: Data Type Handling specification.
#' 
#' @param df Data frame containing string columns
#' @param max_length Maximum allowed string length (default: 65535)
#' @param encoding Target encoding (default: "UTF-8")
#' 
#' @return Data frame with cleaned string columns
#' 
#' @export
clean_string_data <- function(df, max_length = 65535, encoding = "UTF-8") {
  require(dplyr)
  
  df %>%
    mutate(
      across(
        where(is.character),
        ~{
          x <- trimws(.)  # Trim whitespace
          x <- iconv(x, from = encoding, to = encoding, sub = "")  # Fix encoding
          x <- substr(x, 1, max_length)  # Enforce max length
          # Normalize empty strings to NA
          case_when(
            is.na(x) | x == "" ~ NA_character_,
            TRUE ~ x
          )
        }
      )
    )
}
```

### Step 2: Create Test Files

**File: `/scripts/global_scripts/02_db_utils/type_handling/test_numeric_processing.R`**

```r
# Test suite for numeric data processing
# Tests implementation of DU08 specifications

library(testthat)
source("fn_process_numeric_data.R")

test_that("Integer overflow is handled correctly", {
  df <- data.frame(
    small = c(1, 2, 3),
    large = c(1e10, 2e10, 3e10)
  )
  
  result <- process_numeric_data(df)
  
  expect_true(is.integer(result$small))
  expect_true(is.numeric(result$large))
  expect_false(is.integer(result$large))
})

test_that("Price fields are rounded to 2 decimals", {
  df <- data.frame(
    item = c("A", "B"),
    price = c(10.999, 20.001),
    total_cost = c(30.5555, 40.4444)
  )
  
  result <- process_numeric_data(df)
  
  expect_equal(result$price, c(11.00, 20.00))
  expect_equal(result$total_cost, c(30.56, 40.44))
})

test_that("String-to-integer conversion works", {
  df <- data.frame(
    id = c("1", "2", "3"),
    value = c(10, 20, 30)
  )
  
  result <- process_numeric_data(df)
  
  expect_true(is.integer(result$id))
  expect_equal(result$id, c(1L, 2L, 3L))
})
```

### Step 3: Update Principle Documentation

**File: `/00_principles/natural/en/part2_implementations/CH17_database_specifications/duckdb/DU08_data_type_handling.qmd`**

```markdown
---
title: "DU08: Data Type Handling"
subtitle: "Specifications for Data Type Management in DuckDB"
author: "MAMBA Framework"
date: "2025-08-27"
categories: [database, data-types, specifications]
---

# Data Type Handling in DuckDB

## Overview

This specification defines how different data types should be handled when working with DuckDB, ensuring consistency, performance, and data integrity across the MAMBA framework.

## Type Handling Specifications

### Basic Type Categories

DuckDB supports four main categories of types that require different handling strategies:

1. **Numeric Types**: INTEGER, BIGINT, DOUBLE, DECIMAL
2. **String Types**: VARCHAR, TEXT
3. **Temporal Types**: DATE, TIME, TIMESTAMP
4. **Complex Types**: LIST, STRUCT, MAP, JSON

### Type Conversion Matrix

| Source Type | Target Type | Conversion Strategy | Implementation |
|------------|-------------|-------------------|----------------|
| R character | DuckDB VARCHAR | Direct with encoding fix | `clean_string_data()` |
| R numeric | DuckDB DOUBLE | Overflow detection | `process_numeric_data()` |
| R integer | DuckDB INTEGER | Range validation | `process_numeric_data()` |
| R Date | DuckDB DATE | Direct mapping | Native DBI |
| R POSIXct | DuckDB TIMESTAMP | Timezone handling | `process_temporal_data()` |
| R list | DuckDB JSON | Serialization | `handle_complex_types()` |

## Implementation Architecture

### Function Organization

Type handling functions are organized by data type category:

```
scripts/global_scripts/02_db_utils/type_handling/
├── fn_process_numeric_data.R      # Numeric type conversions
├── fn_clean_string_data.R         # String cleaning and validation
├── fn_process_temporal_data.R     # Date/time handling
├── fn_handle_complex_types.R      # List, struct, JSON handling
├── fn_type_detection.R            # Automatic type inference
└── test_*.R                        # Comprehensive test suites
```

### Usage Patterns

#### Basic Type Processing Pipeline

```r
# Load type handling functions
source("scripts/global_scripts/02_db_utils/type_handling/fn_process_numeric_data.R")
source("scripts/global_scripts/02_db_utils/type_handling/fn_clean_string_data.R")

# Apply type processing pipeline
df_processed <- df_raw %>%
  process_numeric_data() %>%
  clean_string_data(max_length = 255) %>%
  process_temporal_data(target_tz = "UTC")

# Write to DuckDB
dbWriteTable(con, "processed_data", df_processed)
```

#### Complex Type Handling

For nested structures and JSON data:

```r
source("scripts/global_scripts/02_db_utils/type_handling/fn_handle_complex_types.R")

# Strategy selection based on use case
df_flat <- flatten_complex_types(df, strategy = "wide")
df_json <- serialize_complex_types(df, format = "json")
```

## Type-Specific Specifications

### Numeric Types

**Specification**: Numeric types must preserve precision while detecting overflow conditions.

**Requirements**:
- Integer overflow detection (> 2^31-1)
- Currency precision (2 decimal places)
- Scientific notation handling
- NULL vs NaN differentiation

**Implementation**: See `fn_process_numeric_data.R`

### String Types

**Specification**: String data must be UTF-8 encoded with consistent NULL handling.

**Requirements**:
- UTF-8 encoding enforcement
- Whitespace normalization
- Length constraints (VARCHAR limits)
- Empty string vs NULL consistency

**Implementation**: See `fn_clean_string_data.R`

### Temporal Types

**Specification**: Temporal data must maintain timezone awareness and precision.

**Requirements**:
- Timezone conversion capabilities
- Date format detection
- Precision preservation (microseconds)
- Epoch conversion support

**Implementation**: See `fn_process_temporal_data.R`

### Complex Types

**Specification**: Complex nested structures must be handled according to use case.

**Strategies**:
1. **Flattening**: For analytical queries
2. **JSON Serialization**: For storage and transport
3. **Structured Extraction**: For specific fields

**Implementation**: See `fn_handle_complex_types.R`

## Performance Considerations

### Batch Processing

Type conversions should be vectorized for performance:

```r
# Efficient: Vectorized operations
df %>% mutate(across(where(is.character), clean_string_data))

# Inefficient: Row-by-row processing
for(i in 1:nrow(df)) df[i,] <- process_row(df[i,])
```

### Memory Management

Large datasets require chunked processing:

```r
source("scripts/global_scripts/02_db_utils/type_handling/fn_process_chunks.R")
process_large_dataset(df, chunk_size = 10000)
```

## Testing Requirements

All type handling functions must include:

1. **Unit Tests**: Individual function behavior
2. **Integration Tests**: Pipeline combinations
3. **Edge Case Tests**: Boundary conditions
4. **Performance Tests**: Large dataset handling

Test files are located alongside implementations with `test_` prefix.

## Related Specifications

- **DM_R025**: Type Conversion Between R and DuckDB
- **DM_R024**: List Column Handling Rule
- **DM_R026**: JSON Serialization Strategy
- **MP064**: ETL-Derivation Separation Principle

## References

### Implementation Files
- Primary: `/scripts/global_scripts/02_db_utils/type_handling/`
- Tests: `/scripts/global_scripts/02_db_utils/type_handling/test_*.R`
- Examples: `/scripts/global_scripts/98_test/test_duckdb_types.R`

### External Documentation
- [DuckDB Data Types](https://duckdb.org/docs/sql/data_types/overview)
- [R DBI Specification](https://dbi.r-dbi.org/)
- [JSON Schema](https://json-schema.org/)
```

### Step 4: Update Implementation Map

**Add to `/00_principles/IMPLEMENTATION_MAP.yaml`:**

```yaml
principles:
  DU08:
    title: "Data Type Handling"
    category: "database_specifications"
    implementations:
      r:
        type_handling:
          - path: "02_db_utils/type_handling/fn_process_numeric_data.R"
            functions: [process_numeric_data]
            tests: "02_db_utils/type_handling/test_numeric_processing.R"
          
          - path: "02_db_utils/type_handling/fn_clean_string_data.R"
            functions: [clean_string_data]
            tests: "02_db_utils/type_handling/test_string_cleaning.R"
          
          - path: "02_db_utils/type_handling/fn_process_temporal_data.R"
            functions: [process_temporal_data]
            tests: "02_db_utils/type_handling/test_temporal_processing.R"
          
          - path: "02_db_utils/type_handling/fn_handle_complex_types.R"
            functions: [flatten_complex_types, serialize_complex_types]
            tests: "02_db_utils/type_handling/test_complex_types.R"
      
      python:
        future:
          - path: "26_platform_apis/type_handling/type_handler.py"
            status: "planned"
```

## Summary of Changes

### Before
- **File Size**: 400+ lines
- **Content**: 70% implementation code, 30% documentation
- **Language**: R-specific
- **Testing**: No tests for embedded code
- **Maintenance**: Changes require documentation updates

### After
- **File Size**: ~150 lines
- **Content**: 100% specifications and concepts
- **Language**: Language-agnostic with implementation references
- **Testing**: Full test coverage in separate files
- **Maintenance**: Implementation can evolve independently

### Benefits Realized

1. **Separation of Concerns**: Clear boundary between specification and implementation
2. **Testability**: All functions now have comprehensive tests
3. **Reusability**: Functions can be imported and reused across projects
4. **Multi-Language Support**: Easy to add Python implementation following same specs
5. **Documentation Clarity**: Principles focus on WHAT and WHY, not HOW
6. **IDE Support**: Full autocomplete, linting, and debugging for implementation files
7. **Version Control**: Clean commits separating documentation from code changes

This refactoring transforms a monolithic documentation file into a clean architectural specification with properly organized, testable implementations.