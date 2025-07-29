---
id: "MP0051"
title: "Test Data Design"
type: "meta-principle"
date_created: "2025-04-08"
author: "Claude"
derives_from:
  - "MP0000": "Axiomatization System"
  - "MP0029": "No Fake Data"
  - "P09": "Authentic Context Testing"
influences:
  - "P16": "Component Testing"
  - "MP0048": "Universal Initialization"
---

# Test Data Design Meta-Principle

## Core Principle

Test data must represent realistic application inputs without artificial, redundant, or "weird" settings. Test data should be a focused subset of production-like data that exercises the specific functionality under test with minimal extraneous elements.

## Rationale

High-quality test data is critical for effective testing and development:

1. **Artificial or convoluted test data** leads to:
   - Tests that pass but don't reflect real usage
   - Development against unrealistic scenarios
   - Increased maintenance burden as data evolves
   - Difficulty transferring development knowledge

2. **Well-designed test data** enables:
   - Tests that verify actual requirements
   - Focused debugging and development
   - Clearer understanding of system behavior
   - Transferable knowledge between testing and production
   - Reduced cognitive load for developers

## Implementation Guidelines

### Test Data Design Principles

1. **Minimal Sufficiency**: Test data should contain only what's necessary for the test
   - Include only the fields and records needed to exercise the functionality
   - Avoid excessive fields that don't participate in the test
   - Limit the volume of data to what's needed (1 record is preferred unless testing volume)

2. **Production Representativeness**: Test data should reflect production schemas
   - Match production data types, ranges, and constraints
   - Use realistic field values (proper names, email formats, etc.)
   - Include appropriate null values where they would occur in production

3. **Focused Intent**: Each test dataset should have a clear purpose
   - Create separate test data for different test cases
   - Name test datasets according to their intended use
   - Document the purpose and characteristics of each test dataset

4. **Boundary Coverage**: Include edge cases in specialized test data
   - Create specific test data for boundary conditions
   - Include "empty but valid" cases (empty strings, zero values, etc.)
   - Include maximum values for testing limits
   - These should be separate from "happy path" test data

5. **Self-Validation**: Test data should enable verification
   - Include expected results for comparison
   - Make key fields easily identifiable
   - Use predictable patterns for generated values when appropriate

### Types of Test Data

#### Function Level

For testing individual functions:

```r
# Good: Minimal test data focused on inputs
test_df_customer <- data.frame(
  customer_id = c(1, 2, 3),
  name = c("Alice Chen", "Bob Smith", "Charlie Wong"),
  email = c("alice@example.com", "bob@example.com", "charlie@example.com")
)

# Good: Associated test data with explicit relationship
test_df_orders <- data.frame(
  order_id = c(101, 102, 103, 104),
  customer_id = c(1, 1, 2, 3),
  amount = c(100.50, 200.75, 50.25, 75.00)
)

# Function to test
calculate_customer_metrics <- function(customers, orders) {
  # Function implementation
}

# Simple test
result <- calculate_customer_metrics(test_df_customer, test_df_orders)
```

#### Component Level

For testing UI components:

```r
# Good: Realistic component test data
test_component_data <- list(
  # Complete customer data
  df_customer_profile = data.frame(
    customer_id = 1:5,
    buyer_name = paste0("Customer ", 1:5),
    email = paste0("customer", 1:5, "@example.com"),
    stringsAsFactors = FALSE
  ),
  
  # Partial DNA data (only for some customers)
  df_dna_by_customer = data.frame(
    customer_id = c(1, 2, 4), # Missing data for customers 3 and 5
    r_label = c("近期", "一般", "久遠"),
    r_value = c(5, 15, 45),
    f_label = c("高", "一般", "低"),
    f_value = c(12, 5, 2),
    m_label = c("高", "一般", "低"),
    m_value = c(1500, 500, 100),
    stringsAsFactors = FALSE
  )
)

# Test component with this data
microCustomerServer("test_id", 
                    test_component_data$df_dna_by_customer,
                    test_component_data$df_customer_profile)
```

#### Application Level

For testing integrated application features:

```r
# Good: Complete test data structure for integration testing
app_test_data <- list(
  # Core tables with complete coverage
  customers = generate_test_customers(100),
  products = generate_test_products(50),
  orders = generate_test_orders(200),
  
  # Relationship tables
  order_products = generate_test_order_products(500),
  
  # Analytics data (intentionally partial coverage)
  customer_analytics = generate_customer_analytics(70) # Only 70% coverage
)

# Test app with this data
testApp(app_test_data)
```

### Avoiding Common Pitfalls

#### 1. Redundant Data Scenarios

##### BAD:
```r
# Bad: Redundant checks for the same condition in multiple places
if (is.null(df_customer_profile)) {
  return()
}

# Elsewhere in the same function
if (is.null(df_customer_profile) || nrow(df_customer_profile) == 0) {
  return()
}

# Yet another place
if (is.null(df_customer_profile) || 
    !is.data.frame(df_customer_profile) || 
    nrow(df_customer_profile) == 0) {
  return()
}
```

##### GOOD:
```r
# Good: Define a validation function
validate_customer_data <- function(df) {
  is_valid <- !is.null(df) && 
              is.data.frame(df) && 
              nrow(df) > 0 &&
              all(c("customer_id", "name", "email") %in% colnames(df))
  
  if (!is_valid) {
    log_validation_error("Invalid customer data")
    return(FALSE)
  }
  
  return(TRUE)
}

# Use it consistently
if (!validate_customer_data(df_customer_profile)) {
  return()
}
```

#### 2. Artificial "Special Cases"

##### BAD:
```r
# Bad: Weird special conditions that don't represent real usage
if (input$special_debug_mode && input$weird_test_condition) {
  # Do something that only happens in this artificial test scenario
} else if (input$data_source == "fake_data") {
  # Load artificial test data that doesn't match production
}
```

##### GOOD:
```r
# Good: Explicit feature flag for development/testing
if (app_config$is_development_mode) {
  # Load development test data that mirrors production structure
  data <- load_development_test_data()
} else {
  # Load production data
  data <- load_production_data()
}
```

#### 3. Copy-Pasted Test Data with Minor Variations

##### BAD:
```r
# Bad: Duplicated test data with minor variations
test_data_for_function_a <- data.frame(
  id = 1:5,
  value = c(10, 20, 30, 40, 50),
  status = c("active", "active", "inactive", "active", "inactive")
)

test_data_for_function_b <- data.frame(
  id = 1:5,
  value = c(10, 20, 35, 40, 55),  # Slightly different values
  status = c("active", "active", "inactive", "active", "active") # One status changed
)
```

##### GOOD:
```r
# Good: Parameterized test data generation
generate_test_data <- function(status_pattern = c("active", "active", "inactive", "active", "inactive"),
                               value_adjustments = c(0, 0, 0, 0, 0)) {
  base_values <- c(10, 20, 30, 40, 50)
  
  data.frame(
    id = 1:5,
    value = base_values + value_adjustments,
    status = status_pattern
  )
}

# Use the generator with appropriate parameters
test_data_for_function_a <- generate_test_data()
test_data_for_function_b <- generate_test_data(
  status_pattern = c("active", "active", "inactive", "active", "active"),
  value_adjustments = c(0, 0, 5, 0, 5)
)
```

## Test Data Documentation

All test data should be documented:

1. **Purpose**: What is this test data for?
2. **Coverage**: What cases does it cover? What cases does it NOT cover?
3. **Generation Method**: How was it created? (Manually, generated, subset of production)
4. **Relationships**: How do the different data sets relate to each other?
5. **Key Fields**: Which fields are key identifiers? (Using NSQL key notation)

Example documentation:

```r
#' Customer Test Data
#'
#' Test data for customer analytics module containing:
#' - test_df_customer_profile (key = customer_id): Complete set of 10 customers
#' - test_df_dna_by_customer (key = customer_id): DNA analysis for 7 out of 10 customers
#'
#' @usage
#' data <- load_customer_test_data()
#' customer_profiles <- data$df_customer_profile
#' customer_dna <- data$df_dna_by_customer
#'
#' @coverage
#' - Complete profiles for all customers
#' - DNA analysis for 70% of customers (IDs 1-7)
#' - Missing DNA for 30% of customers (IDs 8-10)
#' - Includes one customer with extremely high values (ID 7)
#' - Includes one customer with all minimal values (ID 1)
#'
#' @return List containing test dataframes
#' @export
load_customer_test_data <- function() {
  # Implementation
}
```

## Relationship to Other Principles

This meta-principle:

1. **Extends MP0029 (No Fake Data)**: Provides specific guidelines for test data design
2. **Implements P09 (Authentic Context Testing)**: Ensures test data mirrors real-world scenarios
3. **Supports P16 (Component Testing)**: Enables effective component testing with appropriate data
4. **Complements MP0048 (Universal Initialization)**: Ensures test data is properly initialized

## Verification Checklist

To verify compliance with this meta-principle, check that:

1. Test data contains minimal sufficient fields and records
2. Test data matches production schemas and constraints
3. Test data has a clear, focused purpose
4. Test data includes appropriate edge cases
5. Test data enables proper verification of results
6. Test data is well-documented
7. No artificial, weird, or redundant scenarios are created
8. Test data design facilitates maintenance and reuse

## Implementation Timeline

Existing test data should be reviewed and refactored to comply with this meta-principle according to the following schedule:

1. New test data: Immediate compliance
2. Critical component test data: Within 30 days
3. All other test data: Within 90 days

Compliance should be verified during code reviews and documented in the test data itself.
