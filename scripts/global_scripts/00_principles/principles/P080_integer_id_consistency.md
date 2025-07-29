# P0080: Integer ID Consistency Principle

## Statement
System identifiers shall be implemented as integers for data relationships, with consistent type handling across all application layers.

## Description
This principle establishes that primary identifiers in data systems should be implemented as integers to ensure optimal performance, consistency, and compatibility across the data pipeline. It governs how IDs are handled from database storage through server processing to UI presentation.

## Rationale
1. **Performance**: Integer IDs provide optimal storage and comparison performance
2. **Consistency**: Using a single data type for IDs avoids type conversion issues
3. **Reliability**: Prevents string comparison errors in filtering and joining operations
4. **Clarity**: Makes relationships between data entities explicit and unambiguous
5. **Compatibility**: Ensures consistent behavior across different system components

## Implementation Patterns

### Database Schema
```sql
CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  name VARCHAR(255),
  email VARCHAR(255)
);

CREATE TABLE transactions (
  transaction_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  amount DECIMAL(10,2),
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);
```

### Data Access Layer
```r
get_customer_by_id <- function(id) {
  # Ensure id is treated as an integer
  id <- as.integer(id)
  
  # Query customer data
  query <- sprintf("SELECT * FROM customers WHERE customer_id = %d", id)
  result <- dbGetQuery(conn, query)
  
  return(result)
}
```

### Server Processing
```r
# R code for filtering by customer_id
filter_customer_data <- function(data, customer_id) {
  # Ensure consistent type handling
  customer_id <- as.integer(customer_id)
  
  # Filter data
  filtered_data <- data %>%
    filter(customer_id == !!customer_id)
  
  return(filtered_data)
}
```

### User Interface
```r
# When rendering customer choices in a dropdown
customer_choices <- setNames(
  as.character(customers$customer_id),  # Convert to character for UI display
  customers$name
)

# When receiving selection from UI
observeEvent(input$customer_select, {
  # Convert back to integer for data operations
  selected_id <- as.integer(input$customer_select)
  
  # Process the selection...
})
```

## Anti-patterns

### Inconsistent Type Handling
```r
# INCORRECT: Inconsistent type handling can cause filter mismatches
customers %>% filter(customer_id == input$customer_select)  # String vs Integer comparison!

# CORRECT: Ensure type consistency
customers %>% filter(customer_id == as.integer(input$customer_select))
```

### String-Based IDs
```r
# INCORRECT: Using string-based IDs
customer_data$id <- paste0("CUST_", seq_len(nrow(customer_data)))

# CORRECT: Using integer IDs with separate type field if needed
customer_data$id <- seq_len(nrow(customer_data))
customer_data$type <- "CUST"
```

### Mixed ID Types
```r
# INCORRECT: Mixing ID types in joined data
left_join(customers, transactions, by = c("customer_id" = "cust_id"))  # Potentially different types

# CORRECT: Standardizing ID field names and types
left_join(customers, transactions, by = "customer_id")  # Same named field, same type
```

## Examples

### ID Type Conversion Utility
```r
# Utility function for standardizing ID handling
ensure_integer_id <- function(id, allow_null = FALSE) {
  if (is.null(id)) {
    if (allow_null) return(NULL)
    stop("ID cannot be NULL")
  }
  
  # Handle vector case
  if (length(id) > 1) {
    return(sapply(id, ensure_integer_id))
  }
  
  # Convert various input formats to integer
  if (is.character(id)) {
    # Remove any non-numeric characters
    id <- gsub("[^0-9]", "", id)
    if (id == "") {
      if (allow_null) return(NULL)
      stop("ID contains no numeric characters")
    }
  }
  
  return(as.integer(id))
}
```

### Complete Customer Module Example
```r
# Customer module with proper ID handling
customerModuleServer <- function(id, data_source) {
  moduleServer(id, function(input, output, session) {
    # When user selects a customer
    observeEvent(input$customer_select, {
      # Proper ID type handling
      selected_id <- as.integer(input$customer_select)
      
      # Get customer data using the integer ID
      customer_data <- data_source$get_customer(selected_id)
      
      # Update UI
      output$customer_name <- renderText(customer_data$name)
    })
  })
}
```

## Related Principles
- MP0052: Unidirectional Data Flow
- P0073: Server-to-UI Data Flow
- R0076: Module Data Connection Rule
- R0088: Shiny Module ID Handling
- R0089: Integer ID Type Conversion
- R0090: ID Relationship Validation
