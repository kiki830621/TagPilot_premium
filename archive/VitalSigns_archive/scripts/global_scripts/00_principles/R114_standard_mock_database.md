---
id: "R0114"
title: "Standard Mock Database Rule"
type: "rule"
date_created: "2025-04-19"
author: "Claude"
implements:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
  - "MP0051": "Test Data Design"
related_to:
  - "R0074": "Shiny Test Data Rule"
  - "R0091": "Universal Data Access Pattern"
  - "R0092": "Universal DBI Approach"
  - "P0009": "Authentic Context Testing"
---

# Standard Mock Database Rule

## Core Requirement

All testing, development, and demonstration environments must use the standardized `mock_data.duckdb` database located in the `global_scripts/global_data` directory as the primary mock data source, ensuring consistent testing data across the application.

## Pattern Description

The Standard Mock Database Rule establishes a single source of truth for mock data by centralizing it in a DuckDB database file. This approach standardizes the test data environment, ensures consistency across different development and testing contexts, and provides a realistic simulation of production data access patterns.

### 1. Standardized Location and Format

The mock database must be:

- Located at `global_scripts/global_data/mock_data.duckdb`
- Initialized using the provided script `sc_create_mock_duckdb.R`
- Maintained with version control to ensure consistency
- Accessed using standard DBI connection patterns

```r
# Standard way to connect to mock database
mock_db_path <- file.path("update_scripts", "global_scripts", "global_data", "mock_data.duckdb")
mock_db_conn <- DBI::dbConnect(duckdb::duckdb(), dbdir = mock_db_path, read_only = TRUE)
```

### 2. Consistent Data Model

The mock database must maintain a consistent data model that:

- Reflects the structure of production data
- Includes all standard tables required for basic functionality
- Contains appropriate sample data for various test scenarios
- Preserves relationships between tables

### 3. Integration with Testing Framework

All tests must use the standard mock database:

```r
# Test setup
setup({
  # Connect to the standard mock database
  test_conn <- DBI::dbConnect(duckdb::duckdb(), 
                             dbdir = "../global_data/mock_data.duckdb", 
                             read_only = TRUE)
  
  # Make connection available to tests
  assign("test_conn", test_conn, envir = parent.frame())
})

# Test teardown
teardown({
  # Disconnect from database
  DBI::dbDisconnect(test_conn, shutdown = TRUE)
})

# Test example
test_that("Component retrieves customer data", {
  # Use the standard connection
  result <- universal_data_accessor(test_conn, "customer_profile")
  
  # Test against known data in mock database
  expect_equal(nrow(result), 3)  # Known row count in mock database
  expect_true("name" %in% colnames(result))
})
```

## Implementation

### 1. Database Initialization

Use the provided script to initialize or update the mock database:

```r
# Run from the 01_db directory
source("sc_create_mock_duckdb.R")
```

### 2. Connection Factory Configuration

Configure the connection factory to use the standard mock database in development mode:

```r
# In db_connection_factory.R
db_connection_factory <- function(mode = "development", ...) {
  if (mode == "development" || mode == "testing") {
    # Use the standard mock database
    mock_db_path <- file.path(find_project_root(), "update_scripts", 
                             "global_scripts", "global_data", "mock_data.duckdb")
    return(DBI::dbConnect(duckdb::duckdb(), dbdir = mock_db_path, read_only = TRUE))
  } else {
    # Production connection logic
    # ...
  }
}
```

### 3. Test Fixture Integration

Create a standard test fixture function that provides the mock database connection:

```r
# In test_helpers.R
get_test_db_connection <- function() {
  # Get path relative to the current script
  script_dir <- dirname(sys.frame(1)$ofile)
  proj_root <- dirname(dirname(dirname(script_dir)))
  
  mock_db_path <- file.path(proj_root, "update_scripts", 
                           "global_scripts", "global_data", "mock_data.duckdb")
  
  # Connect to the standard mock database
  DBI::dbConnect(duckdb::duckdb(), dbdir = mock_db_path, read_only = TRUE)
}
```

## Benefits

1. **Consistency**: Ensures all testing uses the same baseline data
2. **Realism**: More closely simulates production database interactions
3. **Maintainability**: Centralizes test data definitions
4. **Efficiency**: Eliminates need to recreate similar test data across tests
5. **Completeness**: Provides a comprehensive data environment with proper relationships
6. **Version Control**: Enables tracking changes to test data alongside code

## Relationship to Other Rules and Principles

This rule implements:
- **MP0016 (Modularity)**: By providing a modular data source for testing
- **MP0017 (Separation of Concerns)**: By separating test data from test logic
- **MP0051 (Test Data Design)**: By establishing standards for test data design

It relates to:
- **R0074 (Shiny Test Data Rule)**: By providing a database implementation of test data patterns
- **R0091 (Universal Data Access Pattern)**: By establishing a standard data source for testing
- **R0092 (Universal DBI Approach)**: By enforcing DBI access patterns in testing
- **P0009 (Authentic Context Testing)**: By creating a realistic test environment

## Code Example

Example using the standard mock database in a component test:

```r
# test_microCustomer.R
library(testthat)
library(shiny)
library(DBI)
library(duckdb)

# Source component
source("../../10_rshinyapp_components/micro/microCustomer/microCustomer.R")

# Test setup
test_conn <- NULL

setup({
  # Get standard mock database connection
  mock_db_path <- normalizePath("../../global_data/mock_data.duckdb", mustWork = TRUE)
  test_conn <<- DBI::dbConnect(duckdb::duckdb(), dbdir = mock_db_path, read_only = TRUE)
})

teardown({
  # Cleanup
  if (!is.null(test_conn) && DBI::dbIsValid(test_conn)) {
    DBI::dbDisconnect(test_conn, shutdown = TRUE)
  }
})

test_that("microCustomer component loads customer data", {
  # Test using testServer
  testServer(microCustomerServer, args = list(app_data_connection = test_conn), {
    # Get available customer IDs
    expect_true(length(customer_ids()) > 0)
    
    # Verify data structure matches expected mock data
    customers <- customer_data()
    expect_true(all(c("id", "name", "signup_date") %in% colnames(customers)))
  })
})
```

## Database Structure

The standard mock database includes these base tables:

1. **customer_profile**: Basic customer information
   - id: Customer identifier
   - name: Customer name
   - signup_date: Registration date

2. **orders**: Purchase records
   - order_id: Order identifier
   - customer_id: Reference to customer
   - amount: Purchase amount
   - order_date: Date of purchase

Additional tables can be added to the standard database as needed, with proper documentation and consistency.

## Extending the Mock Database

When extending the mock database:

1. Update the `sc_create_mock_duckdb.R` script with new tables
2. Document the changes in the script comments
3. Update all dependent tests if structural changes are made
4. Commit the updated script to version control (not the database file itself)

## Exceptions

In specific cases where specialized test data is required that cannot be accommodated in the standard mock database, tests may use alternative data sources, but must document the reason for deviation.

## Conclusion

The Standard Mock Database Rule establishes a consistent approach to test data by centralizing it in a standard DuckDB database. This approach improves testing consistency, reduces duplication, and creates a more realistic test environment that closely mirrors production data access patterns. By using this rule, all components can be tested against the same baseline data, ensuring consistent behavior across the application.