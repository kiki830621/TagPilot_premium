---
id: "R0067"
title: "Functional Encapsulation Rule"
type: "rule"
date_created: "2025-04-08"
author: "Claude"
implements:
  - "MP0016": "Modularity Principle"
  - "MP0017": "Separation of Concerns"
  - "MP0018": "Don't Repeat Yourself"
related_to:
  - "R0021": "One Function One File"
  - "P0012": "app.R Is Global Principle"
---

# Functional Encapsulation Rule

## Core Principle

**All code blocks that exhibit functional characteristics must be explicitly encapsulated as named functions.** A code block is considered "function-like" if it has identifiable inputs (which may be implicit or null) and produces determinable outputs or side effects. Such code must never exist as anonymous, inline, or procedural blocks.

## Conceptual Framework

The Functional Encapsulation Metaprinciple establishes that code should be organized around the fundamental unit of a function. This metaprinciple recognizes that functional encapsulation:

1. **Improves Testability**: Encapsulated functions can be tested in isolation
2. **Enhances Reusability**: Named functions can be called from multiple contexts
3. **Clarifies Intent**: Function names document the purpose of code blocks
4. **Reduces Complexity**: Breaking code into functions simplifies reasoning
5. **Enables Composition**: Functions can be combined to build complex behavior

## Identifying Function-Like Code

A code block is considered "function-like" if it has one or more of these characteristics:

1. **Input Dependence**: It processes or operates on specific data inputs
2. **Output Generation**: It produces a defined result or data structure
3. **Side Effect Production**: It performs state changes or external interactions
4. **Error Handling**: It contains try/catch logic or error management
5. **Conditional Branching**: It contains complex conditional logic
6. **Iterative Processing**: It performs repetitive operations on data
7. **Logical Cohesion**: It performs a single conceptual operation
8. **Reuse Potential**: The same logic might be needed elsewhere

### Examples of Function-Like Code

The following patterns indicate code that should be encapsulated as functions:

```r
# Error handling patterns
tryCatch({
  # Complex operations...
}, error = function(e) {
  # Error handling...
})

# Loop processing
for (product in products) {
  # Complex transformations...
  if (condition) {
    # Special handling...
  }
}

# Conditional blocks with cohesive purpose
if (is_valid_data) {
  # Data validation with multiple steps
  # Transformations
  # State changes
}

# Complex calculations
result <- complex_expression + with_multiple + operations / that_form + a_logical_unit

# Initialization blocks
# Setup configuration
# Connect to resources
# Configure environment
```

## Implementation Requirements

### 1. Function Extraction

When encountering function-like code:

1. **Identify Boundaries**: Determine the logical start and end of the operation
2. **Identify Inputs**: Determine what external data the code block depends on
3. **Identify Outputs**: Determine what results or side effects the code produces
4. **Name Appropriately**: Choose a name that describes the operation's purpose
5. **Extract to Function**: Move the code to a named function

```r
# INCORRECT: Inline function-like code
if (data_available) {
  # Complex data manipulation with multiple steps
  processed_data <- data %>%
    filter(value > threshold) %>%
    group_by(category) %>%
    summarize(total = sum(value))
    
  # Additional operations
}

# CORRECT: Extracted function
process_data <- function(data, threshold) {
  if (!data_available) {
    return(NULL)
  }
  
  processed_data <- data %>%
    filter(value > threshold) %>%
    group_by(category) %>%
    summarize(total = sum(value))
    
  # Additional operations
  
  return(processed_data)
}

# Then call the function
processed_data <- process_data(data, threshold)
```

### 2. Function File Placement

Following R0021 (One Function One File):

1. **Create Dedicated File**: Each extracted function should be placed in its own file
2. **Proper Naming**: File should be named `fn_[function_name].R`
3. **Appropriate Location**: File should be placed in the appropriate directory based on functionality

### 3. Function Documentation

Each extracted function must include:

1. **Purpose Description**: What the function does
2. **Parameter Documentation**: What inputs the function accepts
3. **Return Documentation**: What the function returns
4. **Example Usage**: How to use the function
5. **Error Handling**: How the function manages errors

```r
#' Process data according to threshold criteria
#'
#' Filters data based on threshold, groups by category, and summarizes totals.
#'
#' @param data Data frame containing values to process
#' @param threshold Minimum value to include in processing
#' @return Processed data frame with totals by category, or NULL if data unavailable
#' @example
#' process_data(sales_data, 100)
#'
process_data <- function(data, threshold) {
  # Function implementation
}
```

### 4. Test Creation

For significant functions:

1. **Create Unit Tests**: Test the function in isolation
2. **Test Edge Cases**: Test boundary conditions and error handling
3. **Document Test Cases**: Explain what each test verifies

## Special Considerations

### 1. Anonymous Functions

Anonymous functions are acceptable only in very limited contexts:

1. **As Function Arguments**: When used as callbacks in higher-order functions
2. **In Reactive Expressions**: When used in simple reactive expressions
3. **For Simple Transformations**: When performing simple, one-line operations

```r
# ACCEPTABLE: Simple anonymous function as callback
lapply(products, function(x) x * 2)

# ACCEPTABLE: Simple anonymous function in reactive context
output$text <- renderText({ input$value * 2 })

# NOT ACCEPTABLE: Complex anonymous function
data %>% 
  group_by(category) %>%
  summarize(result = (function(x) {
    # Multiple operations
    # Conditional logic
    # Error handling
  })(value))
```

### 2. Small Utility Functions

Very small utility functions may be defined in the same file as their primary user if:

1. They are only used by one function
2. They implement a trivial operation
3. They would not be useful in other contexts

This is consistent with the R0021 exceptions for helper functions.

### 3. Higher-Order Functions

Higher-order functions that create or return functions are acceptable, but the returned function should be properly documented:

```r
#' Create a function that multiplies by a specific factor
#'
#' @param factor The multiplication factor
#' @return A function that multiplies its input by the specified factor
#'
create_multiplier <- function(factor) {
  #' Multiply a value by the preset factor
  #'
  #' @param x The value to multiply
  #' @return The value multiplied by the preset factor
  #'
  function(x) {
    x * factor
  }
}
```

## Implementation Process

### Step 1: Identify Function-Like Code

Review the codebase for code blocks that exhibit functional characteristics:

1. Complex procedural blocks
2. Error-handling blocks
3. Data processing blocks
4. Initialization sequences
5. Blocks with clear inputs and outputs

### Step 2: Extract Functions

For each identified code block:

1. Determine parameters based on what data the code block uses
2. Determine return value based on what data the code block produces
3. Create a properly named function with appropriate documentation
4. Replace the original code block with a function call

### Step 3: Refactor for Composition

After extracting functions:

1. Look for opportunities to compose functions
2. Identify common patterns that could be further abstracted
3. Ensure functions follow single responsibility principle

## Examples

### Example 1: Error Handling Block

#### Original Code

```r
# Try to connect to database
tryCatch({
  conn <- dbConnect(duckdb::duckdb(), "app_data.duckdb")
  message("Connected to database")
  
  # Check if required tables exist
  tables <- dbListTables(conn)
  if (!"customer_data" %in% tables) {
    warning("Customer data table not found")
    customer_available <- FALSE
  } else {
    # Check if table has data
    count <- dbGetQuery(conn, "SELECT COUNT(*) FROM customer_data")
    customer_available <- count > 0
    message("Customer data available: ", customer_available)
  }
}, error = function(e) {
  message("Error connecting to database: ", e$message)
  customer_available <- FALSE
})
```

#### Refactored Code

```r
#' Check availability of customer data in database
#'
#' Connects to the database and checks if the customer_data table exists and has data
#'
#' @param db_path Path to the database file
#' @return Boolean indicating if customer data is available
#'
check_customer_data_availability <- function(db_path = "app_data.duckdb") {
  tryCatch({
    conn <- dbConnect(duckdb::duckdb(), db_path)
    on.exit(dbDisconnect(conn), add = TRUE)
    message("Connected to database")
    
    # Check if required tables exist
    tables <- dbListTables(conn)
    if (!"customer_data" %in% tables) {
      warning("Customer data table not found")
      return(FALSE)
    }
    
    # Check if table has data
    count <- dbGetQuery(conn, "SELECT COUNT(*) FROM customer_data")
    result <- count > 0
    message("Customer data available: ", result)
    return(result)
  }, error = function(e) {
    message("Error connecting to database: ", e$message)
    return(FALSE)
  })
}

# Then call the function
customer_available <- check_customer_data_availability()
```

### Example 2: Initialization Block

#### Original Code

```r
# Initialize availability registry
availability_registry <- list()

# Initialize database connection
app_data_conn <- NULL
tryCatch({
  app_data_conn <- connect_to_app_database("app_data/app_data.duckdb")
  message("Connected to app_data.duckdb database")
  
  # Register database availability in registry
  availability_registry[["database"]] <- list(
    app_data = TRUE,
    connection_valid = TRUE
  )
}, error = function(e) {
  warning("Failed to connect to app_data.duckdb: ", e$message)
  
  # Register database unavailability
  availability_registry[["database"]] <- list(
    app_data = FALSE,
    connection_valid = FALSE
  )
})

# Initialize data availability detection
channel_availability <- detect_marketing_channel_availability(app_data_conn)

# Register channel availability in registry
availability_registry[["channel"]] <- channel_availability
```

#### Refactored Code

```r
#' Initialize data availability registry
#'
#' Sets up the availability registry with database and channel availability
#'
#' @param db_path Path to the database file
#' @return List containing the availability registry
#'
initialize_availability_registry <- function(db_path = "app_data/app_data.duckdb") {
  # Initialize availability registry
  availability_registry <- list()
  
  # Initialize database connection
  app_data_conn <- NULL
  tryCatch({
    app_data_conn <- connect_to_app_database(db_path)
    message("Connected to ", db_path, " database")
    
    # Register database availability in registry
    availability_registry[["database"]] <- list(
      app_data = TRUE,
      connection_valid = TRUE
    )
  }, error = function(e) {
    warning("Failed to connect to ", db_path, ": ", e$message)
    
    # Register database unavailability
    availability_registry[["database"]] <- list(
      app_data = FALSE,
      connection_valid = FALSE
    )
  })
  
  # Initialize data availability detection
  channel_availability <- detect_marketing_channel_availability(app_data_conn)
  
  # Register channel availability in registry
  availability_registry[["channel"]] <- channel_availability
  
  return(availability_registry)
}

# Then call the function
availability_registry <- initialize_availability_registry()
```

## Benefits

1. **Enhanced Testability**: Functions can be tested in isolation
2. **Improved Maintainability**: Functions are easier to update and debug
3. **Better Code Organization**: Functions provide natural modularity
4. **Clearer Intent**: Function names document what code does
5. **Reduced Duplication**: Functions promote code reuse
6. **Better Error Handling**: Functions provide clear boundaries for error management
7. **Consistent Architecture**: Function-based code follows consistent patterns

## Relationship to Other Principles

This metaprinciple:

1. **Derives from MP0016 (Modularity)** by enforcing function-level modularity
2. **Derives from MP0017 (Separation of Concerns)** by isolating different operations
3. **Derives from MP0018 (Don't Repeat Yourself)** by enabling code reuse
4. **Influences R0021 (One Function One File)** by identifying what should be in dedicated files
5. **Influences P0012 (app.R Is Global)** by removing function-like code from app.R

## Conclusion

The Functional Encapsulation Metaprinciple establishes that all function-like code blocks should be explicitly encapsulated as named functions. By following this principle, we create code that is more testable, maintainable, and reusable, while reducing complexity and improving clarity. This approach leads to a more modular, composable codebase that better aligns with the functional programming paradigm.

By rigorously applying this principle, we eliminate "anonymous execution blocks" and procedural code patterns that make systems harder to understand and maintain, creating a codebase that is more robust, flexible, and easier to reason about.
