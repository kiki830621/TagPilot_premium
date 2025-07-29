---
id: "R92"
title: "Universal DBI Approach"
type: "rule"
date_created: "2025-04-10"
date_modified: "2025-04-10"
author: "Claude"
implements:
  - "MP16": "Modularity"
  - "MP17": "Separation of Concerns"
  - "MP52": "Unidirectional Data Flow"
related_to:
  - "R76": "Module Data Connection Rule"
  - "R91": "Universal Data Access Pattern"
  - "P76": "Error Handling Patterns"
  - "P77": "Performance Optimization"
---

# Universal DBI Approach

## Core Requirement

All data access in precision marketing applications must use a consistent Database Interface (DBI) pattern, where data is accessed exclusively through database connection objects (real or mock) using standardized query methods, ensuring consistent data flow regardless of the actual data source.

## Pattern Description

The Universal DBI Approach standardizes how data is accessed throughout the application by enforcing a database-centric access pattern. This creates a clear separation between data storage and application logic, improves testability, and enables seamless transitions between development, testing, and production environments.

### 1. Central Connection Management

Applications must establish database connections through a central factory:

```r
# In app.R
app_db_conn <- initialize_app_db_connection()

# Server function uses the connection
server <- function(input, output, session) {
  # Make connection available to all modules
  moduleServer("module1", function(input, output, session) {
    # Module uses the connection  
  }, app_db_conn)
}
```

### 2. Consistent Access Patterns

All data retrieval must use the same patterns, regardless of whether the data comes from a real database or mock data:

```r
# Inside a module server function
getData <- reactive({
  req(app_data_connection)
  
  # Use universal_data_accessor with any connection type
  universal_data_accessor(
    app_data_connection, 
    "customer_profile"
  )
})
```

### 3. Environment Adaptability

Applications must adapt to different environments without code changes:

- **Production**: Uses real database connections
- **Development**: Can use mock connections with sample data
- **Testing**: Uses deterministic mock data

### 4. Interface Standardization

All database access must follow standard DBI patterns:

- Use `dbGetQuery()` for data retrieval
- Use `dbWriteTable()` and `dbExecute()` for data modification
- Use `dbListTables()` for schema introspection

## Implementation

### 1. Connection Factory

Use the provided connection factory to create database connections:

```r
# Production connection
conn <- db_connection_factory("production")

# Development connection with mock data
conn <- db_connection_factory("development", 
                             mock_data_list = test_data)
```

### 2. Universal Data Accessor

Use the universal data accessor for all data retrieval:

```r
customer_data <- universal_data_accessor(
  conn, 
  "customer_profile",
  query_template = "SELECT * FROM {table_name} WHERE status = 'active'"
)
```

### 3. Mock DBI for Testing

Use mock DBI connections for testing:

```r
# Create test data
test_data <- list(
  customer_profile = data.frame(...),
  dna_by_customer = data.frame(...)
)

# Create mock connection
mock_conn <- list_to_mock_dbi(test_data)

# Run tests with mock connection
test_result <- test_module(mock_conn)
```

## Benefits

1. **Consistency**: Uniform data access patterns across the application
2. **Testability**: Easier to test with mock data
3. **Separation of Concerns**: Data storage decoupled from application logic
4. **Performance**: Database operations can be optimized centrally
5. **Scalability**: Easy transition path from development to production
6. **Maintainability**: Centralized data access simplifies updates

## Relationship to Other Rules and Principles

This rule implements:
- **MP16 (Modularity)**: By creating clear boundaries between data access and application logic
- **MP17 (Separation of Concerns)**: By isolating data storage details from data usage
- **MP52 (Unidirectional Data Flow)**: By establishing a clear flow from database to UI

It relates to:
- **R76 (Module Data Connection Rule)**: By standardizing how modules receive and use data connections
- **R91 (Universal Data Access Pattern)**: By providing a common implementation approach
- **P76 (Error Handling Patterns)**: By standardizing error handling in data access
- **P77 (Performance Optimization)**: By enabling central optimization of data operations

## Code Example

Example application structure implementing the Universal DBI Approach:

```r
# app.R
library(shiny)
library(dplyr)

# 1. Source required utilities
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_db_connection_factory.R")
source("update_scripts/global_scripts/00_principles/02_db_utils/fn_universal_data_accessor.R")

# 2. Initialize database connection
app_db_conn <- initialize_app_db_connection()

# 3. UI Definition
ui <- fluidPage(
  titlePanel("Universal DBI Approach Example"),
  sidebarLayout(
    sidebarPanel(
      # Customer module UI
      microCustomerFilterUI("customer_module")
    ),
    mainPanel(
      # Customer display UI
      microCustomerUI("customer_module"),
      # Debug info
      verbatimTextOutput("connection_info")
    )
  )
)

# 4. Server function
server <- function(input, output, session) {
  # Initialize modules with the database connection
  filtered_data <- microCustomerServer("customer_module", app_db_conn)
  
  # Display connection information
  output$connection_info <- renderPrint({
    get_connection_info(app_db_conn)
  })
}

# 5. Run the application
shinyApp(ui, server)
```

## Testing Approach

When using the Universal DBI Approach, tests should:

1. Create mock connections with deterministic test data
2. Pass these connections to components and modules
3. Verify outputs based on known inputs
4. Test both normal and error conditions

Example test:

```r
test_that("Customer module displays correct data", {
  # Create mock connection with test data
  mock_conn <- list_to_mock_dbi(list(
    customer_profile = data.frame(
      customer_id = 1:3,
      buyer_name = c("Test 1", "Test 2", "Test 3")
    ),
    dna_by_customer = data.frame(
      customer_id = 1:2,
      r_value = c(5, 10)
    )
  ))
  
  # Test the module
  testServer(microCustomerServer, args = list(app_data_connection = mock_conn), {
    # Verify correct initialization
    expect_equal(length(valid_customer_ids()), 2)
    
    # Simulate user interaction
    session$setInputs(customer_filter = "1")
    
    # Verify result
    expect_equal(filtered_data()$customer_id, 1)
  })
})
```

## Conclusion

The Universal DBI Approach standardizes data access throughout the application, creating a clear separation between data storage and application logic. By using this approach, the application becomes more testable, maintainable, and capable of scaling from development to production environments without significant code changes.

This rule is fundamental to maintaining consistency in data flow patterns and ensuring that all components interact with data through a well-defined and predictable interface.