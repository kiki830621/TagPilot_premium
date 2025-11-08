# Immediate Action Plan: Principle Code Extraction

## Priority 1: Most Critical Files to Refactor

These files contain the most embedded code and should be refactored first:

### Week 1 Targets

1. **CH17_database_specifications/duckdb/** (400+ lines of code each)
   - [ ] DU08_data_type_handling.qmd
   - [ ] DU06_mamba_integration.qmd
   - [ ] DU04_import_export.qmd
   - [ ] DU10_complete_reference.qmd

2. **CH02_data_management/rules/** (Heavy implementation code)
   - [ ] DM_R025_type_conversion_r_duckdb.qmd
   - [ ] DM_R024_list_column_handling.qmd
   - [ ] DM_R026_json_serialization_strategy.qmd

## Step-by-Step Refactoring Process

### Step 1: Create Directory Structure (Day 1)

```bash
# Run these commands from MAMBA root directory
cd /Users/che/Library/CloudStorage/Dropbox/che_workspace/projects/ai_martech/l4_enterprise/MAMBA/scripts/global_scripts

# Create type handling directory
mkdir -p 02_db_utils/type_handling

# Create DuckDB utilities directory  
mkdir -p 02_db_utils/duckdb_utils

# Create complex types directory
mkdir -p 02_db_utils/complex_types

# Create test directories
mkdir -p 02_db_utils/type_handling/tests
mkdir -p 02_db_utils/duckdb_utils/tests
mkdir -p 02_db_utils/complex_types/tests
```

### Step 2: Extract First Function Set (Day 2)

Start with DM_R025 type conversion functions:

**Create**: `02_db_utils/type_handling/fn_convert_r_to_duckdb.R`

```r
#' Convert R data frame for DuckDB compatibility
#' 
#' @description Implements DM_R025: Type Conversion Between R and DuckDB
#' @references 00_principles/natural/en/part1_principles/CH02_data_management/rules/DM_R025
#' 
#' @param df Data frame to convert
#' @return Data frame with DuckDB-compatible types
#' @export
convert_r_to_duckdb <- function(df) {
  # Move the actual implementation here from DM_R025
}
```

**Create**: `02_db_utils/type_handling/fn_convert_duckdb_to_r.R`

```r
#' Convert DuckDB query results to R types
#' 
#' @description Implements DM_R025: Reverse conversion from DuckDB to R
#' @references 00_principles/natural/en/part1_principles/CH02_data_management/rules/DM_R025
#' 
#' @param df Data frame from DuckDB query
#' @param schema Optional schema specification
#' @return Data frame with appropriate R types
#' @export
convert_duckdb_to_r <- function(df, schema = NULL) {
  # Move the actual implementation here from DM_R025
}
```

### Step 3: Create Master Source File (Day 3)

**Create**: `02_db_utils/source_duckdb_utils.R`

```r
# Master source file for DuckDB utilities
# Source this file to load all DuckDB-related functions

# Type handling functions
source("02_db_utils/type_handling/fn_convert_r_to_duckdb.R")
source("02_db_utils/type_handling/fn_convert_duckdb_to_r.R")

# Complex type functions
source("02_db_utils/complex_types/fn_handle_list_columns.R")
source("02_db_utils/complex_types/fn_flatten_struct.R")
source("02_db_utils/complex_types/fn_serialize_to_json.R")

# DuckDB-specific utilities
source("02_db_utils/duckdb_utils/fn_safe_write_table.R")
source("02_db_utils/duckdb_utils/fn_batch_insert.R")
source("02_db_utils/duckdb_utils/fn_optimize_query.R")

message("DuckDB utilities loaded successfully")
```

### Step 4: Update Principle Files (Day 4-5)

Transform each principle file from embedded code to references:

**Template for Updated Principle**:

```markdown
## Implementation

### R Implementation
- **Location**: `scripts/global_scripts/02_db_utils/type_handling/`
- **Functions**: 
  - `convert_r_to_duckdb()` - Pre-write conversion
  - `convert_duckdb_to_r()` - Post-read conversion
- **Tests**: `scripts/global_scripts/02_db_utils/type_handling/tests/`

### Usage Example
\```r
source("scripts/global_scripts/02_db_utils/type_handling/fn_convert_r_to_duckdb.R")
df_clean <- convert_r_to_duckdb(df_raw)
dbWriteTable(con, "table", df_clean)
\```

### API Specification
\```yaml
function: convert_r_to_duckdb
input: data.frame
output: data.frame
transforms:
  - factor -> character
  - POSIXlt -> POSIXct
  - list -> JSON string
  - matrix -> multiple columns
\```
```

## Quick Win Targets

These changes can be implemented immediately with high impact:

### 1. Extract Utility Functions (2 hours)

Move these commonly used functions first:
- `safe_convert()` from DU08 → `02_db_utils/type_handling/fn_safe_convert.R`
- `handle_json_data()` from DU08 → `02_db_utils/complex_types/fn_handle_json_data.R`
- `flatten_list_column()` from DM_R024 → `02_db_utils/complex_types/fn_flatten_list_column.R`

### 2. Create Function Registry (1 hour)

**Create**: `02_db_utils/FUNCTION_INDEX.md`

```markdown
# DuckDB Utilities Function Index

## Type Handling
- `convert_r_to_duckdb()` - Convert R types to DuckDB compatible types
- `convert_duckdb_to_r()` - Convert DuckDB results to R types
- `safe_convert()` - Safe type conversion with error handling

## Complex Types
- `flatten_list_column()` - Flatten list columns for analysis
- `serialize_to_json()` - Convert complex types to JSON
- `handle_json_data()` - Process JSON columns from DuckDB

## Database Operations
- `safe_write_table()` - Write with type checking
- `batch_insert()` - Chunked insertion for large datasets
```

### 3. Create Test Template (30 minutes)

**Create**: `02_db_utils/test_template.R`

```r
# Test template for DuckDB utilities
library(testthat)

# Source the function to test
source("fn_your_function.R")

context("Function Name Tests")

test_that("basic functionality works", {
  # Arrange
  input <- data.frame(...)
  
  # Act
  result <- your_function(input)
  
  # Assert
  expect_equal(result, expected)
})

test_that("handles edge cases", {
  # Test NULL input
  expect_error(your_function(NULL))
  
  # Test empty data frame
  expect_equal(your_function(data.frame()), data.frame())
})

test_that("maintains data integrity", {
  # Test that no data is lost
  # Test that types are preserved correctly
})
```

## Validation Checklist

After refactoring each file:

- [ ] Function extracted to appropriate script folder
- [ ] Function has proper documentation header
- [ ] Test file created with at least 3 test cases
- [ ] Principle file updated to reference implementation
- [ ] IMPLEMENTATION_MAP.yaml updated
- [ ] Function works when sourced independently
- [ ] No code duplication remains

## Success Metrics

After Week 1:
- [ ] Zero implementation code in CH17_database_specifications principles
- [ ] All extracted functions have tests
- [ ] Master source file loads without errors
- [ ] At least one app successfully uses refactored functions

## Communication Template

When updating principles, use this commit message format:

```
refactor(principles): Extract [function_name] from [principle_id]

- Moved implementation to scripts/global_scripts/[path]
- Updated principle to reference implementation
- Added tests in [test_path]
- Follows code extraction pattern from REFACTORING_PROPOSAL.md

Refs: #principles-refactoring
```

## Next Steps After Week 1

1. **Week 2**: Extract ETL pipeline implementations
2. **Week 3**: Extract derivation functions
3. **Week 4**: Create Python equivalents for core functions
4. **Week 5**: Update all dependent applications

## Risk Mitigation

1. **Backup First**: Copy current principles to `00_principles/archive/pre-refactoring/`
2. **Test Continuously**: Run tests after each extraction
3. **Document Changes**: Keep detailed log in `CHANGELOG/refactoring_log.md`
4. **Incremental Updates**: Update apps one at a time, not all at once

## Getting Started NOW

1. Read `REFACTORING_PROPOSAL.md` for full context
2. Create the directory structure (Step 1 above)
3. Extract your first function (start with `safe_convert()`)
4. Create a test for it
5. Update the principle file to reference it
6. Commit with proper message format

This incremental approach ensures the refactoring can begin immediately while maintaining system stability.