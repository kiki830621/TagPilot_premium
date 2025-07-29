# R74: Shiny Test Data Rule

## Purpose

This rule establishes standardized patterns for creating and using test data specifically for Shiny applications and components. It implements MP51 (Test Data Design) with Shiny-specific considerations.

## Implementation

### 1. Test Data Structure

All Shiny test data must follow a consistent structure:

```r
# Standard structure for component test data
component_test_data <- list(
  # Input data sets as named elements matching parameter names
  input_data_1 = data.frame(...),
  input_data_2 = data.frame(...),
  
  # Expected output for validation (optional)
  expected_output = list(...),
  
  # Test metadata
  metadata = list(
    description = "Test data for X component",
    covers_cases = c("normal operation", "missing values"),
    key_fields = c("field1", "field2")
  )
)
```

### 2. Reactive Data Sources

Test data for reactive contexts must clearly distinguish between:

```r
# Different types of reactive data
shiny_test_data <- list(
  # Static inputs (non-reactive)
  static_inputs = list(
    df_customer_profile = data.frame(...),
    df_product_catalog = data.frame(...)
  ),
  
  # Initial reactive values
  initial_reactive_values = list(
    selected_customer_id = 1,
    filter_date_range = c("2025-01-01", "2025-03-31")
  ),
  
  # Reactive value updates for testing reactions
  reactive_updates = list(
    list(
      input = "selected_customer_id",
      value = 2,
      expected_effects = c("customer_details", "order_history")
    ),
    list(
      input = "filter_date_range",
      value = c("2025-01-01", "2025-04-30"),
      expected_effects = c("transaction_summary", "date_filtered_chart")
    )
  )
)
```

### 3. UI Component Test Data

Test data for UI components must be structurally sound and visually representative:

```r
# UI component test data
ui_test_data <- list(
  # Complete data set for UI population
  df_dropdown_choices = data.frame(
    id = 1:5,
    label = c("Option A", "Option B", "Option C", "Option D", "Option E")
  ),
  
  # Specific cases for UI state testing
  display_cases = list(
    empty = data.frame(id = integer(0), label = character(0)),
    single = data.frame(id = 1, label = "Only Option"),
    many = data.frame(id = 1:100, label = paste("Option", 1:100)),
    multilingual = data.frame(
      id = 1:3,
      label = c("English", "简体中文", "繁體中文")
    )
  )
)
```

### 4. Server-Side Test Data

Test data for server logic must include validation cases:

```r
# Server logic test data
server_test_data <- list(
  # Input datasets
  df_input = data.frame(...),
  
  # Test cases with inputs and expected outputs
  test_cases = list(
    valid_case = list(
      inputs = list(x = 1, y = "test"),
      expected = list(z = 2, w = "TEST")
    ),
    edge_case = list(
      inputs = list(x = 0, y = ""),
      expected = list(z = 0, w = "")
    ),
    error_case = list(
      inputs = list(x = NULL, y = NULL),
      expected_error = "Invalid input values"
    )
  )
)
```

### 5. Module Integration Test Data

For testing module interactions, define interface-compliant test data:

```r
# Module integration test data
integration_test_data <- list(
  # Module A output (becomes Module B input)
  module_a_output = reactiveVal(data.frame(...)),
  
  # Module B expected internal state after receiving Module A output
  expected_module_b_state = list(
    filtered_data = data.frame(...),
    summary_stats = list(...)
  ),
  
  # Expected final outputs after full integration
  expected_integrated_outputs = list(
    plot_data = data.frame(...),
    table_data = data.frame(...)
  )
)
```

## Standard Test Data Blocks

### 1. Customer Data Block

For customer-related components:

```r
# Standard customer test data block
customer_test_block <- function(n_customers = 10, 
                               dna_coverage_pct = 70,
                               include_edge_cases = TRUE) {
  # Generate basic customer data (always complete)
  customers <- data.frame(
    customer_id = 1:n_customers,
    buyer_name = paste("Customer", 1:n_customers),
    email = paste0("customer", 1:n_customers, "@example.com"),
    registration_date = as.Date("2025-01-01") - (n_customers:1),
    stringsAsFactors = FALSE
  )
  
  # Calculate how many customers have DNA data
  n_with_dna <- ceiling(n_customers * dna_coverage_pct / 100)
  
  # Customer DNA data (intentionally partial)
  customer_dna <- data.frame(
    customer_id = 1:n_with_dna,
    r_label = sample(c("極近", "近期", "一般", "久遠", "非常久遠"), n_with_dna, replace = TRUE),
    r_value = sample(1:60, n_with_dna, replace = TRUE),
    f_label = sample(c("極低", "低", "一般", "高", "非常高"), n_with_dna, replace = TRUE),
    f_value = sample(1:20, n_with_dna, replace = TRUE),
    m_label = sample(c("極低", "低", "一般", "高", "非常高"), n_with_dna, replace = TRUE),
    m_value = sample(seq(100, 2000, by = 100), n_with_dna, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Add edge cases if requested
  if (include_edge_cases) {
    # Edge case 1: Customer with extreme values (if we have at least one customer)
    if (n_with_dna > 0) {
      customer_dna[1, "r_value"] <- 1
      customer_dna[1, "r_label"] <- "極近"
      customer_dna[1, "f_value"] <- 20
      customer_dna[1, "f_label"] <- "非常高"
      customer_dna[1, "m_value"] <- 2000
      customer_dna[1, "m_label"] <- "非常高"
    }
    
    # Edge case 2: Customer with minimal values (if we have at least two customers)
    if (n_with_dna > 1) {
      customer_dna[2, "r_value"] <- 60
      customer_dna[2, "r_label"] <- "非常久遠"
      customer_dna[2, "f_value"] <- 1
      customer_dna[2, "f_label"] <- "極低"
      customer_dna[2, "m_value"] <- 100
      customer_dna[2, "m_label"] <- "極低"
    }
  }
  
  return(list(
    df_customer_profile = customers,        # Complete customer profiles
    df_dna_by_customer = customer_dna,      # Partial DNA data
    
    # Metadata about this test block
    metadata = list(
      description = "Standard customer test data",
      customer_count = n_customers,
      dna_coverage_pct = dna_coverage_pct,
      includes_edge_cases = include_edge_cases,
      key_relationship = "df_customer_profile (key = customer_id) is complete, df_dna_by_customer (key = customer_id) is partial"
    )
  ))
}
```

### 2. Orders Data Block

For order-related components:

```r
# Standard orders test data block
orders_test_block <- function(n_customers = 10, 
                             avg_orders_per_customer = 3,
                             date_range = c("2025-01-01", "2025-03-31")) {
  
  # Calculate total orders
  n_orders <- n_customers * avg_orders_per_customer
  
  # Generate customer assignments (some customers may have more orders than others)
  customer_ids <- rep(1:n_customers, times = sample(1:(2*avg_orders_per_customer), n_customers, replace = TRUE))
  customer_ids <- customer_ids[1:n_orders]  # Trim to get exactly n_orders
  
  # Generate order dates across the specified range
  date_range <- as.Date(date_range)
  date_span <- as.numeric(diff(date_range)) + 1
  order_dates <- date_range[1] + sample(0:(date_span-1), n_orders, replace = TRUE)
  
  # Generate order data
  orders <- data.frame(
    order_id = 1:n_orders,
    customer_id = customer_ids,
    order_date = order_dates,
    order_total = round(runif(n_orders, min = 50, max = 500), 2),
    items_count = sample(1:10, n_orders, replace = TRUE),
    stringsAsFactors = FALSE
  )
  
  # Sort by date
  orders <- orders[order(orders$order_date), ]
  
  return(list(
    df_orders = orders,
    
    # Derived aggregations for convenience
    df_customer_order_summary = aggregate(
      order_total ~ customer_id, 
      data = orders, 
      FUN = function(x) c(count = length(x), total = sum(x), avg = mean(x))
    ),
    
    # Metadata
    metadata = list(
      description = "Standard orders test data",
      orders_count = n_orders,
      customers_with_orders = length(unique(orders$customer_id)),
      date_range = format(range(orders$order_date)),
      key_fields = c("order_id", "customer_id")
    )
  ))
}
```

## Integration with Testing Frameworks

### 1. Shiny Testing Library Integration

```r
library(shinytest2)

# Use standard test data with shinytest2
test_that("microCustomer module renders correctly", {
  # Get standard test data
  test_data <- customer_test_block(n_customers = 5, dna_coverage_pct = 60)
  
  # Create test app with the data
  app <- AppDriver$new(
    app_dir = test_app_dir,
    name = "microCustomer-test",
    variant = platform_variant(),
    seed = 123,
    options = list(
      test_data = test_data
    )
  )
  
  # Test the app
  app$set_inputs(customer_select = "2")
  app$wait_for_value(output = "customer_name")
  
  # Get outputs
  customer_name <- app$get_value(output = "customer_name")
  
  # Verify with test data
  expected_name <- test_data$df_customer_profile$buyer_name[2]
  expect_equal(customer_name, expected_name)
})
```

### 2. Module Testing

```r
# Module testing function
test_module <- function(module_server_fn, test_data, input_values) {
  # Create test environment
  testServer(
    module_server_fn,
    args = list(
      df_customer_profile = test_data$df_customer_profile,
      df_dna_by_customer = test_data$df_dna_by_customer
    ),
    expr = {
      # Set inputs based on test data
      session$setInputs(!!!input_values)
      
      # Assertions about reactive outputs
      expect_type(output$customer_name, "character")
      expect_equal(length(output$dna_recency), 1)
    }
  )
}

# Execute test with standard data
test_that("microCustomer server handles data correctly", {
  test_data <- customer_test_block()
  test_module(microCustomerServer, test_data, list(customer_select = "1"))
})
```

## Common Test Data Patterns

### 1. Complete vs. Partial Data Pattern

For testing handling of incomplete data relationships:

```r
# Create test data with partial relationships
test_data <- list(
  # Complete reference table
  df_complete = data.frame(
    id = 1:10,
    name = paste0("Item ", 1:10)
  ),
  
  # Partial data table (only for some items)
  df_partial = data.frame(
    id = c(1, 3, 5, 7, 9),
    value = c(100, 300, 500, 700, 900)
  )
)

# Test expectations
test_that("Component handles missing relationships", {
  # Test with item that has data
  result1 <- process_item(5, test_data$df_complete, test_data$df_partial)
  expect_equal(result1$value, 500)
  
  # Test with item that has no data
  result2 <- process_item(6, test_data$df_complete, test_data$df_partial)
  expect_equal(result2$value, 0)  # Default value when no data exists
})
```

### 2. Reactive Chain Testing Pattern

For testing reactive dependencies:

```r
# Test reactive chains
test_that("Reactive chain updates correctly", {
  test_data <- reactive_test_block()
  
  testServer(
    app_server,
    args = list(data = test_data$static_inputs),
    expr = {
      # Initial state
      session$setInputs(
        customer_select = test_data$initial_reactive_values$selected_customer_id
      )
      
      # Capture initial output state
      initial_output <- output$customer_summary
      
      # Update reactive value
      update_info <- test_data$reactive_updates[[1]]
      session$setInputs(!!update_info$input := update_info$value)
      
      # Verify changes in target outputs
      for (output_name in update_info$expected_effects) {
        expect_false(identical(output[[output_name]], initial_output[[output_name]]))
      }
    }
  )
})
```

## Relationship to Other Rules

### 1. Influences:
- **P09 (Authentic Context Testing)**: Provides specific test data structure for authentic testing
- **P16 (Component Testing)**: Supports component testing with appropriate test data
- **R71 (Enhanced Input Components)**: Helps test enhanced inputs with realistic test data

### 2. Implements:
- **MP51 (Test Data Design)**: Implements the metaprinciple specifically for Shiny applications
- **MP29 (No Fake Data)**: Ensures test data reflects production structures

## Validation Checklist

For each Shiny component test dataset, verify:

1. It has a consistent structure following this rule
2. Clear identification of complete vs. partial data relationships
3. Realistic values appropriate for UI rendering
4. Explicit edge cases for boundary testing
5. No redundant validations or artificial special cases
6. Proper documentation of test data purpose and characteristics

## Exceptions

Test data for performance testing and large-scale data simulations may deviate from these patterns, but must be clearly labeled as performance test data and should still maintain realistic data structures.

## Examples from Existing Codebase

The microCustomer component demonstrates several test data patterns that can be improved:

### Current Pattern (Not Recommended):
```r
# Redundant validation checks
if (is.null(df_customer_profile) || !is.data.frame(df_customer_profile) || 
    nrow(df_customer_profile) == 0 || 
    !all(c("customer_id", "buyer_name", "email") %in% colnames(df_customer_profile))) {
  return()
}

# Repeat the same check in multiple places
```

### Improved Pattern (Recommended):
```r
# Create standard test data
test_data <- customer_test_block(
  n_customers = 10,
  dna_coverage_pct = 70,
  include_edge_cases = TRUE
)

# Use data validation helper (defined once)
validate_data <- function(data, required_fields, data_name = "Data") {
  if (is.null(data) || !is.data.frame(data) || nrow(data) == 0) {
    message(data_name, " is null, empty, or not a data frame")
    return(FALSE)
  }
  
  if (!all(required_fields %in% colnames(data))) {
    message(data_name, " is missing required fields: ", 
            paste(setdiff(required_fields, colnames(data)), collapse = ", "))
    return(FALSE)
  }
  
  return(TRUE)
}

# Validate once
if (!validate_data(test_data$df_customer_profile, 
                  c("customer_id", "buyer_name", "email"),
                  "Customer profile data")) {
  # Handle invalid data case
}
```

This rule standardizes Shiny test data creation to ensure realistic, maintainable, and effective testing across the application.