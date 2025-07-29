# P0082: Dataframe Column Access Pattern Principle

## Statement
Access to dataframe columns shall preferentially use the `[["column_name"]]` notation rather than the `$column_name` syntax to improve robustness, compatibility with dynamic column names, and defensive programming practices.

## Description
This principle establishes a standardized approach for accessing columns in dataframes, with a preference for using double bracket notation (`df[["column_name"]]`) instead of the dollar sign notation (`df$column_name`). This approach provides more consistent behavior, particularly when working with dynamic column names, programmatically-generated column names, or columns with special characters.

## Rationale
1. **Robustness with Non-standard Names**: Double bracket notation handles column names with spaces, special characters, or reserved words more reliably
2. **Dynamic Column Access**: Enables variable column names and programmatic column selection
3. **Consistent Error Handling**: Provides more uniform behavior when columns don't exist
4. **Defensive Programming**: Pairs well with column existence validation with `column_name %in% names(df)`
5. **Type Safety**: Reduces unintended partial matching issues that can occur with `$` notation

## Implementation Patterns

### Basic Column Access

```r
# CORRECT: Using double bracket notation
customer_name <- customers[["full_name"]]

# AVOID: Using dollar notation
customer_name <- customers$full_name
```

### With Dynamic Column Names

```r
# CORRECT: Dynamic column access with variable
field_name <- "total_sales"
value <- sales_data[[field_name]]

# CORRECT: Column name from function return
id_field <- get_id_field_name(data_type)
ids <- data[[id_field]]

# INCORRECT: Cannot use with $ notation
field_name <- "total_sales"
value <- sales_data$field_name  # This will look for literal "field_name" column
```

### With Column Existence Checking

```r
# CORRECT: Safe column access pattern
if (field %in% names(dat)) {
  value <- dat[[field]]
} else {
  # Handle missing column case
  value <- default_value
}

# CORRECT: In a function with default value
safeValue <- function(data, field, default = NA) {
  if (is.null(data) || !is.data.frame(data) || 
      nrow(data) == 0 || !field %in% names(data)) {
    return(default)
  }
  value <- data[[field]][1]
  if (is.null(value) || is.na(value)) {
    return(default)
  }
  return(value)
}
```

### With Plotly or ggplot

```r
# CORRECT: For plotly/ggplot, use formula notation (tilde) which works differently
plot_ly(df, x = ~x, y = ~y, type = "scatter")

# ALSO CORRECT: For data.table syntax, you may use the specific data.table syntax
dt[, sum(value), by = group]
```

## Anti-patterns

### Mixing Access Styles

```r
# INCORRECT: Inconsistent style mixing $ and [[]]
customer_name <- customers$name
customer_email <- customers[["email_address"]]
purchase_total <- customers$total

# CORRECT: Consistent style using [[]]
customer_name <- customers[["name"]]
customer_email <- customers[["email_address"]]
purchase_total <- customers[["total"]]
```

### Accessing Non-existent Columns

```r
# INCORRECT: No validation before access
value <- data$column_that_might_not_exist  # May return NULL or error

# CORRECT: Validate existence first
if ("column_that_might_not_exist" %in% names(data)) {
  value <- data[["column_that_might_not_exist"]]
} else {
  # Handle the missing case
}
```

### Column Name Conflicts with Function Names

```r
# PROBLEMATIC: When column name is a function name, $ can be ambiguous
data$round  # Is this data$round or the round() function in the data environment?

# CLEAR: Explicitly shows intent to access column
data[["round"]]
```

## Examples

### Complete Helper Function Example

```r
# Safe value retrieval function using the double bracket pattern
get_customer_metric <- function(customer_data, metric_name, default_value = NA) {
  # Validate inputs
  if (is.null(customer_data) || !is.data.frame(customer_data) || nrow(customer_data) == 0) {
    return(default_value)
  }
  
  # Check if metric exists in data
  if (!metric_name %in% names(customer_data)) {
    warning(paste("Metric", metric_name, "not found in customer data"))
    return(default_value)
  }
  
  # Get value using double bracket notation
  value <- customer_data[[metric_name]][1]  # First row only
  
  # Handle NA/NULL
  if (is.null(value) || is.na(value)) {
    return(default_value)
  }
  
  return(value)
}

# Example usage
display_customer_metrics <- function(customer_id, conn) {
  # Get customer data
  customer <- get_customer_data(customer_id, conn)
  
  # Retrieve metrics safely using double bracket pattern
  cust_name <- get_customer_metric(customer, "customer_name", "Unknown")
  total_orders <- get_customer_metric(customer, "total_orders", 0)
  avg_order_value <- get_customer_metric(customer, "average_order", 0)
  
  # Use the values
  tagList(
    h3(paste("Customer:", cust_name)),
    p(paste("Total Orders:", total_orders)),
    p(paste("Average Order Value:", sprintf("$%.2f", avg_order_value)))
  )
}
```

### Shiny Module With Consistent Column Access

```r
# UI Function
customerMetricsUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    selectInput(ns("customer_select"), "Select Customer:", NULL),
    selectInput(ns("metric_field"), "Select Metric:", 
                c("Purchase Frequency", "Recency", "Monetary Value", "Customer Age")),
    plotlyOutput(ns("metric_plot"))
  )
}

# Server Function with consistent column access
customerMetricsServer <- function(id, customer_data) {
  moduleServer(id, function(input, output, session) {
    
    # Field name mapping
    field_mapping <- reactive({
      c(
        "Purchase Frequency" = "f_value",
        "Recency" = "r_value",
        "Monetary Value" = "m_value",
        "Customer Age" = "customer_age_days"
      )
    })
    
    # Get current field name
    current_field <- reactive({
      req(input$metric_field)
      field_mapping()[[input$metric_field]]
    })
    
    # Create plot with double bracket notation
    output$metric_plot <- renderPlotly({
      req(customer_data(), current_field())
      
      # Get data and current field
      dat <- customer_data()
      field <- current_field()
      
      # Validate field exists in data
      if (!field %in% names(dat)) {
        return(plotly_empty() %>% 
                 add_annotations(text = "Selected metric is not available", showarrow = FALSE))
      }
      
      # Use double bracket notation for column access
      plot_ly(dat, x = ~customer_id, y = as.formula(paste0("~", field)), type = "bar") %>%
        layout(title = input$metric_field,
               xaxis = list(title = "Customer ID"),
               yaxis = list(title = input$metric_field))
    })
  })
}
```

## Related Principles and Rules
- MP0047: Functional Programming Principle
- MP0060: Parsimony Principle
- P0076: Error Handling Patterns
- R0073: App.R Change Permissions
- R0089: Integer ID Type Conversion
- R0090: ID Relationship Validation
- P0014: Dot Notation Property Access
- P0105: Minimal Example Construction