---
id: "R0091"
title: "Universal Data Access Pattern"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Claude"
implements:
  - "MP0016": "Modularity"
  - "MP0017": "Separation of Concerns"
related_to:
  - "R0076": "Module Data Connection Rule"
  - "P0076": "Error Handling Patterns"
  - "P0077": "Performance Optimization"
---

# Universal Data Access Pattern

## Core Requirement

Components that require data access must use the Universal Data Access pattern to handle multiple connection types transparently, ensuring that modules remain independent of the specific data source implementation, whether it's a direct database connection, reactive expression, or different forms of data storage.

## Pattern Description

The Universal Data Access pattern provides a standardized approach to accessing data from various sources. It abstracts away the details of how data is stored or accessed, creating a consistent interface for components to retrieve the data they need regardless of the source.

### 1. Connection Type Independence

Components must be designed to work with multiple connection types:

1. **DBI database connections**: Direct SQL database connections (DuckDB, SQLite, PostgreSQL, etc.)
2. **Reactive expressions**: Shiny reactive expressions that return data or connections
3. **Function-based connections**: Lists containing accessor functions (`get_*`, `query_*`)
4. **Direct data references**: Lists containing data frames directly
5. **Data frames**: Direct data frame inputs

### 2. Implementation Approach

The Universal Data Access pattern is implemented through a central utility function with the following capabilities:

```r
universal_data_accessor(
  data_connection,  # The connection object (any of the types above)
  data_name,        # The name of the data to retrieve
  query_template = NULL,  # Optional SQL template
  log_level = 2,    # Logging verbosity
  additional_params = list()  # Additional configuration
)
```

This function:
1. Detects the connection type
2. Applies the appropriate data retrieval mechanism 
3. Validates and returns the data as a consistent data frame

### 3. Module Implementation

Modules using this pattern should follow these guidelines:

```r
# In a module server function
moduleServer(id, function(input, output, session) {
  # Create reactive data sources
  df_data <- reactive({
    req(app_data_connection)
    
    # Use universal accessor
    universal_data_accessor(app_data_connection, "my_data_name")
  })
  
  # Use the data...
})
```

### 4. Testing Support

The pattern includes utilities for creating mock connections to support testing:

```r
# Create test data
test_data <- list(
  customer_profile = data.frame(id = 1:3, name = c("A", "B", "C")),
  dna_by_customer = data.frame(customer_id = 1:3, value = 10:12)
)

# Create a mock DBI connection
mock_conn <- create_mock_connection(test_data, "dbi")

# Create a reactive connection for Shiny testing
reactive_conn <- create_reactive_data_connection(mock_conn)
```

## Benefits

1. **Decoupling**: Components are independent of specific data source implementations
2. **Flexibility**: Supports multiple connection types without code changes
3. **Testability**: Enables easy mocking of connections for testing
4. **Consistency**: Provides a uniform data retrieval pattern across components
5. **Error Handling**: Centralizes error handling logic for data access
6. **Performance**: Optimizes data access based on the connection type

## Relationship to Other Rules and Principles

This rule implements:
- **MP0016 (Modularity)**: By isolating data access from business logic
- **MP0017 (Separation of Concerns)**: By separating data access patterns from module functionality

It relates to:
- **R0076 (Module Data Connection Rule)**: By providing a standard implementation of data connections
- **P0076 (Error Handling Patterns)**: By incorporating structured error handling for data access
- **P0077 (Performance Optimization)**: By optimizing data retrieval based on connection type

## Code Example

Here's a comprehensive example showing the pattern in action:

```r
# In a Shiny app server function
server <- function(input, output, session) {
  # Create database connection
  db_conn <- reactive({
    # Connect to database if needed
    DBI::dbConnect(duckdb::duckdb(), "app_data.duckdb")
  })
  
  # Initialize customer module with data connection
  customerModule("customer_section", data_connection = db_conn)
}

# In the customer module
customerModule <- function(id, data_connection) {
  moduleServer(id, function(input, output, session) {
    # Get customer data using universal accessor
    customer_data <- reactive({
      req(data_connection)
      universal_data_accessor(data_connection, "customer_profile")
    })
    
    # Use the data...
    output$customer_table <- renderTable({
      head(customer_data())
    })
  })
}
```

## Implementation

The Universal Data Access pattern is implemented in the `fn_universal_data_accessor.R` file, which provides:

1. `universal_data_accessor()`: The main function for accessing data from any connection type
2. `create_mock_connection()`: A utility for creating test connections
3. `create_reactive_data_connection()`: A utility for creating reactive connections for Shiny

## Conclusion

By following the Universal Data Access pattern, components can be built to work seamlessly with different data source implementations. This enhances modularity, testing capabilities, and the overall robustness of the application while aligning with key architectural principles.
