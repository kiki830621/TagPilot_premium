# R0090: ID Relationship Validation Rule

## Statement
Applications must validate the existence and relationship of IDs before data operations.

## Description
This rule ensures that IDs used for data relationships are validated for existence and proper relationships before performing data operations. It prevents errors from operations on non-existent entities and maintains data integrity by enforcing proper relationship validation.

## Rationale
1. **Data Integrity**: Ensures operations only occur on valid data relationships
2. **Error Prevention**: Avoids runtime errors due to invalid ID references
3. **User Experience**: Provides meaningful feedback for invalid selections
4. **Debugging**: Makes relationship errors easier to diagnose and fix
5. **Reliability**: Reduces unexpected behavior from invalid data relationships

## Implementation Guide

### ID Existence Validation
Before using an ID for data operations, validate that it exists in the source data:

```r
validate_customer_id <- function(customer_id, data_source) {
  # Ensure integer type
  customer_id <- as.integer(customer_id)
  
  # Check existence
  if (!customer_id %in% data_source$customer_ids) {
    return(FALSE)
  }
  
  return(TRUE)
}
```

### Relationship Validation
When joining tables or accessing related data, validate the relationship exists:

```r
validate_customer_transaction_relationship <- function(customer_id, transaction_id, data_source) {
  # Ensure integer types
  customer_id <- as.integer(customer_id)
  transaction_id <- as.integer(transaction_id)
  
  # Check if transaction belongs to customer
  transaction <- data_source$get_transaction(transaction_id)
  
  if (is.null(transaction) || transaction$customer_id != customer_id) {
    return(FALSE)
  }
  
  return(TRUE)
}
```

### Reactive Validation in Shiny
Implement validation in reactive contexts:

```r
# Reactive validation expression
valid_customer <- reactive({
  req(input$customer_select)
  
  # Convert and validate
  customer_id <- as.integer(input$customer_select)
  exists <- customer_id %in% customer_data$customer_id
  
  if (!exists) {
    showNotification("Selected customer no longer exists", type = "error")
    return(FALSE)
  }
  
  return(TRUE)
})

# Use validation in output
output$customer_details <- renderUI({
  req(valid_customer())
  
  # Now we can safely use the customer ID
  customer_id <- as.integer(input$customer_select)
  customer <- customer_data %>% filter(customer_id == customer_id)
  
  # Render customer details...
})
```

### Anti-patterns

#### Unchecked ID Usage
```r
# INCORRECT: No validation before filtering
customer_details <- reactive({
  selected_id <- as.integer(input$customer_select)
  customers %>% filter(customer_id == selected_id)
})

# CORRECT: Validate ID before use
customer_details <- reactive({
  selected_id <- as.integer(input$customer_select)
  
  # Validate ID exists
  if (!selected_id %in% customers$customer_id) {
    showNotification("Invalid customer selection", type = "error")
    return(NULL)
  }
  
  customers %>% filter(customer_id == selected_id)
})
```

#### Missing Relationship Validation
```r
# INCORRECT: No validation of relationship
display_transaction <- function(customer_id, transaction_id) {
  customer <- get_customer(customer_id)
  transaction <- get_transaction(transaction_id)
  
  # Display details without validating relationship
}

# CORRECT: Validate relationship before display
display_transaction <- function(customer_id, transaction_id) {
  # Validate both exist
  customer <- get_customer(customer_id)
  transaction <- get_transaction(transaction_id)
  
  if (is.null(customer) || is.null(transaction)) {
    return("Customer or transaction not found")
  }
  
  # Validate relationship
  if (transaction$customer_id != customer_id) {
    return("Transaction does not belong to this customer")
  }
  
  # Now safe to display
}
```

## Examples

### Complete ID Validation Example
```r
# Validator class for ID relationships
IDValidator <- R006Class("IDValidator",
  public = list(
    data_source = NULL,
    
    initialize = function(data_source) {
      self$data_source <- data_source
    },
    
    validate_customer = function(customer_id) {
      if (is.null(customer_id) || is.na(customer_id)) return(FALSE)
      
      customer_id <- as.integer(customer_id)
      customer_exists <- customer_id %in% self$data_source$customers$customer_id
      
      if (!customer_exists) {
        log_warning(paste("Invalid customer ID:", customer_id))
      }
      
      return(customer_exists)
    },
    
    validate_transaction = function(transaction_id) {
      if (is.null(transaction_id) || is.na(transaction_id)) return(FALSE)
      
      transaction_id <- as.integer(transaction_id)
      transaction_exists <- transaction_id %in% self$data_source$transactions$transaction_id
      
      if (!transaction_exists) {
        log_warning(paste("Invalid transaction ID:", transaction_id))
      }
      
      return(transaction_exists)
    },
    
    validate_customer_transaction = function(customer_id, transaction_id) {
      # First validate both exist
      if (!self$validate_customer(customer_id)) return(FALSE)
      if (!self$validate_transaction(transaction_id)) return(FALSE)
      
      # Then validate relationship
      customer_id <- as.integer(customer_id)
      transaction_id <- as.integer(transaction_id)
      
      transaction <- self$data_source$transactions %>%
        filter(transaction_id == transaction_id) %>%
        head(1)
      
      relationship_valid <- !is.null(transaction) && 
                            nrow(transaction) > 0 && 
                            transaction$customer_id == customer_id
      
      if (!relationship_valid) {
        log_warning(paste("Transaction", transaction_id, "does not belong to customer", customer_id))
      }
      
      return(relationship_valid)
    }
  )
)
```

### Using the Validator in a Module
```r
transaction_module <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    # Create validator
    validator <- IDValidator$new(app_data)
    
    # Validation reactive
    valid_selection <- reactive({
      req(input$customer_select, input$transaction_select)
      
      customer_id <- as.integer(input$customer_select)
      transaction_id <- as.integer(input$transaction_select)
      
      validator$validate_customer_transaction(customer_id, transaction_id)
    })
    
    # Update transaction choices based on customer
    observe({
      req(input$customer_select)
      
      customer_id <- as.integer(input$customer_select)
      
      # Validate customer exists
      if (!validator$validate_customer(customer_id)) {
        updateSelectInput(session, "transaction_select", 
                         choices = character(0),
                         selected = character(0))
        return()
      }
      
      # Get transactions for customer
      transactions <- app_data$transactions %>%
        filter(customer_id == customer_id)
      
      # Update choices
      transaction_choices <- setNames(
        as.character(transactions$transaction_id),
        paste0("Trans #", transactions$transaction_id, " - ", 
              format(transactions$date, "%Y-%m-%d"))
      )
      
      updateSelectInput(session, "transaction_select", 
                       choices = transaction_choices)
    })
    
    # Display transaction details
    output$transaction_details <- renderUI({
      req(valid_selection())
      
      customer_id <- as.integer(input$customer_select)
      transaction_id <- as.integer(input$transaction_select)
      
      # Safe to access data now that it's validated
      transaction <- app_data$transactions %>%
        filter(transaction_id == transaction_id) %>%
        head(1)
      
      # Render details...
    })
  })
}
```

## Related Rules and Principles
- P0080: Integer ID Consistency Principle
- R0076: Module Data Connection Rule
- R0088: Shiny Module ID Handling
- R0089: Integer ID Type Conversion
- MP0052: Unidirectional Data Flow
