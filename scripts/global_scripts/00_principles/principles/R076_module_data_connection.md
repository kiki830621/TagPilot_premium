# R0076: Module Data Connection Rule

## Statement
Server modules MUST receive data source connections rather than pre-filtered data.

## Description
This rule establishes that Shiny modules should follow a self-contained data access pattern where the module itself is responsible for selecting, filtering, and processing the data it needs from a central data source connection.

## Rationale
1. **Separation of Concerns**: Modules should handle their own data access logic internally.
2. **Testability**: Modules can be tested with different data sources without changing their internal logic.
3. **Consistency**: Creates a uniform pattern for all modules to follow.
4. **Maintainability**: Changes to data selection logic are contained within the module, reducing cross-module dependencies.
5. **Performance**: Allows modules to implement optimized data queries specific to their needs.

## Implementation Guide

### Module Server Function Signature
```r
moduleNameServer <- function(id, app_data_connection) {
  moduleServer(id, function(input, output, session) {
    # Query necessary data from app_data_connection
    # Filter records as needed
    # Implement module logic
  })
}
```

### Connection Types
The `app_data_connection` parameter can be one of:
1. A database connection object
2. A connection configuration (like a list of connection parameters)
3. A reactive data source that provides access to multiple datasets
4. A function that returns data when called with appropriate parameters

### Data Selection
Data selection and filtering MUST occur inside the module:

```r
# CORRECT implementation
data <- reactive({
  req(app_data_connection)
  
  # Query or access data from connection
  df <- app_data_connection$get_data("table_name")
  
  # Apply module-specific filtering
  df %>% filter(some_condition == TRUE)
})
```

### Anti-patterns

```r
# INCORRECT: Module receives pre-filtered data
moduleNameServer <- function(id, filtered_data) {
  moduleServer(id, function(input, output, session) {
    # Work with already filtered data
  })
}
```

## Examples

### Correct Implementation
```r
# Module receives connection, not data
customerModuleServer <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    # Module handles data selection internally
    customer_data <- reactive({
      req(app_data)
      app_data$get_customers() %>%
        filter(status == "active")
    })
    
    # ...rest of module implementation...
  })
}
```

### Usage
```r
# Usage in app.R
app_data <- setup_data_connection()
customerModuleServer("customer_module", app_data)
```

## Related Rules and Principles
- MP0017: Separation of Concerns
- R0009: UI-Server-Defaults Triple
- P0073: Server-to-UI Data Flow

#LOCK FILE
