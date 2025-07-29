# R89: Integer ID Type Conversion Rule

## Statement
All system identifiers must be explicitly converted to integer type when used in data operations.

## Description
This rule enforces consistent type handling of IDs throughout an application, particularly at system boundaries where type conversion is likely to occur. It ensures that all IDs are explicitly converted to integers before being used in filtering, joining, or other data operations.

## Rationale
1. **Type Safety**: Prevents subtle bugs from implicit type conversion
2. **Performance**: Integer comparisons are faster than string comparisons
3. **Predictability**: Ensures consistent behavior regardless of data source
4. **Reliability**: Avoids errors in data filtering and joining operations

## Implementation Guide

### Module Function Parameters
When a module receives an ID parameter, convert it to integer immediately:

```r
customerModule <- function(id, customer_id) {
  # Convert ID to integer immediately upon receipt
  customer_id <- as.integer(customer_id)
  
  # Use the integer ID for all subsequent operations
  # ...
}
```

### UI Input Handling
When receiving user input values that represent IDs, convert them to integers before use:

```r
observeEvent(input$customer_select, {
  # Convert the selected ID to integer
  selected_id <- as.integer(input$customer_select)
  
  # Use the selected ID to filter data
  filtered_data <- data %>% filter(customer_id == selected_id)
})
```

### Data Filtering
Always convert ID values to integers when filtering data frames:

```r
# CORRECT: Explicit integer conversion before filtering
filter_customers_by_id <- function(data, id_value) {
  # Ensure integer type
  id_value <- as.integer(id_value)
  
  # Then filter
  filtered <- data %>% filter(customer_id == id_value)
  return(filtered)
}
```

### Anti-patterns

#### Implicit Type Conversion
```r
# INCORRECT: Relies on implicit type conversion
data %>% filter(customer_id == input$customer_select)

# CORRECT: Explicit type conversion
data %>% filter(customer_id == as.integer(input$customer_select))
```

#### Missing Error Handling
```r
# INCORRECT: No error handling for non-numeric input
as.integer(input$customer_select)

# CORRECT: Proper error handling
tryCatch({
  selected_id <- as.integer(input$customer_select)
  if (is.na(selected_id)) {
    stop("Invalid customer ID")
  }
}, error = function(e) {
  # Handle the error (e.g., show a message to the user)
  showNotification("Please select a valid customer", type = "error")
})
```

## Examples

### Standard ID Conversion Function
```r
safe_as_integer <- function(x, default = NA_integer_) {
  if (is.null(x) || length(x) == 0) {
    return(default)
  }
  
  result <- tryCatch({
    as.integer(x)
  }, warning = function(w) {
    default
  }, error = function(e) {
    default
  })
  
  if (is.na(result)) {
    result <- default
  }
  
  return(result)
}
```

### Complete Example with Error Handling
```r
moduleServer("customer_module", function(input, output, session) {
  # Reactive expression for filtered data
  filtered_data <- reactive({
    # Validate that a selection exists
    req(input$customer_select)
    
    # Try to convert the selected ID to integer
    id <- tryCatch({
      id <- as.integer(input$customer_select)
      if (is.na(id)) {
        showNotification("Invalid customer ID format", type = "error")
        return(NULL)
      }
      id
    }, error = function(e) {
      showNotification("Error processing customer ID", type = "error")
      return(NULL)
    })
    
    # Only filter if we have a valid ID
    if (!is.null(id)) {
      data <- customers_data %>% filter(customer_id == id)
      if (nrow(data) == 0) {
        showNotification("No customer found with ID " + id, type = "warning")
      }
      return(data)
    }
    
    return(NULL)
  })
})
```

### Module Accepting an ID Parameter
```r
customerViewModule <- function(id, customer_id = NULL) {
  moduleServer(id, function(input, output, session) {
    # Initialize reactive value for selected customer
    selected_customer_id <- reactiveVal(NULL)
    
    # If customer_id is provided, use it after conversion
    observe({
      if (!is.null(customer_id)) {
        # Convert to integer and validate
        id <- as.integer(customer_id)
        if (!is.na(id)) {
          selected_customer_id(id)
        }
      }
    })
    
    # When user changes selection
    observeEvent(input$customer_select, {
      id <- as.integer(input$customer_select)
      if (!is.na(id)) {
        selected_customer_id(id)
      }
    })
    
    # Reactive for customer data
    customer_data <- reactive({
      id <- selected_customer_id()
      req(id)
      
      # Use the integer id for data filtering
      customers %>% filter(customer_id == id)
    })
  })
}
```

## Related Rules and Principles
- P80: Integer ID Consistency Principle
- R76: Module Data Connection Rule
- R88: Shiny Module ID Handling
- R90: ID Relationship Validation
- MP52: Unidirectional Data Flow