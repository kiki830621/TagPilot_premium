---
id: "R100"
title: "Database Access via tbl() Rule"
type: "rule"
date_created: "2025-04-13"
date_modified: "2025-04-13"
author: "Claude"
derives_from:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
  - "P77": "Performance Optimization"
  - "R92": "Universal DBI Approach"
influences:
  - "P04": "App Construction Principles"
  - "R91": "Universal Data Access Pattern"
---

# Database Access via tbl() Rule

## Core Rule

When reading data from database connections, always prioritize using the `tbl()` function from the dplyr package instead of direct table reads or queries. The `tbl()` approach allows for lazy evaluation, query composition, and better integration with the tidyverse ecosystem.

## Implementation Guidelines

1. **Primary Access Pattern**:
   - Use `dplyr::tbl(conn, table_name)` followed by `dplyr::collect()` to retrieve data
   - For custom queries, use `dplyr::tbl(conn, dbplyr::sql(query_string))` followed by `collect()`
   - Only fall back to direct methods (`DBI::dbReadTable`, `DBI::dbGetQuery`) when dplyr is unavailable

2. **Dependency Management**:
   - Check for the availability of dplyr using `requireNamespace("dplyr", quietly = TRUE)`
   - Check for dbplyr when working with SQL queries using `requireNamespace("dbplyr", quietly = TRUE)`
   - Implement graceful fallbacks when dependencies are missing

3. **Query Composition**:
   - Leverage dplyr verbs on the table reference before collecting the results
   - Use `select()`, `filter()`, `mutate()`, etc. on the tbl reference for optimized query execution

4. **Lazy Evaluation**:
   - Take advantage of the lazy evaluation properties of tbl references
   - Only call `collect()` when the final result is needed
   - Use `show_query()` to inspect the generated SQL when debugging

5. **Error Handling**:
   - Implement proper error handling for both tbl and fallback approaches
   - Log the access method being used for debugging and auditing purposes

## Examples

### Correct Implementation

```r
# Preferred approach using tbl()
get_customer_data <- function(conn, customer_id = NULL) {
  # Get a reference to the table
  customers_ref <- dplyr::tbl(conn, "customer_profile")
  
  # Apply filters if needed (these are pushed to the database)
  if (!is.null(customer_id)) {
    customers_ref <- customers_ref %>% 
      dplyr::filter(customer_id == !!customer_id)
  }
  
  # Only collect at the end
  return(dplyr::collect(customers_ref))
}

# Custom query using tbl() with sql()
execute_complex_query <- function(conn, query_string) {
  result_ref <- dplyr::tbl(conn, dbplyr::sql(query_string))
  return(dplyr::collect(result_ref))
}
```

### Incorrect Implementation

```r
# Avoid direct table reads
get_customer_data <- function(conn, customer_id = NULL) {
  # Reading the entire table then filtering in R is inefficient
  customers <- DBI::dbReadTable(conn, "customer_profile")
  
  if (!is.null(customer_id)) {
    customers <- customers[customers$customer_id == customer_id, ]
  }
  
  return(customers)
}

# Avoid direct query execution for standard operations
execute_query <- function(conn) {
  # This bypasses the optimization benefits of dplyr
  return(DBI::dbGetQuery(conn, "SELECT * FROM customer_profile"))
}
```

## Integration with Universal Data Accessor

The Universal Data Accessor (R91) must implement this rule by:

1. Prioritizing the tbl() approach when handling database connections
2. Providing fallbacks for compatibility with environments lacking dplyr/dbplyr
3. Implementing proper logging of the access method used

## Backward Compatibility

To maintain backward compatibility:

1. Always include fallback methods for environments without dplyr/dbplyr
2. Ensure that results have consistent formats regardless of the access method
3. Verify that all database drivers work with both tbl() and direct methods
4. Log which method was used to aid in debugging connection-specific issues

## Benefits

- **Performance optimization**: Database operations are optimized through lazy evaluation
- **Code clarity**: Using dplyr syntax makes database operations more readable
- **Query composition**: Enables building complex queries incrementally
- **Tidyverse integration**: Better interoperability with other tidyverse packages
- **Consistent interface**: Provides a consistent interface across different database backends