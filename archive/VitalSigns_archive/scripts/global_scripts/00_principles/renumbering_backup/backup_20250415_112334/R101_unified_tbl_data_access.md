---
id: "R101"
title: "Unified tbl-like Data Access Pattern"
type: "rule"
date_created: "2025-04-13"
date_modified: "2025-04-13"
author: "Claude"
derives_from:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
  - "P77": "Performance Optimization"
  - "R91": "Universal Data Access Pattern"
  - "R100": "Database Access via tbl() Rule"
influences:
  - "P04": "App Construction Principles"
  - "R92": "Universal DBI Approach"
---

# Unified tbl-like Data Access Pattern

## Core Rule

All data sources, regardless of type (database, list, function, data frame), should be accessed using a consistent tbl()-like pattern that provides:

1. Lazy data access whenever possible
2. Consistent filter and select operations
3. A clear separation between data reference and data collection
4. Unified handling across different data sources

## Implementation Guidelines

1. **Unified Reference Model**:
   - Create data references rather than immediately fetching data
   - Implement a consistent pattern for all data types that mimics dplyr::tbl()
   - Support methods like filter(), select(), and collect() for all data types

2. **Lazy Evaluation**:
   - Delay actual data access until collect() is called
   - Build up operations (filters, projections) before data retrieval
   - Collect data only when the final result is needed

3. **Database Access**:
   - For DBI connections, use dplyr::tbl() and dbplyr as per R100
   - For non-DBI connections, implement a compatible interface that provides the same capabilities
   - Treat all data sources as reference objects initially

4. **Non-Database Sources**:
   - Wrap all non-database data sources in a compatible reference interface
   - Implement filter() and select() operations that can be applied to the data when collected
   - Support various access patterns (direct, function-based, etc.) with a uniform interface

5. **Uniform Interface**:
   - All data access should follow the same pattern, regardless of source type
   - Provide consistent fallbacks for different environments
   - Maintain compatibility with existing code

## Examples

### Unified Access Interface

```r
# Access pattern for any data source
data_ref <- get_data_reference(connection, "table_name")
filtered_ref <- data_ref %>% filter(column == value) %>% select(col1, col2)
result <- collect(filtered_ref)

# Database connection (uses dplyr::tbl internally)
db_conn <- DBI::dbConnect(...)
data_ref <- get_data_reference(db_conn, "customers")
result <- data_ref %>% 
  filter(status == "active") %>% 
  select(id, name, email) %>%
  collect()

# List connection (uses a tbl-like wrapper)
list_conn <- list(customers = data.frame(...))
data_ref <- get_data_reference(list_conn, "customers")
result <- data_ref %>% 
  filter(status == "active") %>% 
  select(id, name, email) %>%
  collect()

# Function-based connection (also uses a tbl-like wrapper)
fn_conn <- list(get_customers = function() { ... })
data_ref <- get_data_reference(fn_conn, "customers")
result <- data_ref %>% 
  filter(status == "active") %>% 
  select(id, name, email) %>%
  collect()
```

### Implementation in Universal Data Accessor

```r
# Create a unified reference for any data source
universal_data_reference <- function(connection, data_name) {
  # For DBI connections, use dplyr::tbl
  if (inherits(connection, "DBIConnection")) {
    return(dplyr::tbl(connection, data_name))
  }
  
  # For all other connection types, create a tbl-like reference
  return(create_tbl_ref(connection, data_name))
}

# Example usage
ref <- universal_data_reference(conn, "customers")
filtered_ref <- ref %>% filter(region == "East")
result <- collect(filtered_ref)
```

## Benefits

- **Consistency**: All data access follows the same pattern
- **Performance**: Operations can be optimized before data collection
- **Flexibility**: Works with any data source type
- **Maintainability**: Clear separation of concerns between data access and processing
- **Compatibility**: Seamless integration with tidyverse tools like dplyr

## Backward Compatibility

This pattern builds on R91 (Universal Data Access Pattern) and R100 (Database Access via tbl() Rule) but extends them to all data sources. For backward compatibility:

1. The universal_data_accessor function should maintain its current signature
2. Automatic conversion from the reference model to concrete data should happen internally
3. Fallback methods should be implemented for environments without dplyr

## Usage with Other Patterns

This pattern is designed to work seamlessly with:

- **R76** (Module Data Connection): Modules should receive data connection objects that work with this pattern
- **R91** (Universal Data Access Pattern): This extends R91 with more consistent handling
- **R100** (Database Access via tbl() Rule): This generalizes R100 to all data sources